import 'package:flutter/widgets.dart';
import 'package:ioc_widget/ioc_widget.dart';
import 'package:ioc_widget/src/internal_ioc_widgets.dart';

/// A widget that consumes a dependency of type [T] from the widget tree.
///
/// The [builder] function provides the [BuildContext] to build the widget subtree.
class IocConsumer<T> extends StatefulWidget {
  /// The builder function that receives the [BuildContext].
  final Widget Function(BuildContext context) builder;

  /// Creates an [IocConsumer] widget.
  const IocConsumer({required this.builder, super.key});

  @override
  State<IocConsumer<T>> createState() => _IocConsumerState<T>();
}

class _IocConsumerState<T> extends State<IocConsumer<T>> {
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
