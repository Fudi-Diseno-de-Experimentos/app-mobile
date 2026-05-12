import 'package:flutter_test/flutter_test.dart';

class Event {
  final String id;
  final String name;
  Event({required this.id, required this.name});
}

class MockEventRepo {
  final List<Event> _store = [];

  Future<Event> create(Event e) async {
    _store.add(e);
    return e;
  }

  Future<List<Event>> get() async {
    return _store;
  }

  Future<Event> update(String id, String newName) async {
    final index = _store.indexWhere((x) => x.id == id);
    if (index == -1) throw Exception('Not found');
    final updated = Event(id: id, name: newName);
    _store[index] = updated;
    return updated;
  }
}

void main() {
  group('Event Core Tests', () {
    late MockEventRepo repo;

    setUp(() {
      repo = MockEventRepo();
    });

    test('Create Event', () async {
      final e = Event(id: '1', name: 'Party');
      final result = await repo.create(e);
      expect(result.id, '1');
      expect(result.name, 'Party');
    });

    test('Get Events', () async {
      await repo.create(Event(id: '1', name: 'E1'));
      final list = await repo.get();
      expect(list.length, 1);
    });

    test('Update Event', () async {
      await repo.create(Event(id: '1', name: 'E1'));
      final updated = await repo.update('1', 'E2');
      expect(updated.name, 'E2');
    });
  });
}
