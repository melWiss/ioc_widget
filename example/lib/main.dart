import 'package:flutter/material.dart';
import 'package:ioc_widget/ioc_widget.dart';

class ClassA {
  void talk() {
    print("I'm Class A! $hashCode");
  }
}

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Body(),
      builder:
          (_, child) => MultiIocWidget(
            dependencies: [
              InjectableWidget<ClassA>(factory: (_) => ClassA()),
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
    ClassA a = context.get();
    ClassA b = context.get();
    ClassA c = context.get();
    ClassA d = context.get();
    a.talk();
    b.talk();
    c.talk();
    d.talk();
    ClassB e = context.get();
    ClassB f = context.get();
    ClassB g = context.get();
    ClassB h = context.get();
    e.talk();
    f.talk();
    g.talk();
    h.talk();
    return Placeholder();
  }
}
