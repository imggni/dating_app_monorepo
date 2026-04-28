import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../core/constants/api_constants.dart';

part 'slow_chat_api.g.dart';

@RestApi()
abstract class SlowChatApi {
  factory SlowChatApi(Dio dio, {String baseUrl}) = _SlowChatApi;

  @GET(ApiConstants.slowChatRooms)
  Future<dynamic> getRooms(@Query('page') int page, @Query('limit') int limit);

  @POST(ApiConstants.slowChatRooms)
  Future<dynamic> createRoom(@Body() Map<String, dynamic> data);

  @GET('/slow-chat/rooms/{roomId}')
  Future<dynamic> getRoomDetail(@Path('roomId') String roomId);

  @POST('/slow-chat/rooms/{roomId}/join')
  Future<dynamic> joinRoom(@Path('roomId') String roomId);

  @POST('/slow-chat/rooms/{roomId}/leave')
  Future<dynamic> leaveRoom(@Path('roomId') String roomId);

  @GET('/slow-chat/rooms/{roomId}/messages')
  Future<dynamic> getRoomMessages(@Path('roomId') String roomId);

  @POST(ApiConstants.slowChatSend)
  Future<dynamic> sendLetter(@Body() Map<String, dynamic> data);

  @PUT('/slow-chat/messages/{messageId}/open')
  Future<dynamic> openLetter(@Path('messageId') String messageId);

  @DELETE('/slow-chat/messages/{messageId}')
  Future<dynamic> deleteLetter(@Path('messageId') String messageId);

  @PUT('/slow-chat/messages/{messageId}/anonymous')
  Future<dynamic> setAnonymous(
    @Path('messageId') String messageId,
    @Body() Map<String, dynamic> data,
  );
}
