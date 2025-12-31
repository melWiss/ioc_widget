import 'package:flutter/material.dart';

/// An [InheritedWidget] that holds a dependency of type [T] for the IoC system.
///
/// This widget is used internally by [IocWidget] to provide dependencies to the widget tree.
// ignore: must_be_immutable
class InternalIocInheritedWidget<T> extends InheritedWidget {
  /// The factory function to create the dependency.
  final T Function(BuildContext context) factory;

  /// Optional dispose callback for cleaning up the dependency.
  final void Function()? dispose;

  /// Whether the dependency should be a lazy singleton.
  final bool isLazySingleton;
  InternalIocInheritedWidget({
    required this.factory,
    required super.child,
    this.isLazySingleton = false,
    this.dispose,
    super.key,
  });

  T? _value;

  /// Returns the dependency instance, creating it if necessary.
  T get(BuildContext context) {
    if (isLazySingleton) return _value ??= factory(context);
    return factory(context);
  }

  @override
  bool updateShouldNotify(InternalIocInheritedWidget<T> old) => false;
}

/// A widget that provides a dependency of type [T] to the widget tree.
///
/// Use [InjectableWidget] or [LazySingletonWidget] for common use cases.
class IocWidget<T> extends StatefulWidget {
  /// The factory function to create the dependency.
  final T Function(BuildContext context) factory;

  /// Optional dispose callback for cleaning up the dependency.
  final Function()? dispose;

  /// The child widget subtree that can access the dependency.
  final Widget? child;

  /// Whether the dependency should be a lazy singleton.
  final bool isLazySingleton;

  /// Creates an [IocWidget].
  const IocWidget({
    required this.factory,
    this.child,
    super.key,
    this.isLazySingleton = false,
    this.dispose,
  });

  @override
  State<IocWidget<T>> createState() => _IocWidgetState<T>();

  /// Retrieves a dependency of type [T] from the nearest IoC provider in the widget tree, or null if not found.
  static T? maybeOf<T extends Object>(BuildContext context) {
    InternalIocInheritedWidget<T>? dependencyWidget =
        context
                .getElementForInheritedWidgetOfExactType<
                  InternalIocInheritedWidget<T>
                >()
                ?.widget
            as InternalIocInheritedWidget<T>?;
    if (dependencyWidget == null) return null;
    return dependencyWidget.get(context);
  }

  /// Retrieves a dependency of type [T] from the nearest IoC provider in the widget tree.
  ///
  /// Throws an assertion error if the dependency is not found.
  static T of<T extends Object>(BuildContext context) {
    T? dependency = maybeOf<T>(context);
    assert(
      dependency != null,
      "The requested dependency <$T> is not registered in the widget tree.",
    );
    return dependency!;
  }

  /// Retrieves the nearest [InternalIocInheritedWidget] container of type [T], or null if not found.
  static InternalIocInheritedWidget<T>? maybeContainerOf<T extends Object>(
    BuildContext context,
  ) {
    return context
            .getElementForInheritedWidgetOfExactType<
              InternalIocInheritedWidget<T>
            >()
            ?.widget
        as InternalIocInheritedWidget<T>?;
  }

  /// Retrieves the nearest [InternalIocInheritedWidget] container of type [T].
  ///
  /// Throws an assertion error if the container is not found.
  static InternalIocInheritedWidget<T> containerOf<T extends Object>(
    BuildContext context,
  ) {
    InternalIocInheritedWidget<T>? nullableContainer = maybeContainerOf(
      context,
    );
    assert(
      nullableContainer != null,
      "The requested container InternalIocInheritedWidget<$T>? is not registered in the widget tree.",
    );
    return nullableContainer!;
  }

  /// Wraps another widget with this IoC provider.
  Widget _wrap(Widget other) {
    return IocWidget<T>(
      factory: factory,
      isLazySingleton: isLazySingleton,
      dispose: dispose,
      child: other,
    );
  }
}

class _IocWidgetState<T> extends State<IocWidget<T>> {
  @override
  void dispose() {
    if (widget.isLazySingleton) {
      widget.dispose?.call();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.child == null) return SizedBox.shrink();
    return InternalIocInheritedWidget<T>(
      factory: widget.factory,
      isLazySingleton: widget.isLazySingleton,
      dispose: widget.dispose,
      child: widget.child!,
    );
  }
}

/// A widget that provides multiple dependencies to the widget tree.
///
/// [dependencies] is a list of [IocWidget]s to provide, and [child] is the widget subtree that can access them.
class MultiIocWidget extends StatelessWidget {
  /// The list of IoC dependency widgets to provide.
  final List<IocWidget> dependencies;

  /// The child widget subtree that can access the dependencies.
  final Widget child;

  /// Creates a [MultiIocWidget].
  const MultiIocWidget({
    super.key,
    required this.dependencies,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // we need to loop over the dependencies and extract the factory and lazy sinleton property from it
    // then construct a nested widget tree by looping over those dependencies
    // and it should NOT be recursive.

    return buildDependencyTree(dependencies);
  }

  /// Builds a nested widget tree of dependencies.
  Widget buildDependencyTree(List<IocWidget> deps) {
    Widget current = child;

    for (final dep in deps.reversed) {
      current = dep._wrap(current);
    }

    return current;
  }
}
