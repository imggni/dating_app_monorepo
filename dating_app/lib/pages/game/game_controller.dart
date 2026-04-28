import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io_client;
import '../../core/models/app_models.dart';
import '../../core/utils/toast_util.dart';
import '../../api/api_client.dart';
import '../../api/game_api.dart';
import '../../core/config/app_config.dart';

class GameController extends GetxController {
  late io_client.Socket socket;

  final rooms = <GameRoom>[].obs;
  final selectedRoom = Rxn<GameRoom>();
  final isLoading = false.obs;

  final strokes = <List<Offset>>[].obs;
  final currentStroke = <Offset>[].obs;
  final brushColor = const Color(0xFF7C4DFF).obs;
  final strokeWidth = 4.0.obs;
  final round = 1.obs;
  final secondsLeft = 60.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRooms();
    _initSocket();
  }

  Future<void> fetchRooms() async {
    isLoading.value = true;
    try {
      final response = await GameApi(ApiClient().dio).getRooms(1, 20, null);

      final data = response['data'];
      if (data != null) {
        final list =
            (data['rooms'] as List?) ?? (data['items'] as List?) ?? const [];
        rooms.value =
            list
                .map(
                  (e) => GameRoom.fromJson(Map<String, dynamic>.from(e as Map)),
                )
                .where((e) => e.id.isNotEmpty)
                .toList();
      }
    } catch (e) {
      // ApiClient handles DioException, only handle others
      if (e is! Exception) {
        ToastUtil.error('获取房间列表失败: 系统异常');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _initSocket() {
    // 假设后端运行在 baseUrl 的相同 domain 端口
    final socketUrl = AppConfig.baseUrl.replaceAll('/api/', '');
    socket = io_client.io(
      socketUrl,
      io_client.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      if (kDebugMode) {
        debugPrint('Connected to Game Socket');
      }
      final room = selectedRoom.value;
      if (room != null) socket.emit('joinRoom', room.id);
    });

    socket.on('syncStroke', (data) {
      // Decode binary/json to offset
      if (data is List) {
        final decodedStroke =
            data
                .map(
                  (point) =>
                      Offset(point['dx'].toDouble(), point['dy'].toDouble()),
                )
                .toList();
        strokes.add(decodedStroke);
      }
    });

    socket.on('boardCleared', (_) {
      strokes.clear();
      currentStroke.clear();
    });
  }

  @override
  void onClose() {
    socket.dispose();
    super.onClose();
  }

  void startStroke(Offset point) {
    currentStroke
      ..clear()
      ..add(point);
  }

  void appendStroke(Offset point) {
    currentStroke.add(point);
    currentStroke.refresh();
  }

  void endStroke() {
    if (currentStroke.isEmpty) return;
    final room = selectedRoom.value;
    if (room == null) {
      ToastUtil.show('请先加入房间');
      currentStroke.clear();
      return;
    }

    final finalStroke = List<Offset>.from(currentStroke);
    strokes.add(finalStroke);
    currentStroke.clear();

    // Emit stroke to server
    socket.emit('drawStroke', {
      'roomId': room.id,
      'stroke': finalStroke.map((p) => {'dx': p.dx, 'dy': p.dy}).toList(),
    });
    GameApi(ApiClient().dio).syncBrush({
      'roomId': room.id,
      'round': round.value,
      'content': finalStroke.map((p) => {'dx': p.dx, 'dy': p.dy}).toList(),
    });
  }

  void clearBoard() {
    strokes.clear();
    currentStroke.clear();
    final room = selectedRoom.value;
    if (room != null) socket.emit('clearBoard', room.id);
  }

  void undoStroke() {
    if (strokes.isNotEmpty) strokes.removeLast();
  }

  Future<void> createRoom(String name) async {
    if (name.trim().isEmpty) {
      ToastUtil.show('请输入房间名称');
      return;
    }
    try {
      await GameApi(ApiClient().dio).createRoom({
        'name': name.trim(),
        'maxPlayers': 4,
        'gameType': 'draw_guess',
      });
      ToastUtil.success('房间创建成功');
      await fetchRooms();
    } catch (e) {
      if (e is! Exception) ToastUtil.error('创建房间失败: 系统异常');
    }
  }

  Future<void> joinRoom(GameRoom room) async {
    try {
      await GameApi(ApiClient().dio).joinRoom(room.id);
      selectedRoom.value = room;
      strokes.clear();
      socket.emit('joinRoom', room.id);
      ToastUtil.success('已加入房间');
      await fetchRooms();
    } catch (e) {
      if (e is! Exception) ToastUtil.error('加入房间失败: 系统异常');
    }
  }

  Future<void> leaveRoom() async {
    final room = selectedRoom.value;
    if (room == null) return;
    try {
      await GameApi(ApiClient().dio).leaveRoom(room.id);
      socket.emit('leaveRoom', room.id);
      selectedRoom.value = null;
      strokes.clear();
      await fetchRooms();
    } catch (e) {
      if (e is! Exception) ToastUtil.error('离开房间失败: 系统异常');
    }
  }

  Future<void> startGame() async {
    final room = selectedRoom.value;
    if (room == null) {
      ToastUtil.show('请先加入房间');
      return;
    }
    try {
      await GameApi(ApiClient().dio).startGame(room.id);
      round.value++;
      secondsLeft.value = 60;
      ToastUtil.success('游戏开始');
      await fetchRooms();
    } catch (e) {
      if (e is! Exception) ToastUtil.error('开始游戏失败: 系统异常');
    }
  }

  Future<void> startRound() async {
    final room = selectedRoom.value;
    if (room == null) return;
    await GameApi(ApiClient().dio).startRound(room.id);
    round.value++;
    secondsLeft.value = 60;
  }

  Future<void> endRound() async {
    final room = selectedRoom.value;
    if (room == null) return;
    await GameApi(ApiClient().dio).endRound(room.id);
    clearBoard();
  }
}
