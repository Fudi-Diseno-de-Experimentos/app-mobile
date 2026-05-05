import 'package:equatable/equatable.dart';

abstract class IamState extends Equatable {
  const IamState();

  @override
  List<Object> get props => [];
}

class IamInitial extends IamState {}

class IamLoading extends IamState {}

class IamSignInSuccess extends IamState {}

class IamSignUpSuccess extends IamState {}

class IamJoinCompanySuccess extends IamState {}

class IamError extends IamState {
  final String message;

  const IamError(this.message);

  @override
  List<Object> get props => [message];
}
