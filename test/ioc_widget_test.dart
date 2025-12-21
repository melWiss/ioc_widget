import 'package:flutter_test/flutter_test.dart';
import 'package:ioc_widget/ioc_widget.dart';
import '../example/lib/main.dart';
import 'package:flutter/material.dart';

class TestClass {
  static int instanceCount = 0;
  TestClass() {
    instanceCount++;
  }
}

class DisposableClass {
  static int disposeCount = 0;
  void dispose() {
    disposeCount++;
  }
}

class TestNotifier extends ChangeNotifier {
  int value = 0;
  int disposeCount = 0;
  void increment() {
    value++;
    notifyListeners();
  }
  @override
  void dispose() {
    disposeCount++;
    super.dispose();
  }
}

void main() {
  setUp(() {
    TestClass.instanceCount = 0;
    DisposableClass.disposeCount = 0;
  });

  group('IoC Widget Package', () {
    testWidgets('InjectableWidget provides a new instance each time', (tester) async {
      await tester.pumpWidget(const MyApp());
      // Go to PageA
      expect(find.text('Page A - InjectableWidget'), findsOneWidget);
      final context = tester.element(find.byType(PageA));
      final a1 = context.get<ClassA>();
      final a2 = context.get<ClassA>();
      expect(a1 == a2, isFalse, reason: 'InjectableWidget should provide a new instance each time');
    });

    testWidgets('LazySingletonWidget provides the same instance', (tester) async {
      await tester.pumpWidget(const MyApp());
      // Go to PageB
      await tester.tap(find.text('Go to Page B'));
      await tester.pumpAndSettle();
      expect(find.text('Page B - LazySingletonWidget'), findsOneWidget);
      final context = tester.element(find.byType(PageB));
      final b1 = context.get<ClassB>();
      final b2 = context.get<ClassB>();
      expect(b1, same(b2), reason: 'LazySingletonWidget should provide the same instance');
    });

    testWidgets('LazySingletonWidget dependencies are resolved correctly', (tester) async {
      await tester.pumpWidget(const MyApp());
      // Go to PageB
      await tester.tap(find.text('Go to Page B'));
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(PageB));
      final b = context.get<ClassB>();
      final a = context.get<ClassA>();
      expect(b.classA.runtimeType, ClassA);
      // ClassA is transient, so b.classA != context.get<ClassA>()
      expect(b.classA == a, isFalse);
    });

    testWidgets('MultiIocWidget provides all dependencies', (tester) async {
      await tester.pumpWidget(const MyApp());
      // On PageA
      final context = tester.element(find.byType(PageA));
      expect(context.get<ClassA>(), isA<ClassA>());
      // Go to PageB
      await tester.tap(find.text('Go to Page B'));
      await tester.pumpAndSettle();
      final contextB = tester.element(find.byType(PageB));
      expect(contextB.get<ClassB>(), isA<ClassB>());
      // Go to PageC
      await tester.tap(find.text('Go to Page C'));
      await tester.pumpAndSettle();
      final contextC = tester.element(find.byType(PageC));
      expect(contextC.get<ClassC>(), isA<ClassC>());
    });

    testWidgets('InjectScopedDependency provides dependency in builder context', (tester) async {
      await tester.pumpWidget(const MyApp());
      // Go to PageB
      await tester.tap(find.text('Go to Page B'));
      await tester.pumpAndSettle();
      // Go to PageC
      await tester.tap(find.text('Go to Page C'));
      await tester.pumpAndSettle();
      // Find the InjectScopedDependency builder context
      final consumerFinder = find.byType(InjectScopedDependency<ClassA>);
      expect(consumerFinder, findsOneWidget);
      final ctx = tester.element(consumerFinder);
      expect(ctx.get<ClassA>(), isA<ClassA>());
      expect(ctx.get<ClassC>(), isA<ClassC>());
    });

    testWidgets('Can navigate between all pages and back', (tester) async {
      await tester.pumpWidget(const MyApp());
      // PageA -> PageB
      await tester.tap(find.text('Go to Page B'));
      await tester.pumpAndSettle();
      expect(find.text('Page B - LazySingletonWidget'), findsOneWidget);
      // PageB -> PageC
      await tester.tap(find.text('Go to Page C'));
      await tester.pumpAndSettle();
      expect(find.text('Page C - InjectScopedDependency'), findsOneWidget);
      // PageC -> PageB
      await tester.tap(find.text('Back to Page B'));
      await tester.pumpAndSettle();
      expect(find.text('Page B - LazySingletonWidget'), findsOneWidget);
      // PageB -> PageA
      await tester.tap(find.text('Back to Page A'));
      await tester.pumpAndSettle();
      expect(find.text('Page A - InjectableWidget'), findsOneWidget);
    });
  });

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

  testWidgets('LazySingletonWidget creates only one instance', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LazySingletonWidget<TestClass>(
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
    expect(TestClass.instanceCount, 1);
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

  testWidgets('InjectScopedDependency exposes the same singleton instance in its scope', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LazySingletonWidget<TestClass>(
          factory: (_) => TestClass(),
          child: InjectScopedDependency<TestClass>(
            builder: (ctx) {
              final a = ctx.get<TestClass>();
              final b = ctx.get<TestClass>();
              return Text('${a.hashCode}-${b.hashCode}');
            },
          ),
        ),
      ),
    );
    // Only one instance should be created
    expect(TestClass.instanceCount, 1);
  });

  testWidgets('Dispose function is called for LazySingletonWidget', (tester) async {
    final disposable = DisposableClass();
    await tester.pumpWidget(
      MaterialApp(
        home: LazySingletonWidget<DisposableClass>(
          factory: (_) => disposable,
          dispose: disposable.dispose,
          child: const Placeholder(),
        ),
      ),
    );
    await tester.pumpWidget(const SizedBox.shrink()); // Unmount
    expect(DisposableClass.disposeCount, 1);
  });

  testWidgets('Dispose function is not called for InjectableWidget', (tester) async {
    final disposable = DisposableClass();
    await tester.pumpWidget(
      MaterialApp(
        home: InjectableWidget<DisposableClass>(
          factory: (_) => disposable,
          dispose: disposable.dispose,
          child: const Placeholder(),
        ),
      ),
    );
    await tester.pumpWidget(const SizedBox.shrink()); // Unmount
    expect(DisposableClass.disposeCount, 0);
  });

  testWidgets('InjectScopedNotifier rebuilds on ChangeNotifier notifyListeners', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: InjectableWidget<TestNotifier>(
          factory: (_) => TestNotifier(),
          child: InjectScopedNotifier<TestNotifier>(
            builder: (ctx, notifier) => Column(
              children: [
                Text('Value: ${notifier.value}', key: const Key('value')),
                ElevatedButton(
                  key: const Key('inc'),
                  onPressed: notifier.increment,
                  child: const Text('Increment'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    expect(find.text('Value: 0'), findsOneWidget);
    await tester.tap(find.byKey(const Key('inc')));
    await tester.pump();
    expect(find.text('Value: 1'), findsOneWidget);
  });

  testWidgets('InjectScopedNotifier disposes ChangeNotifier on widget dispose', (tester) async {
    final notifier = TestNotifier();
    await tester.pumpWidget(
      MaterialApp(
        home: InjectableWidget<TestNotifier>(
          factory: (_) => notifier,
          child: InjectScopedNotifier<TestNotifier>(
            builder: (ctx, n) => const Placeholder(),
          ),
        ),
      ),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    expect(notifier.disposeCount, 1);
  });

  testWidgets('InjectScopedNotifier provides the same instance via context.get within scope', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: InjectableWidget<TestNotifier>(
          factory: (_) => TestNotifier(),
          child: InjectScopedNotifier<TestNotifier>(
            builder: (ctx, notifier) {
              final fromContext = ctx.get<TestNotifier>();
              return Text('Same: ${identical(notifier, fromContext)}', key: const Key('same'));
            },
          ),
        ),
      ),
    );
    expect(find.text('Same: true'), findsOneWidget);
  });

  testWidgets('InjectScopedNotifier creates a new instance after widget is disposed and rebuilt', (tester) async {
    Widget buildTest() => MaterialApp(
      home: InjectableWidget<TestNotifier>(
        factory: (_) => TestNotifier(),
        child: InjectScopedNotifier<TestNotifier>(
          builder: (ctx, notifier) => Text('Hash: ${notifier.hashCode}', key: const Key('hash')),
        ),
      ),
    );
    await tester.pumpWidget(buildTest());
    final hash1 = (tester.widget(find.byKey(const Key('hash'))) as Text).data;
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(buildTest());
    final hash2 = (tester.widget(find.byKey(const Key('hash'))) as Text).data;
    expect(hash1 != hash2, isTrue);
  });

  testWidgets('InjectScopedNotifier does not rebuild when notifier does not notify', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: InjectableWidget<TestNotifier>(
          factory: (_) => TestNotifier(),
          child: InjectScopedNotifier<TestNotifier>(
            builder: (ctx, notifier) => Text('Value: ${notifier.value}', key: const Key('value')),
          ),
        ),
      ),
    );
    expect(find.text('Value: 0'), findsOneWidget);
    // No notifyListeners called, so value should remain 0
    await tester.pump();
    expect(find.text('Value: 0'), findsOneWidget);
  });
}
