import 'package:ioc_widget/src/internal_ioc_widgets.dart';

/// A widget that provides an injectable dependency of type [T] to the widget tree.
///
/// The dependency is created using the provided [factory] function and is not a singleton.
/// Use this for dependencies that should be recreated each time they are requested.
class InjectableWidget<T> extends IocWidget<T> {
  /// Creates an [InjectableWidget].
  ///
  /// [factory] is the function that creates the dependency.
  /// [child] is the widget subtree that can access the dependency.
  /// [dispose] is an optional function called when the widget is disposed.
  const InjectableWidget({
    required super.factory,
    super.child,
    super.key,
    super.dispose,
  }) : super(isLazySingleton: false);
}

/// A widget that provides a lazy singleton dependency of type [T] to the widget tree.
///
/// The dependency is created using the provided [factory] function the first time it is requested,
/// and the same instance is returned for subsequent requests.
class LazySingletonWidget<T> extends IocWidget<T> {
  /// Creates a [LazySingletonWidget].
  ///
  /// [factory] is the function that creates the dependency.
  /// [child] is the widget subtree that can access the dependency.
  /// [dispose] is an optional function called when the widget is disposed.
  const LazySingletonWidget({
    required super.factory,
    super.child,
    super.key,
    super.dispose,
  }) : super(isLazySingleton: true);
}
