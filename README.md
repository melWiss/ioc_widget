# ioc_widget

A simple, flexible, and testable dependency injection (DI) solution for Flutter, inspired by the best of both the Provider and get_it packages. This package is designed for widget-level dependency injection, supporting both transient (injectable) and singleton (lazy) strategies, and is ideal for managing dependencies in a scalable, testable, and maintainable way.

## Motivation

We already have the Provider package that somehow handles dependency injection and it's perfect.

My only issue with Provider is the easy misuse of it. When you go in the Flutter official docs, they suggest using Provider as a simple state manegement package alongsie the fact that it can work as a dependency injection mechanism.

However in the guide, it's suggested that you have all the list of your providers on the root level of your app, this results in all provided classes to be singletons which is not a realistic case scenario.

So, how about we have something with the same simplicity as Provider but it can provide singletons and new instances everytime you get the dependency just like get_it?

## Why use ioc_widget?

Use this package if you want:

- **Explicit DI**: Register and scope dependencies in the widget tree, not globally.
- **Testability**: Easily override dependencies in tests.
- **Lifecycle control**: Choose between transient (new instance per request) and lazy singleton (one instance per scope) strategies.
- **No magic**: No code generation, no global singletons, no hidden state.

## Getting Started

Add to your `pubspec.yaml`:

```yaml
dependencies:
  ioc_widget: ^<latest_version>
```

## Core Concepts

- **InjectableWidget**: Provides a new instance of a dependency every time it is requested.
- **LazySingletonWidget**: Provides a single instance of a dependency for the subtree, created on first use.
- **MultiIocWidget**: Register multiple dependencies at once.
- **InjectScopedDependency**: Injects dependencies in context widget tree and handles its dispose callback. (Renamed from IocConsumer in v2.0.0)
- **InjectScopedNotifier**: Injects a ChangeNotifier from the IoC container, rebuilds when the notifier updates, and disposes it automatically when removed from the tree. Use the `value` parameter to provide an external notifier (no disposal).
- **context.get<T>()**: Retrieve a dependency of type `T` from the nearest provider.

## Usage Example

