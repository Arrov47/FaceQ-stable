import 'package:dartz/dartz.dart';
import 'package:faceq/config/errors/failure.dart';
import 'package:faceq/features/auth/domain/entities/network_state.dart';

abstract class UseCase <Type,Params>{
  Future<Either<Failure,Type>> call(Params params);
}