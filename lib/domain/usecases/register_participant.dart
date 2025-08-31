import '../entities/participant.dart';
import '../repositories/participant_repository.dart';

class RegisterParticipant {
  final ParticipantRepository repository;
  RegisterParticipant(this.repository);

  Future<void> call(Participant participant) {
    return repository.register(participant);
  }
}
