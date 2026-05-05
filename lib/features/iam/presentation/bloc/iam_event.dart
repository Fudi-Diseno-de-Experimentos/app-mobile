import 'package:equatable/equatable.dart';

abstract class IamEvent extends Equatable {
  const IamEvent();

  @override
  List<Object> get props => [];
}

class SignInSubmitted extends IamEvent {
  final String username;
  final String password;

  const SignInSubmitted({required this.username, required this.password});

  @override
  List<Object> get props => [username, password];
}

class SignUpSubmitted extends IamEvent {
  final String username;
  final String password;
  final String name;
  final String lastname;
  final String email;

  const SignUpSubmitted({
    required this.username,
    required this.password,
    required this.name,
    required this.lastname,
    required this.email,
  });

  @override
  List<Object> get props => [username, password, name, lastname, email];
}

class JoinCompanySubmitted extends IamEvent {
  final String joinCode;

  const JoinCompanySubmitted({required this.joinCode});

  @override
  List<Object> get props => [joinCode];
}
