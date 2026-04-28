import crypto from 'crypto';
import path from 'path';

import prisma = require('../prisma/prisma');
import { HttpError } from '../errors/http-error';

// TencentCloud SDK
const tencentcloud = require('tencentcloud-sdk-nodejs');

type UploadType = 'image' | 'avatar' | 'audio' | 'video' | 'document';

const allowedTypes: Record<UploadType, string[]> = {
  image: ['image/jpeg', 'image/png', 'image/gif', 'image/webp'],
  avatar: ['image/jpeg', 'image/png', 'image/webp'],
  audio: ['audio/mpeg', 'audio/wav', 'audio/ogg'],
  video: ['video/mp4', 'video/avi', 'video/mov'],
  document: ['application/pdf', 'text/plain', 'application/msword'],
};

export const uploadFile = async (file: Express.Multer.File | undefined, type: UploadType = 'image') => {
  if (!file) throw new HttpError(400, '文件不能为空');

  const maxSize = type === 'image' ? 5 * 1024 * 1024 : 10 * 1024 * 1024;
  if (file.size > maxSize) throw new HttpError(400, `文件大小不能超过 ${maxSize / 1024 / 1024}MB`);

  if (!allowedTypes[type] || !allowedTypes[type].includes(file.mimetype)) {
    throw new HttpError(400, `不支持的文件类型: ${file.mimetype}`);
  }

  const ext = path.extname(file.originalname);
  const fileName = `${Date.now()}-${crypto.randomBytes(8).toString('hex')}${ext}`;

  const cloudbaseUrl = process.env.CLOUDBASE_STORAGE_URL;
  const envId = process.env.CLOUDBASE_ENV_ID;
  if (!cloudbaseUrl || !envId) throw new HttpError(500, '云存储配置缺失');

  const fileUrl = `${cloudbaseUrl}/${envId}/uploads/${fileName}`;
  return {
    url: fileUrl,
    fileName: file.originalname,
    fileSize: file.size,
    fileType: file.mimetype,
    uploadedAt: new Date(),
  };
};

export const refreshToken = async (refreshToken: string | undefined) => {
  if (!refreshToken) throw new HttpError(400, 'Refresh token 不能为空');

  const jwt = await import('jsonwebtoken');
  try {
    const decoded: any = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET || (process.env.JWT_SECRET as string));

    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
      select: { id: true, phone: true, nickname: true },
    });
    if (!user) throw new HttpError(401, '用户不存在');

    if (!process.env.JWT_SECRET) throw new HttpError(500, '服务端未配置 JWT_SECRET');

    const accessToken = jwt.sign({ userId: user.id, phone: user.phone }, process.env.JWT_SECRET, { expiresIn: '7d' });
    const newRefreshToken = jwt.sign(
      { userId: user.id },
      process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET,
      { expiresIn: '30d' }
    );

    return { accessToken, refreshToken: newRefreshToken, expiresIn: 7 * 24 * 60 * 60 };
  } catch (error: any) {
    if (error?.name === 'TokenExpiredError') throw new HttpError(401, 'Refresh token 已过期');
    throw new HttpError(401, '无效的 refresh token');
  }
};

export const getConfigs = async () => {
  try {
    const configs = await prisma.systemConfig.findMany({ select: { configKey: true, configValue: true } });

    const configMap: Record<string, unknown> = {};
    configs.forEach((config: any) => {
      try {
        configMap[config.configKey] = JSON.parse(config.configValue);
      } catch {
        configMap[config.configKey] = config.configValue;
      }
    });

    const defaultConfig = {
      version: process.env.APP_VERSION || '1.0.0',
      minVersion: process.env.APP_MIN_VERSION || '1.0.0',
      updateUrl: process.env.APP_UPDATE_URL || '',
      privacyUrl: process.env.APP_PRIVACY_URL || '',
      termsUrl: process.env.APP_TERMS_URL || '',
      customerService: {
        phone: process.env.CS_PHONE || '',
        email: process.env.CS_EMAIL || '',
        workingHours: process.env.CS_WORKING_HOURS || '',
      },
    };

    return { ...defaultConfig, ...configMap };
  } catch (error: any) {
    console.error('获取配置失败:', error?.message || error);
    return {
      version: process.env.APP_VERSION || '1.0.0',
      minVersion: process.env.APP_MIN_VERSION || '1.0.0',
      updateUrl: process.env.APP_UPDATE_URL || '',
      privacyUrl: process.env.APP_PRIVACY_URL || '',
      termsUrl: process.env.APP_TERMS_URL || '',
      customerService: {
        phone: process.env.CS_PHONE || '',
        email: process.env.CS_EMAIL || '',
        workingHours: process.env.CS_WORKING_HOURS || '',
      },
    };
  }
};

