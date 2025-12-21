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
    return "I'm Class C! $hashCode\n" + classB.talk();
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
      initialRoute: '/',
      routes: {
        '/': (_) => const PageA(),
        '/b': (_) => const PageB(),
        '/c': (_) => const PageC(),
      },
      builder:
          (_, child) => MultiIocWidget(
            dependencies: [
              // Register ClassA as a transient (new instance each time)
              InjectableWidget<ClassA>(factory: (_) => ClassA()),
              // Register ClassB as a lazy singleton (same instance for the subtree)
              LazySingletonWidget<ClassB>(factory: (ctx) => ClassB(ctx.get())),
              // Register ClassC as a lazy singleton (to show deeper dependency)
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
