import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/admin_stats_entity.dart';
import '../repositories/admin_repository.dart';

class GetAdminStatsUsecase {
  final AdminRepository repository;

  GetAdminStatsUsecase(this.repository);

  Future<Either<Failure, AdminStatsEntity>> call() async {
    return await repository.getStats();
  }
}
