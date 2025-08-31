import '../entities/participant.dart';
import '../repositories/participant_repository.dart';

class ListParticipants {
  final ParticipantRepository repository;

  ListParticipants(this.repository);

  Future<List<Participant>> call() async {
    return await repository.list();
  }
}
