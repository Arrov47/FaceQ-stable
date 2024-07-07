import 'package:dartz/dartz.dart';
import 'package:faceq/config/errors/failure.dart';
import 'package:faceq/features/auth/domain/entities/network_state.dart';

abstract interface class AuthRepository {
  Future<Either<Failure,String>> checkPassword(String password);
}