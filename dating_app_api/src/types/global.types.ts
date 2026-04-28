export const UserStatus = {
  ONLINE: 'online',
  OFFLINE: 'offline',
} as const;

export type UserStatus = (typeof UserStatus)[keyof typeof UserStatus];

