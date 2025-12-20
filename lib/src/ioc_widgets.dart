import 'package:ioc_widget/src/internal_ioc_widgets.dart';

class InjectableWidget<T> extends IocWidget<T> {
  const InjectableWidget({
    required super.factory,
    super.child,
    super.key,
    super.dispose,
  }) : super(isLazySingleton: false);
}

class LazySingletonWidget<T> extends IocWidget<T> {
  const LazySingletonWidget({
    required super.factory,
    super.child,
    super.key,
    super.dispose,
  }) : super(isLazySingleton: true);
}