```dart
import 'package:flutter/material.dart';
import 'package:ioc_widget/ioc_widget.dart';

class ClassA {
  String talk() => "I'm Class A! $hashCode";
}

class ClassB {
  final ClassA classA;
  ClassB(this.classA);
  String talk() => "I'm Class B! $hashCode\nAnd I'm Class A! ${classA.hashCode}";
}

class ClassC {
  final ClassB classB;
  ClassC(this.classB);
  String talk() => "I'm Class C! $hashCode\n" + classB.talk();
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const PageA(),
        '/b': (_) => const PageB(),
        '/c': (_) => const PageC(),
      },
      builder: (_, child) => MultiIocWidget(
        dependencies: [
          InjectableWidget<ClassA>(factory: (_) => ClassA()),
          LazySingletonWidget<ClassB>(factory: (ctx) => ClassB(ctx.get())),
          LazySingletonWidget<ClassC>(factory: (ctx) => ClassC(ctx.get())),
          InjectableWidget<CounterNotifier>(factory: (_) => CounterNotifier()),
        ],
        child: child!,
      ),
    );
  }
}

class PageA extends StatelessWidget {
  const PageA({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page A - InjectableWidget')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('ClassA is injected as a transient.'),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('ClassA: ${context.get<ClassA>().talk()}')),
                );
              },
              child: const Text('Talk (ClassA)'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/b'),
              child: const Text('Go to Page B'),
            ),
          ],
        ),
      ),
    );
  }
}

class PageB extends StatelessWidget {
  const PageB({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page B - LazySingletonWidget')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('ClassB is injected as a lazy singleton.'),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('ClassB: ${context.get<ClassB>().talk()}')),
                );
              },
              child: const Text('Talk (ClassB)'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/c'),
              child: const Text('Go to Page C'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Page A'),
            ),
          ],
        ),
      ),
    );
  }
}

class PageC extends StatelessWidget {
  const PageC({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page C - InjectScopedDependency')),
      body: Center(
        child: InjectScopedDependency<ClassA>(
          builder: (ctx) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('ClassC is injected using InjectScopedDependency.'),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('ClassC: ${ctx.get<ClassC>().talk()}')),
                    );
                  },
                  child: const Text('Talk (ClassC)'),
                ),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('ClassA: ${ctx.get<ClassA>().talk()}')),
                    );
                  },
                  child: const Text('Talk (ClassA)'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Back to Page B'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class CounterNotifier extends ChangeNotifier {
  int value = 0;
  void increment() {
    value++;
    notifyListeners();
  }
}

class PageNotifier extends StatelessWidget {
  const PageNotifier({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Notifier - InjectScopedNotifier')),
      body: Center(
        child: InjectScopedNotifier<CounterNotifier>(
          builder: (ctx, notifier) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Counter value: ${notifier.value}', style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: notifier.increment,
                child: const Text('Increment'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final notifierFromContext = ctx.get<CounterNotifier>();
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Notifier hashCode: ${notifierFromContext.hashCode}')),
                  );
                },
                child: const Text('Show Notifier HashCode'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PageNotifierExternal extends StatelessWidget {
  const PageNotifierExternal({super.key});
  @override
  Widget build(BuildContext context) {
    final externalNotifier = CounterNotifier();
    return Scaffold(
      appBar: AppBar(title: const Text('Page Notifier - InjectScopedNotifier (external value)')),
      body: Center(
        child: InjectScopedNotifier<CounterNotifier>(
          value: externalNotifier,
          builder: (ctx, notifier) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Counter value: ${notifier.value}', style: const TextStyle(fontSize: 24)),
              ElevatedButton(
                onPressed: notifier.increment,
                child: const Text('Increment'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## API Reference

### InjectableWidget<T>
Provides a new instance of `T` every time it is requested from the context.

### LazySingletonWidget<T>
Provides a single instance of `T` for the subtree, created on first use.

### MultiIocWidget
Registers multiple dependencies at once. Useful for grouping related dependencies.

### InjectScopedDependency<T>
Widget that exposes a dependency in its context widget tree as a singleton and gets disposed when its parent is disposed. (Renamed from IocConsumer in v2.0.0)

### InjectScopedNotifier<T extends ChangeNotifier>
Widget that injects a ChangeNotifier from the IoC container, rebuilds when the notifier updates, and disposes it automatically when removed from the tree. The notifier instance is a singleton within the widget scope and will be recreated if the widget is disposed and rebuilt.

- Use the `value` parameter to provide an external notifier (no disposal).

### context.get<T>()
Extension on `BuildContext` to retrieve a dependency of type `T` from the nearest provider.

## Testing

The package is designed for testability. You can easily override dependencies in your widget tests. Example:

```dart
testWidgets('InjectableWidget creates a new instance every time', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: InjectableWidget<TestClass>(
        factory: (_) => TestClass(),
        child: Builder(
          builder: (context) {
            final a = context.get<TestClass>();
            final b = context.get<TestClass>();
            return Text('${a.hashCode}-${b.hashCode}');
          },
        ),
      ),
    ),
  );
  expect(TestClass.instanceCount, 2);
});

testWidgets('InjectScopedDependency exposes a new instance in its scope', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: InjectableWidget<TestClass>(
        factory: (_) => TestClass(),
        child: Builder(
          builder: (ctx) {
            final _ = ctx.get<TestClass>();
            return InjectScopedDependency<TestClass>(
              builder: (ctx) {
                final a = ctx.get<TestClass>();
                final b = ctx.get<TestClass>();
                final c = ctx.get<TestClass>();
                return Text('${a.hashCode}-${b.hashCode}-${c.hashCode}');
              },
            );
          }
        ),
      ),
    ),
  );
  // Should create two instances (one for each get)
  expect(TestClass.instanceCount, 2);
});
```

## Lifecycle & Disposal

- `LazySingletonWidget` supports a `dispose` callback for cleaning up resources when the widget is removed from the tree.
- `InjectableWidget` does not call `dispose` (since it creates new instances each time) so you should either explicitly call the dispose method of that specific instance or safely dispose it by mixing it with the `InjectScopedDependency` widget.
- `InjectScopedNotifier` automatically disposes the ChangeNotifier when the widget is removed from the tree.
- The notifier is a singleton within the widget scope and will be recreated if the widget is disposed and rebuilt.

## When to use
- When you want explicit, widget-scoped dependency injection.
- When you want to avoid global singletons and make your app more testable.
- When you want to control the lifecycle of your dependencies.

## When NOT to use
- If you want global, app-wide singletons (use get_it directly).
- If you want state management (use Provider, Riverpod, Bloc, etc.).

## License

MIT
