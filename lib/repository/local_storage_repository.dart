import 'package:agro/model/answer/answer.dart';
import 'package:hive/hive.dart';

/// Legacy per-order call results stored on the device. Nothing writes them
/// any more; logout still clears what older versions saved.
class LocalStorageRepository {
  Future<void> clear() async {
    final box = await Hive.openBox<Answer>(_answers);
    await box.clear();
    await box.close();
  }

  static const String _answers = "answers";
}
