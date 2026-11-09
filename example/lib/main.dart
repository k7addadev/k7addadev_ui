import 'package:flutter/material.dart';
import 'package:k7addadev_ui/k7addadev_ui.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  bool _arabic = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'k7addadev_ui example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      builder: (context, child) => Directionality(
        textDirection: _arabic ? TextDirection.rtl : TextDirection.ltr,
        child: child!,
      ),
      home: RegisterPage(
        arabic: _arabic,
        onToggleLanguage: () => setState(() => _arabic = !_arabic),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
    required this.arabic,
    required this.onToggleLanguage,
  });

  final bool arabic;
  final VoidCallback onToggleLanguage;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _birthDate = TextEditingController();
  bool _hidePassword = true;

  String _t(String ar, String en) => widget.arabic ? ar : en;

  @override
  void dispose() {
    _birthDate.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      _birthDate.text = date.toIso8601String().split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_t('إنشاء حساب', 'Register')),
        actions: [
          TextButton(
            onPressed: widget.onToggleLanguage,
            child: Text(_t('English', 'عربي')),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            K7TextField(
              hintText: _t('الاسم الكامل', 'Full name'),
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? _t('أدخل اسمك', 'Enter your name')
                  : null,
            ),
            const Divider(),
            K7TextField(
              hintText: _t('رقم الهاتف', 'Phone number'),
              digitsOnly: true,
              maxLength: 10,
              textInputAction: TextInputAction.next,
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
            const Divider(),
            // Emails read left-to-right even in an Arabic app.
            K7TextField(
              hintText: 'email@example.com',
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              textInputAction: TextInputAction.next,
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            const Divider(),
            K7TextField(
              hintText: _t('كلمة المرور', 'Password'),
              obscureText: _hidePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _hidePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() => _hidePassword = !_hidePassword),
              ),
              validator: (v) => (v == null || v.length < 8)
                  ? _t('٨ أحرف على الأقل', 'At least 8 characters')
                  : null,
            ),
            const Divider(),
            K7TextField(
              hintText: _t('تاريخ الميلاد', 'Birth date'),
              controller: _birthDate,
              readOnly: true,
              onTap: _pickDate,
              suffixIcon: const Icon(Icons.calendar_today_outlined),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => _formKey.currentState!.validate(),
              child: Text(_t('إنشاء الحساب', 'Create account')),
            ),
          ],
        ),
      ),
    );
  }
}
