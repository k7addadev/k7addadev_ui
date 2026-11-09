import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:k7addadev_ui/k7addadev_ui.dart';

Widget _wrap(Widget child, {TextDirection direction = TextDirection.ltr}) {
  return MaterialApp(
    home: Directionality(
      textDirection: direction,
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  testWidgets('shows the hint text', (tester) async {
    await tester.pumpWidget(_wrap(const K7TextField(hintText: 'Phone')));
    expect(find.text('Phone'), findsOneWidget);
  });

  testWidgets('digitsOnly drops non-digits and uses a numeric keyboard',
      (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _wrap(K7TextField(controller: controller, digitsOnly: true)),
    );

    await tester.enterText(find.byType(TextField), '12ab3-4');
    expect(controller.text, '1234');

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.keyboardType, TextInputType.number);
  });

  testWidgets('maxLength limits input without showing a counter',
      (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _wrap(K7TextField(controller: controller, maxLength: 3)),
    );

    await tester.enterText(find.byType(TextField), 'abcdef');
    expect(controller.text, 'abc');
    expect(find.text('3/3'), findsNothing);
  });

  testWidgets('extra inputFormatters run after the built-in ones',
      (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _wrap(
        K7TextField(
          controller: controller,
          maxLength: 4,
          inputFormatters: [
            TextInputFormatter.withFunction(
              (_, value) => value.copyWith(text: value.text.toUpperCase()),
            ),
          ],
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'abcdef');
    expect(controller.text, 'ABCD');
  });

  testWidgets('readOnly hides the cursor, ignores typing and still fires onTap',
      (tester) async {
    var taps = 0;
    final controller = TextEditingController(text: '2026-01-01');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _wrap(
        K7TextField(
          controller: controller,
          readOnly: true,
          onTap: () => taps++,
        ),
      ),
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.showCursor, isFalse);

    await tester.tap(find.byType(TextField));
    expect(taps, 1);

    await tester.enterText(find.byType(TextField), 'changed');
    expect(controller.text, '2026-01-01');
  });

  testWidgets('validator error appears when the form is validated',
      (tester) async {
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(
      _wrap(
        Form(
          key: formKey,
          child: K7TextField(
            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Required'), findsOneWidget);
  });

  testWidgets('suffix icon sits at the end of the field in RTL',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 300,
          child: K7TextField(
            hintText: 'بحث',
            suffixIcon: Icon(Icons.search),
          ),
        ),
        direction: TextDirection.rtl,
      ),
    );

    final iconX = tester.getCenter(find.byIcon(Icons.search)).dx;
    final fieldX = tester.getCenter(find.byType(TextField)).dx;
    expect(iconX, lessThan(fieldX));
  });

  testWidgets('follows the app direction unless textDirection is set',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        const Column(
          children: [
            K7TextField(hintText: 'الاسم'),
            K7TextField(
              hintText: 'email@example.com',
              textDirection: TextDirection.ltr,
            ),
          ],
        ),
        direction: TextDirection.rtl,
      ),
    );

    final fields =
        tester.widgetList<TextField>(find.byType(TextField)).toList();
    final editables =
        tester.widgetList<EditableText>(find.byType(EditableText)).toList();

    // No override: both stay null and inherit the app's RTL direction.
    expect(fields[0].decoration!.hintTextDirection, isNull);
    expect(editables[0].textDirection, isNull);
    expect(
      Directionality.of(tester.element(find.byType(EditableText).first)),
      TextDirection.rtl,
    );

    expect(fields[1].decoration!.hintTextDirection, TextDirection.ltr);
    expect(editables[1].textDirection, TextDirection.ltr);
  });

  testWidgets('colors come from the theme and can be overridden',
      (tester) async {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.teal);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorScheme: scheme),
        home: const Scaffold(
          body: Column(
            children: [
              K7TextField(hintText: 'a'),
              K7TextField(cursorColor: Colors.red),
            ],
          ),
        ),
      ),
    );

    final fields =
        tester.widgetList<TextField>(find.byType(TextField)).toList();
    expect(fields[0].cursorColor, scheme.primary);
    expect(fields[0].style!.color, scheme.onSurface);
    expect(fields[0].decoration!.hintStyle!.color, scheme.onSurfaceVariant);
    expect(fields[1].cursorColor, Colors.red);
  });

  testWidgets('digitsOnly converts Arabic-Indic and Persian digits',
      (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _wrap(K7TextField(controller: controller, digitsOnly: true)),
    );

    await tester.enterText(find.byType(TextField), '٠٥x۱۲3');
    expect(controller.text, '05123');
  });

  testWidgets('ignores a filled InputDecorationTheme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Colors.red,
            isDense: true,
          ),
        ),
        home: const Scaffold(body: K7TextField()),
      ),
    );

    final decorator =
        tester.widget<InputDecorator>(find.byType(InputDecorator));
    expect(decorator.decoration.filled, isFalse);
    expect(decorator.decoration.isDense, isFalse);
  });

  testWidgets('disabled field fades its text and hint', (tester) async {
    final scheme = ThemeData().colorScheme;
    await tester.pumpWidget(
      _wrap(const K7TextField(enabled: false, hintText: 'x')),
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.style!.color!.a, closeTo(scheme.onSurface.a * 0.38, 0.01));
    expect(field.decoration!.hintStyle!.color!.a,
        closeTo(scheme.onSurfaceVariant.a * 0.38, 0.01));
  });

  testWidgets('IconButton keeps a 48dp touch target', (tester) async {
    await tester.pumpWidget(
      _wrap(
        K7TextField(
          suffixIcon: IconButton(icon: const Icon(Icons.add), onPressed: () {}),
        ),
      ),
    );

    final size = tester.getSize(find.byType(IconButton));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });

  testWidgets('readOnly disables text selection', (tester) async {
    await tester.pumpWidget(
      _wrap(const K7TextField(readOnly: true, initialValue: 'value')),
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.enableInteractiveSelection, isFalse);
  });

  testWidgets('uses the bundled font by default and allows overriding it',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        const Column(
          children: [
            K7TextField(),
            K7TextField(style: TextStyle(fontFamily: 'Roboto')),
          ],
        ),
      ),
    );

    final fields =
        tester.widgetList<TextField>(find.byType(TextField)).toList();
    expect(fields[0].style!.fontFamily,
        'packages/k7addadev_ui/MontserratArabic');
    expect(fields[1].style!.fontFamily, 'Roboto');
  });
}
