import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../participants/domain/entities/participant_entity.dart';
import '../../../participants/data/models/participant_model.dart';
import '../../domain/entities/admin_stats_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_local_datasource.dart';
import '../datasources/admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDatasource remoteDatasource;
  final AdminLocalDatasource localDatasource;

  AdminRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  @override
  Future<Either<Failure, bool>> loginAdmin(String password) async {
    try {
      final success = await remoteDatasource.loginAdmin(password);
      if (success) await localDatasource.setAdminLoggedIn(true);

      return Right(success);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logoutAdmin() async {
    try {
      await localDatasource.clearAdminSession();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminStatsEntity>> getStats() async {
    try {
      final stats = await remoteDatasource.getStats();
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ParticipantEntity>>> getAllParticipants() async {
    try {
      final participants = await remoteDatasource.getAllParticipants();
      return Right(participants);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ParticipantEntity>> updateParticipant(
    ParticipantEntity participant,
  ) async {
    try {
      final participantModel = ParticipantModel(
        id: participant.id,
        nombre: participant.nombre,
        telefono: participant.telefono,
        cedula: participant.cedula,
        boletos: participant.boletos,
        pagado: participant.pagado,
        comprobante: participant.comprobante,
        fechaCreacion: participant.fechaCreacion,
      );
      final updated = await remoteDatasource.updateParticipant(
        participantModel,
      );
      return Right(updated);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletedParticipant(int id) async {
    try {
      await remoteDatasource.deletedParticipant(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> exportData() async {
    try {
      final url = await remoteDatasource.exportData();
      return Right(url);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
