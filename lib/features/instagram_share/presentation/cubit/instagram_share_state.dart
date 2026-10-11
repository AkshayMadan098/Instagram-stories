import 'package:equatable/equatable.dart';

abstract class InstagramShareState extends Equatable {
  const InstagramShareState();

  @override
  List<Object?> get props => [];
}

class InstagramShareInitial extends InstagramShareState {}

class InstagramShareLoading extends InstagramShareState {
  final String statusMessage;
  const InstagramShareLoading({this.statusMessage = 'Preparing your story...'});

  @override
  List<Object?> get props => [statusMessage];
}

class InstagramShareSuccess extends InstagramShareState {
  final bool captionCopied;
  final String? caption;
  const InstagramShareSuccess({this.captionCopied = false, this.caption});

  @override
  List<Object?> get props => [captionCopied, caption];
}

class InstagramShareNotInstalled extends InstagramShareState {
  final String imagePath;
  final String? caption;
  const InstagramShareNotInstalled({required this.imagePath, this.caption});

  @override
  List<Object?> get props => [imagePath, caption];
}

class InstagramShareSimulated extends InstagramShareState {
  final String imagePath;
  final String? caption;
  const InstagramShareSimulated({required this.imagePath, this.caption});

  @override
  List<Object?> get props => [imagePath, caption];
}

class InstagramShareFailure extends InstagramShareState {
  final String message;
  const InstagramShareFailure(this.message);

  @override
  List<Object?> get props => [message];
}
