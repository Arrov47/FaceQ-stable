import 'package:dartz/dartz.dart';
import 'package:faceq/config/errors/failure.dart';
import 'package:faceq/features/auth/data/data_sources/remote.dart';
import 'package:faceq/features/auth/domain/entities/network_state.dart';
import 'package:faceq/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final RemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({required RemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, String>> checkPassword(String password) async{
    return await _remoteDataSource.checkPassword(password);
  }
}
