import 'package:flutter/material.dart';
import 'package:ioc_widget/ioc_widget.dart';

/// Example class to demonstrate dependency injection.
class ClassA {
  String talk() {
    return "I'm Class A! $hashCode";
  }
}

/// Example class that depends on [ClassA].
class ClassB {
  final ClassA classA;
  const ClassB(this.classA);

  String talk() {
    return "I'm Class B! $hashCode\nAnd I'm Class A! ${classA.hashCode}";
  }
}

/// Example class that depends on [ClassB].
class ClassC {
  final ClassB classB;
  const ClassC(this.classB);

  String talk() {
    return "I'm Class C! $hashCode\n${classB.talk()}";
  }
}

class CounterNotifier extends ChangeNotifier {
  int value = 0;
  void increment() {
    value++;
    notifyListeners();
  }
}

void main() {
  runApp(const MyApp());
}

/// Example usage of the IoC widget system with navigation and all public components.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const PageA());
          case '/b':
            return MaterialPageRoute(builder: (_) => const PageB());
          case '/c':
            return MaterialPageRoute(builder: (_) => const PageC());
          case '/notifier':
            return MaterialPageRoute(builder: (_) => const PageNotifier());
          case '/external':
            return MaterialPageRoute(builder: (_) => const PageExternalValue());
          case '/external-notifier':
            return MaterialPageRoute(builder: (_) => const PageNotifierExternal());
          default:
            return null;
        }
      },
      builder:
          (_, child) => MultiIocWidget(
            dependencies: [
              InjectableWidget<ClassA>(factory: (_) => ClassA()),
              LazySingletonWidget<ClassB>(factory: (ctx) => ClassB(ctx.get())),
              LazySingletonWidget<ClassC>(factory: (ctx) => ClassC(ctx.get())),
              InjectableWidget<CounterNotifier>(
                factory: (_) => CounterNotifier(),
              ),
            ],
            child: child ?? const SizedBox.shrink(),
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
                  SnackBar(
                    content: Text('ClassA: ${context.get<ClassA>().talk()}'),
                  ),
                );
              },
              child: const Text('Talk (ClassA)'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/b'),
              child: const Text('Go to Page B'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/notifier'),
              child: const Text('Go to Notifier Page'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/external'),
              child: const Text('Go to External Value Page'),
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
                  SnackBar(
                    content: Text('ClassB: ${context.get<ClassB>().talk()}'),
                  ),
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
                      SnackBar(
                        content: Text('ClassC: ${ctx.get<ClassC>().talk()}'),
                      ),
                    );
                  },
                  child: const Text('Talk (ClassC)'),
                ),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text('ClassA: ${ctx.get<ClassA>().talk()}'),
                      ),
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

class PageNotifier extends StatelessWidget {
  const PageNotifier({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Notifier - InjectScopedNotifier')),
      body: Center(
        child: InjectScopedNotifier<CounterNotifier>(
          builder:
              (ctx, notifier) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Counter value: ${notifier.value}',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: notifier.increment,
                    child: const Text('Increment'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Back'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final notifierFromContext = ctx.get<CounterNotifier>();
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Notifier hashCode: ${notifierFromContext.hashCode}',
                          ),
                        ),
                      );
                    },
                    child: const Text('Show Notifier HashCode'),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}

class PageExternalValue extends StatelessWidget {
  const PageExternalValue({super.key});
  @override
  Widget build(BuildContext context) {
    final externalA = ClassA();
    return Scaffold(
      appBar: AppBar(title: const Text('Page - InjectScopedDependency (external value)')),
      body: Center(
        child: InjectScopedDependency<ClassA>(
          value: externalA,
          builder: (ctx) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Injected external ClassA: ${ctx.get<ClassA>().talk()}'),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(ctx, '/external-notifier'),
                child: const Text('External Notifier'),
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
