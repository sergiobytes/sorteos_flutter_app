import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;
  final AuthLocalDatasource localDatasource;

  AuthRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await remoteDatasource.getCurrentUser();
      if (user != null) {
        final isAdmin = await localDatasource.isAdmin();
        final userWithAdmin = UserModel(
          uid: user.uid,
          email: user.email,
          isAdmin: isAdmin,
        );
        return Right(userWithAdmin);
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDatasource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await localDatasource.setAdminStatus(false);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDatasource.signOut();
      await localDatasource.clearAdminStatus();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isAdmin() async {
    try {
      final isAdmin = await localDatasource.isAdmin();
      return Right(isAdmin);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
