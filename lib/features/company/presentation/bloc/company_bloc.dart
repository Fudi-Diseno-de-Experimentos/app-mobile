import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_company_usecase.dart';
import '../../domain/usecases/update_company_usecase.dart';
import '../../domain/usecases/get_company_by_user_id_usecase.dart';
import 'company_event.dart';
import 'company_state.dart';

class CompanyBloc extends Bloc<CompanyEvent, CompanyState> {
  final CreateCompanyUseCase createCompanyUseCase;
  final UpdateCompanyUseCase updateCompanyUseCase;
  final GetCompanyByUserIdUseCase getCompanyByUserIdUseCase;

  CompanyBloc({
    required this.createCompanyUseCase,
    required this.updateCompanyUseCase,
    required this.getCompanyByUserIdUseCase,
  }) : super(CompanyInitial()) {
    on<CreateCompanyRequested>(_onCreateCompanyRequested);
    on<UpdateCompanyRequested>(_onUpdateCompanyRequested);
    on<GetCompanyRequested>(_onGetCompanyRequested);
  }

  Future<void> _onCreateCompanyRequested(
    CreateCompanyRequested event,
    Emitter<CompanyState> emit,
  ) async {
    emit(CompanyLoading());
    final result = await createCompanyUseCase(
      ruc: event.ruc,
      nombre: event.nombre,
      iconUrl: event.iconUrl,
      isActive: event.isActive,
      userId: event.userId,
    );
    result.fold(
      (failure) => emit(CompanyFailure(failure.message)),
      (company) => emit(CompanyCreateSuccess(company)),
    );
  }

  Future<void> _onUpdateCompanyRequested(
    UpdateCompanyRequested event,
    Emitter<CompanyState> emit,
  ) async {
    emit(CompanyLoading());
    final result = await updateCompanyUseCase(
      id: event.id,
      ruc: event.ruc,
      nombre: event.nombre,
      iconUrl: event.iconUrl,
      isActive: event.isActive,
    );
    result.fold(
      (failure) => emit(CompanyFailure(failure.message)),
      (company) => emit(CompanyUpdateSuccess(company)),
    );
  }

  Future<void> _onGetCompanyRequested(
    GetCompanyRequested event,
    Emitter<CompanyState> emit,
  ) async {
    emit(CompanyLoading());
    final result = await getCompanyByUserIdUseCase(event.userId);
    result.fold(
      (failure) => emit(CompanyFailure(failure.message)),
      (company) => emit(CompanyLoadSuccess(company)),
    );
  }
}
