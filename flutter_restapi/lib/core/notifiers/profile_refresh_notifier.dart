import 'package:flutter/foundation.dart';

/// Thông báo các màn hình cần tải lại thông tin user (sau cập nhật hồ sơ).
class ProfileRefreshNotifier {
  ProfileRefreshNotifier._();

  static final ProfileRefreshNotifier instance = ProfileRefreshNotifier._();

  final ValueNotifier<int> tick = ValueNotifier(0);

  void notifyChanged() {
    tick.value++;
  }
}
