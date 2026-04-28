import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../core/constants/api_constants.dart';

part 'im_api.g.dart';

@RestApi()
abstract class ImApi {
  factory ImApi(Dio dio, {String baseUrl}) = _ImApi;

  @GET(ApiConstants.imUserSig)
  Future<dynamic> getUserSig();

  @GET(ApiConstants.imUnreadCount)
  Future<dynamic> getUnreadCount();

  @GET(ApiConstants.imConversations)
  Future<dynamic> getConversations();

  @GET(ApiConstants.imMessages)
  Future<dynamic> getMessages(
    @Query('conversationId') String conversationId,
    @Query('page') int page,
    @Query('limit') int limit,
  );

  @POST(ApiConstants.imSend)
  Future<dynamic> sendMessage(@Body() Map<String, dynamic> data);

  @PUT('/im/messages/{messageId}/read')
  Future<dynamic> markAsRead(@Path('messageId') String messageId);

  @PUT('/im/messages/{messageId}/recall')
  Future<dynamic> recallMessage(@Path('messageId') String messageId);

  @POST('/im/group/create')
  Future<dynamic> createGroup(@Body() Map<String, dynamic> data);

  @PUT('/im/group/member/add')
  Future<dynamic> addGroupMember(@Body() Map<String, dynamic> data);

  @PUT('/im/group/member/remove')
  Future<dynamic> removeGroupMember(@Body() Map<String, dynamic> data);

  @GET('/im/group/{groupId}/messages')
  Future<dynamic> getGroupMessages(
    @Path('groupId') String groupId,
    @Query('page') int page,
    @Query('limit') int limit,
  );

  @POST('/im/group/{groupId}/send')
  Future<dynamic> sendGroupMessage(
    @Path('groupId') String groupId,
    @Body() Map<String, dynamic> data,
  );
}
