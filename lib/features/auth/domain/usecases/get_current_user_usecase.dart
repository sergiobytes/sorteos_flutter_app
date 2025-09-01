import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';
import '../entities/user_entity.dart';

class GetCurrentUserUsecase {
  final AuthRepository repository;

  GetCurrentUserUsecase(this.repository);

  Future<Either<Failure, UserEntity?>> call() async {
    return repository.getCurrentUser();
  }
}
