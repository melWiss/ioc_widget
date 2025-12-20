import 'package:flutter/widgets.dart';
import 'package:ioc_widget/ioc_widget.dart';
import 'package:ioc_widget/src/internal_ioc_widgets.dart';

class IocConsumer<T> extends StatefulWidget {
  final Widget Function(BuildContext context) builder;
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
      child: widget.builder(context),
    );
  }
}
