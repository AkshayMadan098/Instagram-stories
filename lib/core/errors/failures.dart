import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class CameraFailure extends Failure {
  const CameraFailure(super.message);
}

class CanvasFailure extends Failure {
  const CanvasFailure(super.message);
}

class InstagramShareFailure extends Failure {
  const InstagramShareFailure(super.message);
}

class StorageFailure extends Failure {
  const StorageFailure(super.message);
}
