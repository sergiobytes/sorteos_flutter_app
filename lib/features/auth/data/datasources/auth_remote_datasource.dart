import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<UserModel?> getCurrentUser();

  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final FirebaseAuth firebaseAuth;

  AuthRemoteDatasourceImpl({required this.firebaseAuth});

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;

    if (user != null) {
      return UserModel(uid: user.uid, email: user.email ?? '', isAdmin: false);
    }

    return null;
  }

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return UserModel(
      uid: credential.user!.uid,
      email: credential.user!.email ?? '',
      isAdmin: false,
    );
  }

  @override
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }
}
