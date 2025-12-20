import 'package:flutter/material.dart';
import 'package:ioc_widget/src/internal_ioc_widgets.dart';

extension IocGetExtension on BuildContext {
  T get<T>() => IocWidget.of(this);
}
