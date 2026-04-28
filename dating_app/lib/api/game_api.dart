import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../core/constants/api_constants.dart';

part 'game_api.g.dart';

@RestApi()
abstract class GameApi {
  factory GameApi(Dio dio, {String baseUrl}) = _GameApi;

  @GET(ApiConstants.gameRooms)
  Future<dynamic> getRooms(
    @Query('page') int page,
    @Query('limit') int limit,
    @Query('status') String? status,
  );

  @POST(ApiConstants.gameCreate)
  Future<dynamic> createRoom(@Body() Map<String, dynamic> data);

  @GET('/game/rooms/{roomId}')
  Future<dynamic> getRoomDetail(@Path('roomId') String roomId);

  @POST('/game/rooms/{roomId}/join')
  Future<dynamic> joinRoom(@Path('roomId') String roomId);

  @POST('/game/rooms/{roomId}/leave')
  Future<dynamic> leaveRoom(@Path('roomId') String roomId);

  @POST('/game/rooms/{roomId}/start')
  Future<dynamic> startGame(@Path('roomId') String roomId);

  @POST(ApiConstants.gameBrushSync)
  Future<dynamic> syncBrush(@Body() Map<String, dynamic> data);

  @PUT('/game/rooms/{roomId}/round/start')
  Future<dynamic> startRound(@Path('roomId') String roomId);

  @PUT('/game/rooms/{roomId}/round/end')
  Future<dynamic> endRound(@Path('roomId') String roomId);

  @DELETE('/game/rooms/{roomId}/destroy')
  Future<dynamic> destroyRoom(@Path('roomId') String roomId);
}
