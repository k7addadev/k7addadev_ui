# k7addadev_ui

Reusable Flutter UI widgets. The first widget is **`K7TextField`**, a
borderless form text field with a consistent look that works in both LTR and
RTL (Arabic) apps.

## Features

- Borderless, clean style that ignores app-wide `InputDecorationTheme` fills.
  Colors come from your app's `ColorScheme` (faded when disabled), and you can
  override them.
- `digitsOnly` and `maxLength` are enforced while typing, with no counter shown.
  Arabic-Indic (٠-٩) and Persian (۰-۹) digits are converted to 0-9.
- `readOnly` mode hides the cursor, disables text selection and keeps `onTap`,
  which suits date and country pickers.
- Prefix and suffix icons sit in a fixed-width box, so they line up across
  fields.
- Text, hint and icons follow `Directionality` automatically, so the field
  flips in Arabic.
- Plugs into `Form` with `validator` and `autovalidateMode`.
- Bundles the **Montserrat Arabic** font (400, 500, 600 and 700) as the default.
  It covers Arabic and Latin, and you can switch it per field.
- Has no dependencies beyond Flutter (no state-management package required).

## Installation

```yaml
dependencies:
  k7addadev_ui: ^0.1.0
```

```dart
import 'package:k7addadev_ui/k7addadev_ui.dart';
```

## Usage

```dart
// Phone number: digits only, max 10
const K7TextField(
  hintText: 'Phone number',
  digitsOnly: true,
  maxLength: 10,
  prefixIcon: Icon(Icons.phone_outlined),
);

// Password with validation
K7TextField(
  hintText: 'Password',
  obscureText: true,
  validator: (v) => (v == null || v.length < 8) ? 'At least 8 characters' : null,
);

// Display-only field that opens a picker
K7TextField(
  hintText: 'Birth date',
  controller: birthDateController,
  readOnly: true,
  onTap: pickDate,
  suffixIcon: const Icon(Icons.calendar_today_outlined),
);
```

### Text direction

Fields follow the app's direction (`Directionality`) automatically. To force
one field, for example an email in an Arabic app, set `textDirection`. It
applies to the typed text and the hint; icons and errors still follow the app.

```dart
const K7TextField(
  hintText: 'email@example.com',
  keyboardType: TextInputType.emailAddress,
  textDirection: TextDirection.ltr,
);
```

### Customizing the style

```dart
K7TextField(
  hintText: 'Email',
  cursorColor: Colors.orange,
  style: const TextStyle(fontSize: 18),        // merged over the default
  hintStyle: const TextStyle(color: Colors.grey),
  contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
  iconBoxWidth: 56,
);
```

### Fonts

`K7TextField` uses the bundled Montserrat Arabic font by default. To use
another font, set `fontFamily` in `style` and `hintStyle`. To use the bundled
font elsewhere in your app:

```dart
const TextStyle(
  fontFamily: K7Fonts.montserratArabic,
  package: K7Fonts.package,
);
```

Montserrat Arabic is by Mohamed Gaber / Kief Type Foundry and is licensed under
the [SIL Open Font License 1.1](assets/fonts/OFL.txt). The bundled files are
version 5.008, taken unmodified from the official repository
[typeagm/Montserrat-Arabic](https://github.com/typeagm/Montserrat-Arabic).

The full sample is in [`example/lib/main.dart`](example/lib/main.dart).

## Main parameters

| Parameter | Description |
| --- | --- |
| `hintText` | Placeholder text |
| `controller` / `initialValue` | Field value (use one, not both) |
| `digitsOnly` | Accept digits only (Arabic digits become 0-9); switches to the numeric keyboard |
| `maxLength` | Character limit (no counter) |
| `inputFormatters` | Extra formatters, run after the built-in ones |
| `readOnly` + `onTap` | Display-only field with a tap action |
| `obscureText` | Hide input (passwords) |
| `prefixIcon` / `suffixIcon` / `iconBoxWidth` | Aligned icons (box width 48 by default) |
| `validator` / `autovalidateMode` | Form validation |
| `textDirection` | Force the text and hint direction for this field |
| `style` / `hintStyle` / `cursorColor` / `contentPadding` | Styling |
| `focusNode`, `textInputAction`, `onFieldSubmitted`, `autofillHints`, `maxLines`, `enabled` | Same as `TextFormField` |
