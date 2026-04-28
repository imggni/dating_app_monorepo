import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../core/constants/api_constants.dart';

part 'common_api.g.dart';

@RestApi()
abstract class CommonApi {
  factory CommonApi(Dio dio, {String baseUrl}) = _CommonApi;

  @POST(ApiConstants.commonUpload)
  Future<dynamic> uploadFile(@Body() FormData data);

  @POST(ApiConstants.commonTokenRefresh)
  Future<dynamic> refreshToken(@Body() Map<String, dynamic> data);

  @POST(ApiConstants.commonSensitiveFilter)
  Future<dynamic> filterSensitiveContent(@Body() Map<String, dynamic> data);

  @GET(ApiConstants.commonRegions)
  Future<dynamic> getRegions(
    @Query('type') String? type,
    @Query('parentCode') String? parentCode,
  );

  @GET('/common/regions/{code}')
  Future<dynamic> getRegionByCode(@Path('code') String code);

  @GET(ApiConstants.commonDictionaries)
  Future<dynamic> getDictionaries(@Query('type') String? type);

  @GET(ApiConstants.commonConfigs)
  Future<dynamic> getConfigs();

  @GET(ApiConstants.commonOssToken)
  Future<dynamic> getOssToken();
}
