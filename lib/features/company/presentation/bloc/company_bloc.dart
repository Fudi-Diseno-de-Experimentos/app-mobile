import 'package:flutter_bloc/flutter_bloc.dart';
import 'company_event.dart';
import 'company_state.dart';

class CompanyBloc extends Bloc<CompanyEvent, CompanyState> {
  CompanyBloc() : super(InitialCompanyState()) {
    on<CompanyEvent>((event, emit) { });
  }
}

class InitialCompanyState extends CompanyState {}
