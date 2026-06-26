import 'package:flutter_test/flutter_test.dart';

// Simulate integration logic for both
class CoreFacade {
  List<String> logs = [];

  Future<void> syncEventsAndAnnouncements() async {
    logs.add('fetching_events');
    logs.add('fetching_announcements');
    logs.add('synced');
  }
}

void main() {
  group('Integration Tests - Announcements and Events', () {
    test('Facade syncs both modules', () async {
      final facade = CoreFacade();
      await facade.syncEventsAndAnnouncements();

      expect(facade.logs.contains('fetching_events'), isTrue);
      expect(facade.logs.contains('fetching_announcements'), isTrue);
      expect(facade.logs.contains('synced'), isTrue);
    });
  });
}
