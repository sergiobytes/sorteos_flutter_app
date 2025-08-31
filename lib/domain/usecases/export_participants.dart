import '../repositories/participant_repository.dart';

class ExportParticipants {
  final ParticipantRepository repository;
  ExportParticipants(this.repository);

  Future<void> call() async {
    return repository.purge();
  }
}
