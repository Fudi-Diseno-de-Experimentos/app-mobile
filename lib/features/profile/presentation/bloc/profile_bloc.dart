import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(InitialProfileState()) {
    on<ProfileEvent>((event, emit) { });
  }
}

class InitialProfileState extends ProfileState {}
