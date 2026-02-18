import 'package:job_finder/core/constants/api_enpoint.dart';
import 'package:job_finder/core/networks/dio_client.dart';
import 'package:job_finder/features/job_seeker/data/model/tip_model.dart';
import 'package:job_finder/features/job_seeker/domain/entities/tip_entity.dart';

abstract class TipServer {
  Future<List<TipEntity>> getTips();
  Future<TipEntity> getTipDetail(String id);
}

class TipServerImpl implements TipServer {
  final dio = setupAuthenticatedDio(ApiEnpoint.baseUrl);

  @override
  Future<List<TipEntity>> getTips() async {
    try {
      final response = await dio.get(ApiEnpoint.tips);
      final dynamic data = response.data['tips'] ?? response.data;

      if (data is List) {
        return data.map((e) => TipModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TipEntity> getTipDetail(String id) async {
    try {
      final response = await dio.get(ApiEnpoint.tipDetail(id));
      final dynamic data = response.data['tip'] ?? response.data;
      return TipModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
}
