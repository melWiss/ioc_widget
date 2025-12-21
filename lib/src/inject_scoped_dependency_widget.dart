import 'package:flutter/widgets.dart';
import 'package:ioc_widget/ioc_widget.dart';
import 'package:ioc_widget/src/internal_ioc_widgets.dart';

/// A widget that injects a scoped dependency of type [T] into the widget tree.
///
/// The [builder] function provides the [BuildContext] to build the widget subtree.
class InjectScopedDependency<T> extends StatefulWidget {
  /// The builder function that receives the [BuildContext].
  final Widget Function(BuildContext context) builder;

  /// Creates an [InjectScopedDependency] widget.
  const InjectScopedDependency({required this.builder, super.key});

  @override
  State<InjectScopedDependency<T>> createState() =>
      _InjectScopedDependencyState<T>();
}

class _InjectScopedDependencyState<T> extends State<InjectScopedDependency<T>> {
  late InternalIocInheritedWidget<T> dependency;
  late T value;

  @override
  void initState() {
    dependency = context.getContainer<T>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
}
