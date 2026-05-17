import 'package:shared_preferences/shared_preferences.dart';

/// Local-only archive: the backend has no archive concept, so the set of
/// archived group ids lives in SharedPreferences on the device.
class ChatArchiveStore {
  static const _key = 'chat_archived_group_ids';

  final SharedPreferences sharedPreferences;

  ChatArchiveStore(this.sharedPreferences);

  Set<String> getArchived() {
    return sharedPreferences.getStringList(_key)?.toSet() ?? <String>{};
  }

  Future<Set<String>> toggle(String groupId) async {
    final current = getArchived();
    if (!current.add(groupId)) {
      current.remove(groupId);
    }
    await sharedPreferences.setStringList(_key, current.toList());
    return current;
  }
}
