import 'package:flutter/material.dart';
import 'package:ioc_widget/ioc_widget.dart';

/// Example class to demonstrate dependency injection.
class ClassA {
  void talk() {
    print("I'm Class A! $hashCode");
  }
}

/// Example class that depends on [ClassA].
class ClassB {
  final ClassA classA;
  const ClassB(this.classA);

  void talk() {
    print("I'm Class B! $hashCode");
    print("And I'm Class A! ${classA.hashCode}");
  }
}

void main() {
  runApp(const MyApp());
}

/// Example usage of the IoC widget system.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Body(),
      builder: (_, child) => MultiIocWidget(
        dependencies: [
          // Register ClassA as a transient (new instance each time)
          InjectableWidget<ClassA>(factory: (_) => ClassA()),
          // Register ClassB as a lazy singleton (same instance for the subtree)
          LazySingletonWidget<ClassB>(factory: (ctx) => ClassB(ctx.get())),
        ],
        child: child!,
      ),
    );
  }
}

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve multiple instances of ClassA (should have different hashCodes)
    final a1 = context.get<ClassA>();
    final a2 = context.get<ClassA>();
    a1.talk();
    a2.talk();

    // Retrieve ClassB (should be the same instance each time)
    final b1 = context.get<ClassB>();
    final b2 = context.get<ClassB>();
    b1.talk();
    b2.talk();

    return const Center(
      child: Text(
        'Check the console output for IoC widget usage example.',
        textAlign: TextAlign.center,
      ),
    );
  }
}
