import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active_file_provider.g.dart';

@riverpod
class ActiveFile extends _$ActiveFile {
  @override
  String? build() => null;

  void openFile(String filePath) {
    state = filePath;
  }

  void closeFile() {
    state = null;
  }
}
