import 'package:flutter/widgets.dart';
import 'package:ioc_widget/ioc_widget.dart';

/// A widget that injects a [ChangeNotifier] from the IoC container into the widget tree,
/// rebuilds when the notifier notifies listeners, and disposes the notifier when removed from the tree.
///
/// If you want to provide an existing notifier instance and avoid disposal, use the [value] parameter.
class InjectScopedNotifier<T extends ChangeNotifier> extends StatelessWidget {
  /// The builder function that receives the [BuildContext] and the notifier instance.
  final Widget Function(BuildContext context, T notifier) builder;

  /// An optional externally provided notifier. If set, this value is injected and not disposed.
  final T? value;

  /// Creates an [InjectScopedNotifier].
  ///
  /// If [value] is provided, it will be injected and not disposed by this widget.
  const InjectScopedNotifier({required this.builder, this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return InjectScopedDependency<T>(
      value: value,
      builder:
          (context) => ListenableBuilder(
            listenable: context.get<T>(),
            builder: (context, _) => builder(context, context.get()),
          ),
    );
  }
}
