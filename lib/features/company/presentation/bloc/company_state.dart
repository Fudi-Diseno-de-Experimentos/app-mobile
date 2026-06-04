import 'package:equatable/equatable.dart';
import '../../domain/entities/company_entity.dart';

abstract class CompanyState extends Equatable {
  const CompanyState();

  @override
  List<Object?> get props => [];
}

class CompanyInitial extends CompanyState {}

class CompanyLoading extends CompanyState {}

class CompanyLoadSuccess extends CompanyState {
  final CompanyEntity company;

  const CompanyLoadSuccess(this.company);

  @override
  List<Object?> get props => [company];
}

class CompanyCreateSuccess extends CompanyState {
  final CompanyEntity company;

  const CompanyCreateSuccess(this.company);

  @override
  List<Object?> get props => [company];
}

class CompanyUpdateSuccess extends CompanyState {
  final CompanyEntity company;

  const CompanyUpdateSuccess(this.company);

  @override
  List<Object?> get props => [company];
}

class CompanyFailure extends CompanyState {
  final String message;

  const CompanyFailure(this.message);

  @override
  List<Object?> get props => [message];
}
