import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:app_mobile/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:app_mobile/features/notifications/presentation/bloc/notification_event.dart';
import 'package:app_mobile/features/notifications/presentation/bloc/notification_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/generate_mocks.mocks.dart';
import '../../../../mocks/mock_helpers.dart';

void main() {
  late MockGetNotificationsUseCase mockGetNotifications;
  late MockMarkNotificationAsReadUseCase mockMarkAsRead;
  late NotificationBloc bloc;

  final tDate1 = DateTime(2026, 6, 28, 10, 0);
  final tDate2 = DateTime(2026, 6, 28, 11, 0);

  final tNotificationsList = [
    NotificationEntity(
      id: 'notif-1',
      title: 'New Event: All Hands',
      message: 'Description here',
      recipientIds: const ['user-1'],
      priority: 'MEDIUM',
      status: 'PENDING',
      createdAt: tDate1,
      updatedAt: tDate1,
    ),
    NotificationEntity(
      id: 'notif-2',
      title: ' New message in General',
      message: 'Hello world',
      recipientIds: const ['user-1'],
      priority: 'MEDIUM',
      status: 'PENDING',
      createdAt: tDate2,
      updatedAt: tDate2,
    ),
  ];

  final tSortedList = [
    NotificationEntity(
      id: 'notif-2',
      title: ' New message in General',
      message: 'Hello world',
      recipientIds: const ['user-1'],
      priority: 'MEDIUM',
      status: 'PENDING',
      createdAt: tDate2,
      updatedAt: tDate2,
    ),
    NotificationEntity(
      id: 'notif-1',
      title: 'New Event: All Hands',
      message: 'Description here',
      recipientIds: const ['user-1'],
      priority: 'MEDIUM',
      status: 'PENDING',
      createdAt: tDate1,
      updatedAt: tDate1,
    ),
  ];

  setUpAll(() => registerFallbackValues());

  setUp(() {
    mockGetNotifications = MockGetNotificationsUseCase();
    mockMarkAsRead = MockMarkNotificationAsReadUseCase();
    bloc = NotificationBloc(
      getNotificationsUseCase: mockGetNotifications,
      markNotificationAsReadUseCase: mockMarkAsRead,
    );
  });

  tearDown(() => bloc.close());

  group('NotificationBloc - FetchNotificationsList', () {
    blocTest<NotificationBloc, NotificationState>(
      'should emit [Loading, Loaded] sorted by date desc when successful',
      build: () {
        when(mockGetNotifications('user-1'))
            .thenAnswer((_) async => Right(tNotificationsList));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchNotificationsList('user-1')),
      expect: () => [
        NotificationLoading(),
        NotificationsLoaded(tSortedList),
      ],
    );

    blocTest<NotificationBloc, NotificationState>(
      'should emit [Loading, Error] when loading fails',
      build: () {
        when(mockGetNotifications('user-1'))
            .thenAnswer((_) async => const Left(ServerFailure('Connection error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchNotificationsList('user-1')),
      expect: () => [
        NotificationLoading(),
        const NotificationError('Connection error'),
      ],
    );
  });

  group('NotificationBloc - MarkNotificationRead', () {
    final tReadList = [
      NotificationEntity(
        id: 'notif-2',
        title: ' New message in General',
        message: 'Hello world',
        recipientIds: const ['user-1'],
        priority: 'MEDIUM',
        status: 'PENDING',
        createdAt: tDate2,
        updatedAt: tDate2,
      ),
      NotificationEntity(
        id: 'notif-1',
        title: 'New Event: All Hands',
        message: 'Description here',
        recipientIds: const ['user-1'],
        priority: 'MEDIUM',
        status: 'READ',
        createdAt: tDate1,
        updatedAt: tDate1,
      ),
    ];

    blocTest<NotificationBloc, NotificationState>(
      'should emit [Loaded] with updated READ status locally immediately',
      seed: () => NotificationsLoaded(tSortedList),
      build: () {
        when(mockMarkAsRead('notif-1'))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const MarkNotificationRead('notif-1')),
      expect: () => [
        NotificationsLoaded(tReadList),
      ],
      verify: (_) {
        verify(mockMarkAsRead('notif-1')).called(1);
      },
    );
  });
}
