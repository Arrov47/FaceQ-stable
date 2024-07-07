import 'package:dartz/dartz.dart';
import 'package:faceq/config/errors/failure.dart';
import 'package:faceq/config/usecase/usecase.dart';
import 'package:faceq/features/auth/domain/entities/network_state.dart';
import 'package:faceq/features/auth/domain/repository/auth_repository.dart';

class CheckPasswordUseCase extends UseCase<String,CheckPasswordParams>{
  final AuthRepository _authRepository;

  CheckPasswordUseCase({required AuthRepository authRepository}) : _authRepository = authRepository;

  @override
  Future<Either<Failure, String>> call(CheckPasswordParams params) async{
    return await _authRepository.checkPassword(params.password);
  }
}


class CheckPasswordParams {
  final String password;
  CheckPasswordParams({required this.password});
}