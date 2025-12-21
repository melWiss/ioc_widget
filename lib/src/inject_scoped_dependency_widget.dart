import 'package:flutter/widgets.dart';
import 'package:ioc_widget/ioc_widget.dart';
import 'package:ioc_widget/src/internal_ioc_widgets.dart';

/// A widget that injects a scoped dependency of type [T] into the widget tree.
///
/// The [builder] function provides the [BuildContext] to build the widget subtree.
///
/// Use [value] to provide an external value (no disposal).
class InjectScopedDependency<T> extends StatefulWidget {
  /// The builder function that receives the [BuildContext].
  final Widget Function(BuildContext context) builder;

  /// An optional externally provided value. If set, this value is injected and not disposed.
  final T? value;

  /// Creates an [InjectScopedDependency] widget.
  ///
  /// If [value] is provided, it will be injected and not disposed by this widget.
  const InjectScopedDependency({required this.builder, this.value, super.key});

  @override
  State<InjectScopedDependency<T>> createState() =>
      _InjectScopedDependencyState<T>();
}

class _InjectScopedDependencyState<T> extends State<InjectScopedDependency<T>> {
  late InternalIocInheritedWidget<T> dependency;
  late T value;

  @override
  void initState() {
    dependency = context.getDependencyContainer<T>();
    if (widget.value != null) {
      value = widget.value as T;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.value == null) {
      return LazySingletonWidget<T>(
        factory: dependency.factory,
        dispose: () {
          dependency.dispose?.call();
          if (value is ChangeNotifier) {
            try {
              (value as ChangeNotifier).dispose();
            } catch (_) {}
          }
        },
        child: Builder(
          builder: (ctx) {
            value = ctx.get();
            return widget.builder(ctx);
          },
        ),
      );
    }
    return LazySingletonWidget<T>(
        factory: (_) => value,
        child: Builder(
          builder: widget.builder,
        ),
      );
  }
}
