## 2.0.4
### Bug fixes
- trying storing the dependency value within the StatefulWidget's state

## 2.0.3
### Bug fixes
- used maybeGetDependencyContainer instead of getDependencyContainer

## 2.0.2
### Bug fixes
- fixed late instance bug
- fixed variable nullability type not registered issue

## 2.0.1
### Added & Fixed
- Added a `value` parameter to both `InjectScopedDependency` and `InjectScopedNotifier` to allow injecting an external value or notifier instance that will NOT be disposed by the widget. This makes it easy to provide externally managed dependencies for testing or advanced scenarios.
- Fixed disposal behavior: If `value` is provided, the widget will not dispose the instance. If `value` is not provided, the instance created by the IoC container will be disposed automatically when the widget is removed from the tree.

## 2.0.0
### Breaking Changes
- Renamed `IocConsumer` widget to `InjectScopedDependency` for clarity and to avoid confusion with Provider's Consumer.
- Updated all references in the codebase, example app, and tests to use `InjectScopedDependency`.
- Updated documentation and API references accordingly.
- Added `InjectScopedNotifier<T extends ChangeNotifier>` widget for scoped injection of ChangeNotifier.
  - Automatically rebuilds child widgets when the notifier calls `notifyListeners`.
  - Disposes the notifier when the widget is removed from the tree.
  - Ensures the injected notifier is a singleton within the widget scope and changes when the widget is disposed/recreated.
- Example app updated with a new page demonstrating `InjectScopedNotifier` usage and singleton behavior.
- Comprehensive widget tests for `InjectScopedNotifier`, covering rebuilds, disposal, singleton scope, and instance recreation.

## 1.0.0
### Added
- Initial release of ioc_widget package.
- InjectableWidget for transient dependencies.
- LazySingletonWidget for lazy singleton dependencies.
- MultiIocWidget for grouping multiple dependencies.
- IocConsumer for scoped dependency access in builder context.
- context.get<T>() extension for dependency retrieval.
- Example app demonstrating navigation and all features.
- Comprehensive widget tests for all DI scenarios.
- MIT License file added.
- Complete README documentation and usage guide.
