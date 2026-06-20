import 'package:flutter/widgets.dart';

enum DeviceClass { mobile, tablet, desktop }

extension ResponsiveContext on BuildContext {
  double get width => MediaQuery.sizeOf(this).width;

  DeviceClass get deviceClass {
    if (width >= 1024) return DeviceClass.desktop;
    if (width >= 768) return DeviceClass.tablet;
    return DeviceClass.mobile;
  }

  bool get isDesktop => deviceClass == DeviceClass.desktop;
}
