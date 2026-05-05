import 'package:flutter_bloc/flutter_bloc.dart';
import 'announcement_event.dart';
import 'announcement_state.dart';

class AnnouncementBloc extends Bloc<AnnouncementEvent, AnnouncementState> {
  AnnouncementBloc() : super(InitialAnnouncementState()) {
    on<AnnouncementEvent>((event, emit) { });
  }
}

class InitialAnnouncementState extends AnnouncementState {}
