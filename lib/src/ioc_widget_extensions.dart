import 'package:flutter/material.dart';
import 'package:ioc_widget/src/internal_ioc_widgets.dart';

/// Extension on [BuildContext] to easily retrieve dependencies from the IoC container.
extension IocGetExtension on BuildContext {
  /// Retrieves a dependency of type [T] from the nearest IoC provider in the widget tree.
  T get<T>() => IocWidget.of(this);

  /// Retrieves the dependency container of type [T] from the nearest IoC provider
  /// in the widget tree.
  InternalIocInheritedWidget<T> getContainer<T>() =>
      IocWidget.containerOf(this);
}
