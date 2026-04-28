import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../core/constants/api_constants.dart';

part 'user_api.g.dart';

@RestApi()
abstract class UserApi {
  factory UserApi(Dio dio, {String baseUrl}) = _UserApi;

  @POST(ApiConstants.login)
  Future<dynamic> login(@Body() Map<String, dynamic> data);

  @POST(ApiConstants.register)
  Future<dynamic> register(@Body() Map<String, dynamic> data);

  @GET(ApiConstants.userProfile)
  Future<dynamic> getProfile();

  @PUT(ApiConstants.userProfile)
  Future<dynamic> updateProfile(@Body() Map<String, dynamic> data);

  @POST(ApiConstants.friendRequest)
  Future<dynamic> sendFriendRequest(@Body() Map<String, dynamic> data);

  @PUT(ApiConstants.friendHandle)
  Future<dynamic> handleFriendRequest(@Body() Map<String, dynamic> data);

  @GET(ApiConstants.friendList)
  Future<dynamic> getFriendList();

  @POST(ApiConstants.logout)
  Future<dynamic> logout();

  @GET('/users/online/{userId}')
  Future<dynamic> getOnlineStatus(@Path('userId') String userId);
}
