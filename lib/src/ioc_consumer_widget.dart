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
  State<InjectScopedDependency<T>> createState() => _InjectScopedDependencyState<T>();
}

class _InjectScopedDependencyState<T> extends State<InjectScopedDependency<T>> {
  late InternalIocInheritedWidget<T> dependency;

  @override
  void initState() {
    dependency = IocWidget.containerOf(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LazySingletonWidget<T>(
      factory: dependency.factory,
      dispose: dependency.dispose,
      child: Builder(builder: widget.builder),
    );
  }
}
