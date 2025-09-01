import '../../../../shared/data/datasources/api_client.dart';
import '../../../participants/data/models/participant_model.dart';
import '../models/admin_stats_model.dart';

abstract class AdminRemoteDatasource {
  Future<bool> loginAdmin(String password);

  Future<AdminStatsModel> getStats();

  Future<List<ParticipantModel>> getAllParticipants();

  Future<ParticipantModel> updateParticipant(ParticipantModel participant);

  Future<void> deletedParticipant(int id);

  Future<String> exportData();
}

class AdminRemoteDatasourceImpl implements AdminRemoteDatasource {
  final ApiClient apiClient;

  AdminRemoteDatasourceImpl({required this.apiClient});

  @override
  Future<bool> loginAdmin(String password) async {
    final response = await apiClient.post(
      '/admin/login',
      data: {'password': password},
    );

    return response.data['success'] ?? false;
  }

  @override
  Future<AdminStatsModel> getStats() async {
    final response = await apiClient.get('/admin/stats');
    return AdminStatsModel.fromJson(response.data);
  }

  @override
  Future<List<ParticipantModel>> getAllParticipants() async {
    final response = await apiClient.get('/admin/participants');
    final List<dynamic> data = response.data;
    return data.map((json) => ParticipantModel.fromJson(json)).toList();
  }

  @override
  Future<ParticipantModel> updateParticipant(
    ParticipantModel participant,
  ) async {
    final response = await apiClient.put(
      '/admin/participants/${participant.id}',
      data: participant.toJson(),
    );

    return ParticipantModel.fromJson(response.data);
  }

  @override
  Future<void> deletedParticipant(int id) async {
    await apiClient.delete('/admin/participants/$id');
  }

  @override
  Future<String> exportData() async {
    final response = await apiClient.get('/admin/export');
    return response.data['url'];
  }
}
