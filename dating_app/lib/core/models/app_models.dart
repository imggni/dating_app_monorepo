class UserProfile {
  const UserProfile({
    required this.id,
    required this.nickname,
    required this.bio,
    required this.tags,
    this.phone = '',
    this.avatar = '',
    this.gender = '',
    this.age,
    this.gameScore = 0,
    this.onlineStatus = false,
  });

  final String id;
  final String nickname;
  final String bio;
  final List<String> tags;
  final String phone;
  final String avatar;
  final String gender;
  final int? age;
  final int gameScore;
  final bool onlineStatus;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      nickname: json['nickname']?.toString() ?? '未命名',
      avatar: json['avatar']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      age: (json['age'] as num?)?.toInt(),
      bio: json['bio']?.toString() ?? '',
      tags: parseTags(json['tags']),
      gameScore: (json['gameScore'] as num?)?.toInt() ?? 0,
      onlineStatus: json['onlineStatus'] == true,
    );
  }

  static List<String> parseTags(dynamic rawTags) {
    if (rawTags is List) {
      return rawTags
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (rawTags is String && rawTags.isNotEmpty) {
      return rawTags
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return const [];
  }
}

class FriendItem {
  const FriendItem({
    required this.id,
    required this.nickname,
    this.avatar = '',
    this.gender = '',
    this.online = false,
  });

  final String id;
  final String nickname;
  final String avatar;
  final String gender;
  final bool online;

  factory FriendItem.fromJson(Map<String, dynamic> json) {
    return FriendItem(
      id: json['id']?.toString() ?? '',
      nickname: json['nickname']?.toString() ?? '好友',
      avatar: json['avatar']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      online: json['online'] == true || json['onlineStatus'] == true,
    );
  }
}

class ConversationItem {
  const ConversationItem({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.timeLabel,
    required this.unreadCount,
  });

  final String id;
  final String title;
  final String lastMessage;
  final String timeLabel;
  final int unreadCount;
}

class MessageItem {
  const MessageItem({
    required this.id,
    required this.text,
    required this.isMine,
  });

  final String id;
  final String text;
  final bool isMine;
}

class CirclePost {
  const CirclePost({
    required this.id,
    required this.author,
    required this.topic,
    required this.content,
    required this.likes,
    required this.comments,
    this.circleId = '',
    this.images = const [],
    this.isLiked = false,
    this.createdAt = '',
  });

  final String id;
  final String author;
  final String topic;
  final String content;
  final int likes;
  final int comments;
  final String circleId;
  final List<String> images;
  final bool isLiked;
  final String createdAt;

  factory CirclePost.fromJson(
    Map<String, dynamic> json, {
    String fallbackTopic = '分享',
  }) {
    final images =
        json['images'] is List
            ? (json['images'] as List).map((e) => e.toString()).toList()
            : <String>[];
    return CirclePost(
      id: json['id']?.toString() ?? '',
      author:
          json['nickname']?.toString() ??
          json['user']?['nickname']?.toString() ??
          '未知用户',
      topic:
          json['circleName']?.toString() ??
          json['circle']?['name']?.toString() ??
          fallbackTopic,
      circleId: json['circleId']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      images: images,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      comments: (json['comments'] as num?)?.toInt() ?? 0,
      isLiked: json['isLiked'] == true,
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

class CircleItem {
  const CircleItem({
    required this.id,
    required this.name,
    required this.description,
    this.coverImage = '',
    this.memberCount = 0,
  });

  final String id;
  final String name;
  final String description;
  final String coverImage;
  final int memberCount;

  factory CircleItem.fromJson(Map<String, dynamic> json) {
    return CircleItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '兴趣圈子',
      description: json['description']?.toString() ?? '',
      coverImage: json['coverImage']?.toString() ?? '',
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class CircleComment {
  const CircleComment({
    required this.id,
    required this.author,
    required this.content,
    required this.likes,
    this.createdAt = '',
  });

  final String id;
  final String author;
  final String content;
  final int likes;
  final String createdAt;

  factory CircleComment.fromJson(Map<String, dynamic> json) {
    return CircleComment(
      id: json['id']?.toString() ?? '',
      author: json['nickname']?.toString() ?? '用户',
      content: json['content']?.toString() ?? '',
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

class LetterItem {
  const LetterItem({
    required this.id,
    required this.title,
    required this.preview,
    required this.arrivalLabel,
    required this.isOpened,
    this.senderId = '',
    this.senderName = '',
    this.isAnonymous = false,
  });

  final String id;
  final String title;
  final String preview;
  final String arrivalLabel;
  final bool isOpened;
  final String senderId;
  final String senderName;
  final bool isAnonymous;

  factory LetterItem.fromJson(Map<String, dynamic> json) {
    return LetterItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '匿名信件',
      preview: json['content']?.toString() ?? '',
      arrivalLabel:
          json['arrivalLabel']?.toString() ??
          json['sendTime']?.toString() ??
          '已送达',
      isOpened: json['isOpened'] == true,
      senderId: json['senderId']?.toString() ?? '',
      senderName:
          json['isAnonymous'] == true
              ? '匿名来信'
              : (json['nickname']?.toString() ?? '来信'),
      isAnonymous: json['isAnonymous'] == true,
    );
  }
}

class GameRoom {
  const GameRoom({
    required this.id,
    required this.name,
    required this.players,
    required this.status,
    this.roomCode = '',
    this.maxPlayers = 4,
    this.hostNickname = '',
  });

  final String id;
  final String name;
  final int players;
  final String status;
  final String roomCode;
  final int maxPlayers;
  final String hostNickname;

  factory GameRoom.fromJson(Map<String, dynamic> json) {
    return GameRoom(
      id: json['id']?.toString() ?? '',
      name: json['roomName']?.toString() ?? json['name']?.toString() ?? '游戏房间',
      roomCode: json['roomCode']?.toString() ?? '',
      players:
          (json['currentPlayers'] as num?)?.toInt() ??
          (json['players'] as List?)?.length ??
          0,
      maxPlayers: (json['maxPlayers'] as num?)?.toInt() ?? 4,
      status: json['status']?.toString() ?? 'waiting',
      hostNickname: json['hostNickname']?.toString() ?? '',
    );
  }
}
