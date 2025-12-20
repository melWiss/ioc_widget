# ioc_widget

A simple, flexible, and testable dependency injection (DI) solution for Flutter, inspired by the best of both the Provider and get_it packages. This package is designed for widget-level dependency injection, supporting both transient (injectable) and singleton (lazy) strategies, and is ideal for managing dependencies in a scalable, testable, and maintainable way.

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
- **IocConsumer**: Access dependencies in a builder context, with optional rebuilds.
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
      appBar: AppBar(title: const Text('Page C - IocConsumer')),
      body: Center(
        child: IocConsumer<ClassA>(
          builder: (ctx) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('ClassC is injected using IocConsumer.'),
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
```

## API Reference

### InjectableWidget<T>
Provides a new instance of `T` every time it is requested from the context.

### LazySingletonWidget<T>
Provides a single instance of `T` for the subtree, created on first use.

### MultiIocWidget
Registers multiple dependencies at once. Useful for grouping related dependencies.

### IocConsumer<T>
Widget that exposes a dependency in its builder context, allowing for fine-grained rebuilds and access.

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

// See test/ioc_widget_test.dart for more scenarios.
```

## Lifecycle & Disposal

- `LazySingletonWidget` supports a `dispose` callback for cleaning up resources when the widget is removed from the tree.
- `InjectableWidget` does not call `dispose` (since it creates new instances each time) so you should either explicitly call the dispose method of that specific instance or safely dispose it by mixing it with the `IocConsumer` widget.

## When to use
- When you want explicit, widget-scoped dependency injection.
- When you want to avoid global singletons and make your app more testable.
- When you want to control the lifecycle of your dependencies.

## When NOT to use
- If you want global, app-wide singletons (use get_it directly).
- If you want state management (use Provider, Riverpod, Bloc, etc.).

## License

MIT
