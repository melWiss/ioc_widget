import 'package:flutter/widgets.dart';
import 'package:ioc_widget/ioc_widget.dart';

/// A widget that injects a [ChangeNotifier] from the IoC container into the widget tree,
/// rebuilds when the notifier notifies listeners, and disposes the notifier when removed from the tree.
class InjectScopedNotifier<T extends ChangeNotifier> extends StatelessWidget {
  /// The builder function that receives the [BuildContext] and the notifier instance.
  final Widget Function(BuildContext context, T notifier) builder;

  const InjectScopedNotifier({required this.builder, super.key});

  @override
  Widget build(BuildContext context) {
    return InjectScopedDependency<T>(
      builder:
          (context) => ListenableBuilder(
            listenable: context.get<T>(),
            builder: (context, _) => builder(context, context.get()),
          ),
    );
  }
}
