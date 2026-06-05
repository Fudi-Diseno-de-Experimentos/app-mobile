import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/announcements/domain/entities/comment_entity.dart';
import 'package:app_mobile/features/announcements/presentation/bloc/comment_bloc.dart';
import 'package:app_mobile/features/announcements/presentation/bloc/comment_event.dart';
import 'package:app_mobile/features/announcements/presentation/bloc/comment_state.dart';

import '../../../../mocks/generate_mocks.mocks.dart';
import '../../../../mocks/mock_helpers.dart';

void main() {
  late MockGetCommentsUseCase mockGetComments;
  late MockCreateCommentUseCase mockCreateComment;
  late MockDeleteCommentUseCase mockDeleteComment;
  late CommentBloc bloc;

  const tComment = CommentEntity(
    id: 'comment-1',
    announcementId: 'ann-1',
    content: '¿Cuándo aplica esta política?',
    authorId: 'emp-1',
    createdAt: '2024-01-01',
    updatedAt: '2024-01-01',
  );

  setUpAll(() => registerFallbackValues());

  setUp(() {
    mockGetComments = MockGetCommentsUseCase();
    mockCreateComment = MockCreateCommentUseCase();
    mockDeleteComment = MockDeleteCommentUseCase();
    bloc = CommentBloc(
      getCommentsUseCase: mockGetComments,
      createCommentUseCase: mockCreateComment,
      deleteCommentUseCase: mockDeleteComment,
    );
  });

  tearDown(() => bloc.close());

  group('US15 - Comentarios en anuncios', () {
    blocTest<CommentBloc, CommentState>(
      'debe emitir [Loading, Loaded] al obtener comentarios exitosamente',
      build: () {
        when(mockGetComments('ann-1'))
            .thenAnswer((_) async => const Right([tComment]));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchComments('ann-1')),
      expect: () => [
        CommentLoading(),
        const CommentLoaded([tComment]),
      ],
    );

    blocTest<CommentBloc, CommentState>(
      'debe emitir [Loading, Error] cuando falla la obtención de comentarios',
      build: () {
        when(mockGetComments('ann-1'))
            .thenAnswer((_) async => const Left(ServerFailure('Error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchComments('ann-1')),
      expect: () => [
        CommentLoading(),
        const CommentError('Error'),
      ],
    );

    blocTest<CommentBloc, CommentState>(
      'debe crear comentario y refrescar la lista',
      build: () {
        when(mockCreateComment(
          announcementId: anyNamed('announcementId'),
          content: anyNamed('content'),
          authorId: anyNamed('authorId'),
        )).thenAnswer((_) async => const Right(tComment));
        when(mockGetComments('ann-1'))
            .thenAnswer((_) async => const Right([tComment]));
        return bloc;
      },
      act: (bloc) => bloc.add(const CreateCommentRequested(
        announcementId: 'ann-1',
        content: '¿Cuándo aplica esta política?',
        authorId: 'emp-1',
      )),
      expect: () => [
        CommentLoading(),
        const CommentLoaded([tComment]),
      ],
    );

    blocTest<CommentBloc, CommentState>(
      'debe mantener comentarios visibles mientras se crea uno nuevo (ActionInProgress)',
      seed: () => const CommentLoaded([tComment]),
      build: () {
        when(mockCreateComment(
          announcementId: anyNamed('announcementId'),
          content: anyNamed('content'),
          authorId: anyNamed('authorId'),
        )).thenAnswer((_) async => const Right(tComment));
        when(mockGetComments('ann-1'))
            .thenAnswer((_) async => const Right([tComment, tComment]));
        return bloc;
      },
      act: (bloc) => bloc.add(const CreateCommentRequested(
        announcementId: 'ann-1',
        content: 'Nuevo comentario',
        authorId: 'emp-2',
      )),
      expect: () => [
        const CommentActionInProgress([tComment]),
        CommentLoading(),
        isA<CommentLoaded>(),
      ],
    );

    blocTest<CommentBloc, CommentState>(
      'debe eliminar comentario y refrescar la lista',
      seed: () => const CommentLoaded([tComment]),
      build: () {
        when(mockDeleteComment('comment-1'))
            .thenAnswer((_) async => const Right(null));
        when(mockGetComments('ann-1'))
            .thenAnswer((_) async => const Right([]));
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteCommentRequested(
        commentId: 'comment-1',
        announcementId: 'ann-1',
      )),
      expect: () => [
        const CommentActionInProgress([tComment]),
        CommentLoading(),
        const CommentLoaded([]),
      ],
    );
  });
}
