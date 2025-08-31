import '../entities/participant.dart';

abstract class ParticipantRepository {
  Future<void> register(Participant participant);
  Future<List<Participant>> list();
  Future<void> purge();
  Future<void> export();
}
