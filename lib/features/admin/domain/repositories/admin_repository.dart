import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../participants/domain/entities/participant_entity.dart';
import '../entities/admin_stats_entity.dart';

abstract class AdminRepository {
  Future<Either<Failure, bool>> loginAdmin(String password);

  Future<Either<Failure, void>> logoutAdmin();

  Future<Either<Failure, AdminStatsEntity>> getStats();

  Future<Either<Failure, List<ParticipantEntity>>> getAllParticipants();

  Future<Either<Failure, ParticipantEntity>> updateParticipant(
    ParticipantEntity participant,
  );

  Future<Either<Failure, void>> deletedParticipant(int id);

  Future<Either<Failure, String>> exportData();
}
