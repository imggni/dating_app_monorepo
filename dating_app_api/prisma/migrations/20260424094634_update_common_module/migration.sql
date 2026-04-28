-- CreateTable
CREATE TABLE `User` (
    `id` VARCHAR(191) NOT NULL,
    `phone` VARCHAR(191) NOT NULL,
    `password` VARCHAR(191) NOT NULL,
    `nickname` VARCHAR(191) NOT NULL,
    `avatar` VARCHAR(191) NULL,
    `gender` VARCHAR(191) NULL,
    `age` INTEGER NULL,
    `bio` VARCHAR(191) NULL,
    `tags` VARCHAR(191) NOT NULL,
    `isAnonymous` BOOLEAN NOT NULL DEFAULT false,
    `onlineStatus` BOOLEAN NOT NULL DEFAULT false,
    `gameScore` INTEGER NOT NULL DEFAULT 0,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,
    `deletedAt` DATETIME(3) NULL,

    UNIQUE INDEX `User_phone_key`(`phone`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `FriendRelation` (
    `id` VARCHAR(191) NOT NULL,
    `userId` VARCHAR(191) NOT NULL,
    `friendId` VARCHAR(191) NOT NULL,
    `status` VARCHAR(191) NOT NULL DEFAULT 'pending',
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    INDEX `FriendRelation_friendId_idx`(`friendId`),
    UNIQUE INDEX `FriendRelation_userId_friendId_key`(`userId`, `friendId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `ImMessage` (
    `id` VARCHAR(191) NOT NULL,
    `senderId` VARCHAR(191) NOT NULL,
    `receiverId` VARCHAR(191) NOT NULL,
    `groupId` VARCHAR(191) NULL,
    `messageType` VARCHAR(191) NOT NULL,
    `content` VARCHAR(191) NOT NULL,
    `isRead` BOOLEAN NOT NULL DEFAULT false,
    `isRecalled` BOOLEAN NOT NULL DEFAULT false,
    `sendTime` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `deletedAt` DATETIME(3) NULL,

    INDEX `ImMessage_senderId_receiverId_sendTime_idx`(`senderId`, `receiverId`, `sendTime`),
    INDEX `ImMessage_groupId_sendTime_idx`(`groupId`, `sendTime`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `SlowChat` (
    `id` VARCHAR(191) NOT NULL,
    `senderId` VARCHAR(191) NOT NULL,
    `receiverId` VARCHAR(191) NOT NULL,
    `title` VARCHAR(191) NOT NULL,
    `content` VARCHAR(191) NOT NULL,
    `messageType` VARCHAR(191) NOT NULL,
    `delayTime` INTEGER NOT NULL,
    `sendTime` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `actualSendTime` DATETIME(3) NULL,
    `isOpened` BOOLEAN NOT NULL DEFAULT false,
    `isAnonymous` BOOLEAN NOT NULL DEFAULT false,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    INDEX `SlowChat_senderId_receiverId_idx`(`senderId`, `receiverId`),
    INDEX `SlowChat_receiverId_isOpened_idx`(`receiverId`, `isOpened`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `GameRoom` (
    `id` VARCHAR(191) NOT NULL,
    `roomName` VARCHAR(191) NOT NULL,
    `roomCode` VARCHAR(191) NOT NULL,
    `status` VARCHAR(191) NOT NULL DEFAULT 'waiting',
    `hostId` VARCHAR(191) NOT NULL,
    `maxPlayers` INTEGER NOT NULL DEFAULT 4,
    `currentPlayers` INTEGER NOT NULL DEFAULT 1,
    `gameRound` INTEGER NOT NULL DEFAULT 1,
    `roundTime` INTEGER NOT NULL DEFAULT 60,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,
    `endedAt` DATETIME(3) NULL,

    UNIQUE INDEX `GameRoom_roomCode_key`(`roomCode`),
    INDEX `GameRoom_roomCode_idx`(`roomCode`),
    INDEX `GameRoom_status_currentPlayers_idx`(`status`, `currentPlayers`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `GameRoomMember` (
    `id` VARCHAR(191) NOT NULL,
    `roomId` VARCHAR(191) NOT NULL,
    `userId` VARCHAR(191) NOT NULL,
    `role` VARCHAR(191) NOT NULL DEFAULT 'player',
    `score` INTEGER NOT NULL DEFAULT 0,
    `joinTime` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `GameRoomMember_userId_idx`(`userId`),
    UNIQUE INDEX `GameRoomMember_roomId_userId_key`(`roomId`, `userId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `GameRecord` (
    `id` VARCHAR(191) NOT NULL,
    `roomId` VARCHAR(191) NOT NULL,
    `round` INTEGER NOT NULL,
    `drawerId` VARCHAR(191) NOT NULL,
    `word` VARCHAR(191) NOT NULL,
    `brushData` TEXT NOT NULL,
    `isFinished` BOOLEAN NOT NULL DEFAULT false,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    INDEX `GameRecord_roomId_round_idx`(`roomId`, `round`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Circle` (
    `id` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `description` VARCHAR(191) NULL,
    `coverImage` VARCHAR(191) NULL,
    `memberCount` INTEGER NOT NULL DEFAULT 0,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    UNIQUE INDEX `Circle_name_key`(`name`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `CirclePost` (
    `id` VARCHAR(191) NOT NULL,
    `userId` VARCHAR(191) NOT NULL,
    `circleId` VARCHAR(191) NOT NULL,
    `content` VARCHAR(191) NOT NULL,
    `images` VARCHAR(191) NULL,
    `likes` INTEGER NOT NULL DEFAULT 0,
    `comments` INTEGER NOT NULL DEFAULT 0,
    `isTop` BOOLEAN NOT NULL DEFAULT false,
    `isDeleted` BOOLEAN NOT NULL DEFAULT false,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    INDEX `CirclePost_userId_createdAt_idx`(`userId`, `createdAt`),
    INDEX `CirclePost_circleId_createdAt_idx`(`circleId`, `createdAt`),
    INDEX `CirclePost_likes_createdAt_idx`(`likes`, `createdAt`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `CircleComment` (
    `id` VARCHAR(191) NOT NULL,
    `postId` VARCHAR(191) NOT NULL,
    `userId` VARCHAR(191) NOT NULL,
    `content` VARCHAR(191) NOT NULL,
    `parentId` VARCHAR(191) NULL,
    `likes` INTEGER NOT NULL DEFAULT 0,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    INDEX `CircleComment_postId_createdAt_idx`(`postId`, `createdAt`),
    INDEX `CircleComment_parentId_createdAt_idx`(`parentId`, `createdAt`),
    INDEX `CircleComment_userId_idx`(`userId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `SystemConfig` (
    `id` VARCHAR(191) NOT NULL,
    `configKey` VARCHAR(191) NOT NULL,
    `configValue` TEXT NOT NULL,
    `description` VARCHAR(191) NULL,
    `updatedAt` DATETIME(3) NOT NULL,

    UNIQUE INDEX `SystemConfig_configKey_key`(`configKey`),
    INDEX `SystemConfig_configKey_idx`(`configKey`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
