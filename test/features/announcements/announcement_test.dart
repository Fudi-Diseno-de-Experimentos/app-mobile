import 'package:flutter_test/flutter_test.dart';

// Mock entities and repos
class Announcement {
  final String id;
  final String title;
  final String content;
  Announcement({required this.id, required this.title, required this.content});
}

class MockAnnouncementRepo {
  final List<Announcement> _store = [];

  Future<Announcement> create(Announcement a) async {
    _store.add(a);
    return a;
  }

  Future<List<Announcement>> get() async {
    return _store;
  }

  Future<Announcement> update(String id, String newTitle) async {
    final index = _store.indexWhere((e) => e.id == id);
    if (index == -1) throw Exception('Not found');
    final updated = Announcement(
      id: id,
      title: newTitle,
      content: _store[index].content,
    );
    _store[index] = updated;
    return updated;
  }
}

void main() {
  group('Announcement Core Tests', () {
    late MockAnnouncementRepo repo;

    setUp(() {
      repo = MockAnnouncementRepo();
    });

    test('Create Announcement', () async {
      final a = Announcement(id: '1', title: 'Test', content: 'Content');
      final result = await repo.create(a);
      expect(result.id, '1');
      expect(result.title, 'Test');
    });

    test('Get Announcements', () async {
      await repo.create(
        Announcement(id: '1', title: 'Test 1', content: 'Content 1'),
      );
      await repo.create(
        Announcement(id: '2', title: 'Test 2', content: 'Content 2'),
      );
      final list = await repo.get();
      expect(list.length, 2);
    });

    test('Update Announcement', () async {
      await repo.create(
        Announcement(id: '1', title: 'Old Title', content: 'Content'),
      );
      final updated = await repo.update('1', 'New Title');
      expect(updated.title, 'New Title');
    });
  });
}
