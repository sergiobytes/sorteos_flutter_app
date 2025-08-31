import '../../domain/entities/participant.dart';
import '../../domain/repositories/participant_repository.dart';
import 'api_client.dart';
import 'dart:convert';

class ApiParticipantRepository implements ParticipantRepository {
  final ApiClient client;
  ApiParticipantRepository(this.client);

  @override
  Future<void> register(Participant participant) async {
    await client.post(
      '/participants',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(participant.toJson()),
    );
  }

  @override
  Future<List<Participant>> list() async {
    final response = await client.get('/participants');
    final List data = jsonDecode(response.body);
    return data.map((e) => Participant.fromJson(e)).toList();
  }

  @override
  Future<void> purge() async {
    await client.post('/admin/purge');
  }

  @override
  Future<void> export() async {
    await client.get('/admin/export');
  }
}
