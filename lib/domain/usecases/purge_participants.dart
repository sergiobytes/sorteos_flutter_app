import '../repositories/participant_repository.dart';

class PurgeParticipants {
  final ParticipantRepository repository;
  PurgeParticipants(this.repository);

  Future<void> call() {
    return repository.purge();
  }
}
