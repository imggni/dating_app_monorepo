import { HttpError } from '../errors/http-error';

export const createGroup = async (_userId: string, _args: { name: string; memberIds?: string[] | undefined }) => {
  throw new HttpError(501, '群聊功能未启用');
};

export const addGroupMember = async (_userId: string, _args: { groupId: string; memberId: string }) => {
  throw new HttpError(501, '群聊功能未启用');
};

export const removeGroupMember = async (_userId: string, _args: { groupId: string; memberId: string }) => {
  throw new HttpError(501, '群聊功能未启用');
};

export default {
  createGroup,
  addGroupMember,
  removeGroupMember,
};

