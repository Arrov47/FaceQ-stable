abstract class Failure{
  final String message;
  Failure({required this.message});
}
class NetworkFailure extends Failure{
  NetworkFailure({required super.message});

}
class InvalidTokenFailure extends Failure{
  InvalidTokenFailure({required super.message});
}