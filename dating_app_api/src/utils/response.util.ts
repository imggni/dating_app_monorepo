import type { Response } from 'express';

type ApiResponse<T> = {
  code: number;
  message: string;
  data: T;
};

export const sendOk = <T>(res: Response, data: T, message = '成功') => {
  const body: ApiResponse<T> = { code: 0, message, data };
  return res.json(body);
};

export const sendCreated = <T>(res: Response, data: T, message = '创建成功') => {
  const body: ApiResponse<T> = { code: 0, message, data };
  return res.status(201).json(body);
};

export const sendBadRequest = (res: Response, message: string, data: unknown = null) => {
  const body: ApiResponse<unknown> = { code: 400, message, data };
  return res.status(400).json(body);
};

