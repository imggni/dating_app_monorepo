import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../core/constants/api_constants.dart';

part 'circle_api.g.dart';

@RestApi()
abstract class CircleApi {
  factory CircleApi(Dio dio, {String baseUrl}) = _CircleApi;

  @GET(ApiConstants.circleList)
  Future<dynamic> getCircleList(
    @Query('page') int page,
    @Query('limit') int limit,
  );

  @GET(ApiConstants.circlePostList)
  Future<dynamic> getPostList(
    @Query('circleId') String circleId,
    @Query('page') int page,
    @Query('limit') int limit,
  );

  @GET(ApiConstants.circlePostFilter)
  Future<dynamic> filterPosts(
    @Query('keyword') String keyword,
    @Query('tags') String tags,
    @Query('page') int page,
    @Query('limit') int limit,
  );

  @GET('/circle/posts/{postId}')
  Future<dynamic> getPostDetail(@Path('postId') String postId);

  @POST(ApiConstants.circlePosts)
  Future<dynamic> publishPost(@Body() Map<String, dynamic> data);

  @POST('/circle/posts/{postId}/like')
  Future<dynamic> likePost(@Path('postId') String postId);

  @POST('/circle/posts/{postId}/unlike')
  Future<dynamic> unlikePost(@Path('postId') String postId);

  @GET('/circle/posts/{postId}/comments')
  Future<dynamic> getComments(
    @Path('postId') String postId,
    @Query('page') int page,
    @Query('limit') int limit,
  );

  @POST('/circle/posts/{postId}/comments')
  Future<dynamic> addComment(
    @Path('postId') String postId,
    @Body() Map<String, dynamic> data,
  );

  @POST(ApiConstants.circleCommentLike)
  Future<dynamic> likeComment(@Body() Map<String, dynamic> data);
}
