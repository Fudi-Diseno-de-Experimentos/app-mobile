import 'package:flutter_bloc/flutter_bloc.dart';
import 'iam_event.dart';
import 'iam_state.dart';

class IamBloc extends Bloc<IamEvent, IamState> {
  IamBloc() : super(InitialIamState()) {
    on<IamEvent>((event, emit) { });
  }
}

class InitialIamState extends IamState {}
