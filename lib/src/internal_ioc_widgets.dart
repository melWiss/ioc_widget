import 'package:flutter/material.dart';

// ignore: must_be_immutable
class InternalIocInheritedWidget<T> extends InheritedWidget {
  final T Function(BuildContext context) factory;
  final bool isLazySingleton;
  InternalIocInheritedWidget({
    required this.factory,
    required super.child,
    this.isLazySingleton = false,
    super.key,
  });

  T? _value;

  T get(BuildContext context) {
    if (isLazySingleton) return _value ??= factory(context);
    return factory(context);
  }

  @override
  bool updateShouldNotify(InternalIocInheritedWidget<T> old) => false;
}

class IocWidget<T> extends StatefulWidget {
  final T Function(BuildContext context) factory;
  final Function()? dispose;
  final Widget? child;
  final bool isLazySingleton;

  const IocWidget({
    required this.factory,
    this.child,
    super.key,
    this.isLazySingleton = false,
    this.dispose,
  });

  @override
  State<IocWidget<T>> createState() => _IocWidgetState<T>();

  static T? maybeOf<T>(BuildContext context) {
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

  static T of<T>(BuildContext context) {
    T? dependency = maybeOf<T>(context);
    assert(
      dependency != null,
      "The requested dependency <$T> is not registered in the widget tree.",
    );
    return dependency!;
  }

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
      child: widget.child!,
    );
  }
}

class MultiIocWidget extends StatelessWidget {
  final List<IocWidget> dependencies;
  final Widget child;

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

  Widget buildDependencyTree(List<IocWidget> deps) {
    Widget current = child;

    for (final dep in deps.reversed) {
      current = dep._wrap(current);
    }

    return current;
  }
}