export const filterSensitiveContent = async (content: string, type: 'text' | 'image' = 'text') => {
  if (!content || content.trim().length === 0) return { isSafe: true, filteredContent: content };

  try {
    const secretId = process.env.TC_SECRET_ID;
    const secretKey = process.env.TC_SECRET_KEY;

    if (!secretId || !secretKey) {
      console.warn('腾讯云内容安全配置缺失，使用本地过滤');
      const sensitiveWords = (process.env.SENSITIVE_WORDS || '')
        .split(',')
        .map((s) => s.trim())
        .filter(Boolean);

      let filteredContent = content;
      let isSafe = true;
      sensitiveWords.forEach((word) => {
        if (filteredContent.includes(word)) {
          filteredContent = filteredContent.replace(new RegExp(word, 'g'), '**');
          isSafe = false;
        }
      });
      return { isSafe, filteredContent };
    }

    const CmsClient = tencentcloud.cms.v20190321.Client;
    const client = new CmsClient({
      credential: { secretId, secretKey },
      region: process.env.TC_REGION || 'ap-guangzhou',
      profile: { httpProfile: { endpoint: 'cms.tencentcloudapi.com' } },
    });

    const params = { Content: content, ContentType: type === 'text' ? 'Text' : 'Image' };
    const result = await client.TextModeration(params);

    const isSafe = result.Data.EvilType === 0;
    const filteredContent = isSafe ? content : content.replace(/./g, '*');

    return {
      isSafe,
      filteredContent,
      evilType: result.Data.EvilType,
      confidence: result.Data.Confidence,
    };
  } catch (error: any) {
    console.error('敏感词过滤失败:', error?.message || error);
    return { isSafe: true, filteredContent: content, error: '过滤服务暂时不可用' };
  }
};

type Region = { code: string; name: string; type: string; parentCode?: string };

const regions: Region[] = [
  { code: 'CN', name: '中国', type: 'country' },
  { code: 'CN-BJ', name: '北京市', type: 'province', parentCode: 'CN' },
  { code: 'CN-SH', name: '上海市', type: 'province', parentCode: 'CN' },
  { code: 'CN-BJ-CY', name: '朝阳区', type: 'district', parentCode: 'CN-BJ' },
];

export const getRegions = async (type?: string, parentCode?: string) => {
  let filtered = regions;
  if (type) filtered = filtered.filter((r) => r.type === type);
  if (parentCode) filtered = filtered.filter((r) => r.parentCode === parentCode);
  return filtered;
};

const buildRegionPath = (region: Region, allRegions: Region[]) => {
  const parts = [region.name];
  let current: Region = region;

  while (current.parentCode) {
    const parent = allRegions.find((r) => r.code === current.parentCode);
    if (!parent) break;
    parts.unshift(parent.name);
    current = parent;
  }

  return parts.join('/');
};

export const getRegionByCode = async (code: string) => {
  const all = await getRegions();
  const region = all.find((r) => r.code === code);
  if (!region) throw new HttpError(404, '地区不存在');
  return { ...region, fullPath: buildRegionPath(region, all) };
};

export const getDictionaries = async (type?: string) => {
  const dictionaries: Record<string, unknown> = {
    gender: [
      { value: 'male', label: '男', sort: 1 },
      { value: 'female', label: '女', sort: 2 },
      { value: 'other', label: '其他', sort: 3 },
    ],
    interest: [
      { value: 'sports', label: '运动', sort: 1 },
      { value: 'music', label: '音乐', sort: 2 },
      { value: 'travel', label: '旅行', sort: 3 },
      { value: 'reading', label: '阅读', sort: 4 },
      { value: 'gaming', label: '游戏', sort: 5 },
    ],
    occupation: [
      { value: 'student', label: '学生', sort: 1 },
      { value: 'engineer', label: '工程师', sort: 2 },
      { value: 'teacher', label: '教师', sort: 3 },
      { value: 'doctor', label: '医生', sort: 4 },
      { value: 'other', label: '其他', sort: 5 },
    ],
  };

  if (type) return { [type]: (dictionaries[type] as any) || [] };
  return dictionaries;
};

export const getOssToken = async () => {
  // Avoid returning fake credentials. If OSS token is required, implement STS and enable by env.
  throw new HttpError(501, '未启用 OSS 临时凭证服务');
};

export default {
  uploadFile,
  refreshToken,
  getConfigs,
  filterSensitiveContent,
  getRegions,
  getRegionByCode,
  getDictionaries,
  getOssToken,
};

