import 'package:app_mobile/features/announcements/domain/usecases/create_comment_usecase.dart';
import 'package:app_mobile/features/announcements/domain/usecases/delete_comment_usecase.dart';
import 'package:app_mobile/features/announcements/domain/usecases/get_comments_usecase.dart';
import 'package:app_mobile/features/announcements/presentation/bloc/comment_event.dart';
import 'package:app_mobile/features/announcements/presentation/bloc/comment_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final GetCommentsUseCase getCommentsUseCase;
  final CreateCommentUseCase createCommentUseCase;
  final DeleteCommentUseCase deleteCommentUseCase;

  CommentBloc({
    required this.getCommentsUseCase,
    required this.createCommentUseCase,
    required this.deleteCommentUseCase,
  }) : super(CommentInitial()) {
    on<FetchComments>(_onFetchComments);
    on<CreateCommentRequested>(_onCreateCommentRequested);
    on<DeleteCommentRequested>(_onDeleteCommentRequested);
  }

  Future<void> _onFetchComments(
    FetchComments event,
    Emitter<CommentState> emit,
  ) async {
    emit(CommentLoading());
    final result = await getCommentsUseCase(event.announcementId,
        forceRefresh: event.forceRefresh);
    result.fold(
      (failure) => emit(CommentError(failure.message)),
      (comments) => emit(CommentLoaded(comments)),
    );
  }

  Future<void> _onCreateCommentRequested(
    CreateCommentRequested event,
    Emitter<CommentState> emit,
  ) async {
    final current = state;
    if (current is CommentLoaded) {
      emit(CommentActionInProgress(current.comments));
    } else {
      emit(CommentLoading());
    }
    final result = await createCommentUseCase(
      announcementId: event.announcementId,
      content: event.content,
      authorId: event.authorId,
    );
    await result.fold(
      (failure) async => emit(CommentError(failure.message)),
      (_) async => add(FetchComments(event.announcementId)),
    );
  }

  Future<void> _onDeleteCommentRequested(
    DeleteCommentRequested event,
    Emitter<CommentState> emit,
  ) async {
    final current = state;
    if (current is CommentLoaded) {
      emit(CommentActionInProgress(current.comments));
    } else {
      emit(CommentLoading());
    }
    final result = await deleteCommentUseCase(event.commentId);
    await result.fold(
      (failure) async => emit(CommentError(failure.message)),
      (_) async => add(FetchComments(event.announcementId)),
    );
  }
}
