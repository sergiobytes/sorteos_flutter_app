import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/admin_repository.dart';

class LoginAdminUsecase {
  final AdminRepository repository;

  LoginAdminUsecase(this.repository);

  Future<Either<Failure, bool>> call(String password) async {
    return await repository.loginAdmin(password);
  }
}
