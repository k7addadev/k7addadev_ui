import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'k7_fonts.dart';

/// A borderless form text field with a consistent look.
///
/// * Colors default to the ambient [ColorScheme] and can be overridden.
/// * Text and hint direction follow the ambient [Directionality], so the field
///   is right-to-left automatically in Arabic apps.
/// * [digitsOnly] and [maxLength] are enforced while typing (no counter shown).
/// * With [readOnly] the cursor is hidden and [onTap] can open a picker
///   (date, country, ...).
/// * Prefix and suffix icons sit in a fixed-width box so they line up across
///   fields.
///
/// Works inside a [Form]: pass a [validator] and call
/// `FormState.validate()`.
class K7TextField extends StatelessWidget {
  /// Creates a [K7TextField].
  const K7TextField({
    super.key,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.hintText,
    this.maxLength,
    this.digitsOnly = false,
    this.inputFormatters,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.readOnly = false,
    this.enabled,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.prefixIcon,
    this.suffixIcon,
    this.iconBoxWidth = 48,
    this.onChanged,
    this.onTap,
    this.onFieldSubmitted,
    this.validator,
    this.autovalidateMode,
    this.style,
    this.hintStyle,
    this.cursorColor,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 14),
    this.textDirection,
  })  : assert(controller == null || initialValue == null,
            'Pass either controller or initialValue, not both.'),
        assert(maxLength == null || maxLength > 0,
            'maxLength must be greater than 0.'),
        assert(!obscureText || maxLines == 1,
            'Obscured fields cannot be multiline.'),
        assert(iconBoxWidth >= 0 && iconBoxWidth < double.infinity,
            'iconBoxWidth must be a finite, non-negative number.');

  /// Controls the text being edited.
  final TextEditingController? controller;

  /// Initial text when no [controller] is given.
  final String? initialValue;

  /// Focus node for the field.
  final FocusNode? focusNode;

  /// Placeholder shown while the field is empty.
  final String? hintText;

  /// Maximum number of characters. Extra input is ignored and no counter is
  /// shown.
  final int? maxLength;

  /// Accept digits only. Arabic-Indic (٠-٩) and Persian (۰-۹) digits are
  /// converted to 0-9, everything else is dropped. Also switches the keyboard
  /// to numeric unless [keyboardType] is set.
  final bool digitsOnly;

  /// Extra formatters, applied after [digitsOnly] and [maxLength].
  final List<TextInputFormatter>? inputFormatters;

  /// Keyboard type. Defaults to numeric when [digitsOnly] is true, otherwise
  /// to Flutter's default for [maxLines].
  final TextInputType? keyboardType;

  /// Action button on the keyboard (next, done, search...).
  final TextInputAction? textInputAction;

  /// Automatic capitalization behaviour.
  final TextCapitalization textCapitalization;

  /// Autofill hints, e.g. [AutofillHints.email].
  final Iterable<String>? autofillHints;

  /// Display-only mode: the text cannot be edited or selected and the cursor
  /// is hidden. Combine with [onTap] to open a picker.
  final bool readOnly;

  /// Whether the field is enabled. Defaults to the enclosing decoration's
  /// setting (enabled).
  final bool? enabled;

  /// Hide the text (passwords).
  final bool obscureText;

  /// Maximum lines. Use `null` for unlimited growth.
  final int? maxLines;

  /// Minimum lines.
  final int? minLines;

  /// Widget shown at the start of the field (left in LTR, right in RTL).
  final Widget? prefixIcon;

  /// Widget shown at the end of the field (right in LTR, left in RTL).
  final Widget? suffixIcon;

  /// Width of the box holding [prefixIcon] and [suffixIcon]. The default (48)
  /// keeps an [IconButton] at its full touch-target size.
  final double iconBoxWidth;

  /// Called on every edit.
  final ValueChanged<String>? onChanged;

  /// Called when the field is tapped.
  final VoidCallback? onTap;

  /// Called when the user submits from the keyboard.
  final ValueChanged<String>? onFieldSubmitted;

  /// Returns an error message, or `null` if the value is valid.
  final FormFieldValidator<String>? validator;

  /// When to run [validator] automatically.
  final AutovalidateMode? autovalidateMode;

  /// Text style, merged over the default (Montserrat Arabic, 16, w600,
  /// `onSurface`, faded when the field is disabled). Set `fontFamily` here to
  /// use another font.
  final TextStyle? style;

  /// Hint style, merged over the default (Montserrat Arabic, 16, w600,
  /// `onSurfaceVariant`).
  final TextStyle? hintStyle;

  /// Cursor, selection and selection-handle color. Defaults to
  /// `ColorScheme.primary`.
  final Color? cursorColor;

  /// Padding around the text.
  final EdgeInsetsGeometry contentPadding;

  /// Direction of the typed text and the hint. Defaults to the ambient
  /// [Directionality] (the app's language).
  ///
  /// Use it to force one field, e.g. `TextDirection.ltr` for an email or URL
  /// field in an Arabic app. Icon and error placement still follow the app.
  final TextDirection? textDirection;

  static const TextStyle _baseStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle _bundledFont = TextStyle(
    fontFamily: K7Fonts.montserratArabic,
    package: K7Fonts.package,
  );

  /// Builds the final style. The bundled font is only applied when [custom]
  /// does not choose its own family; merging a family over a package style
  /// would otherwise keep the `packages/k7addadev_ui/` prefix.
  /// Opacity Material uses for disabled content.
  static const double _disabledOpacity = 0.38;

  static TextStyle _resolve(Color color, TextStyle? custom) {
    final base = custom?.fontFamily == null
        ? _baseStyle.merge(_bundledFont)
        : _baseStyle;
    return base.copyWith(color: color).merge(custom);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = cursorColor ?? colors.primary;
    final iconConstraints = BoxConstraints.tightFor(width: iconBoxWidth);
    final disabled = enabled == false;
    Color fade(Color c) =>
        disabled ? c.withValues(alpha: c.a * _disabledOpacity) : c;

    return TextSelectionTheme(
      data: TextSelectionThemeData(
        cursorColor: accent,
        selectionColor: accent.withValues(alpha: 0.25),
        selectionHandleColor: accent,
      ),
      child: TextFormField(
        controller: controller,
        initialValue: initialValue,
        focusNode: focusNode,
        readOnly: readOnly,
        enabled: enabled,
        showCursor: !readOnly,
        enableInteractiveSelection: !readOnly,
        obscureText: obscureText,
        maxLines: maxLines,
        minLines: minLines,
        keyboardType:
            keyboardType ?? (digitsOnly ? TextInputType.number : null),
        textInputAction: textInputAction,
        textCapitalization: textCapitalization,
        autofillHints: autofillHints,
        onTap: onTap,
        onChanged: onChanged,
        onFieldSubmitted: onFieldSubmitted,
        validator: validator,
        autovalidateMode: autovalidateMode,
        inputFormatters: [
          if (digitsOnly) ...[
            const _ArabicDigitsFormatter(),
            FilteringTextInputFormatter.digitsOnly,
          ],
          if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
          ...?inputFormatters,
        ],
        cursorColor: accent,
        textDirection: textDirection,
        style: _resolve(fade(colors.onSurface), style),
        decoration: InputDecoration(
          hintText: hintText,
          hintTextDirection: textDirection,
          hintStyle: _resolve(fade(colors.onSurfaceVariant), hintStyle),
          prefixIcon: prefixIcon == null ? null : Center(child: prefixIcon),
          prefixIconConstraints: iconConstraints,
          suffixIcon: suffixIcon == null ? null : Center(child: suffixIcon),
          suffixIconConstraints: iconConstraints,
          // Opt out of app-wide InputDecorationTheme fills and density so the
          // field keeps the same look everywhere.
          filled: false,
          isDense: false,
          isCollapsed: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: contentPadding,
        ),
      ),
    );
  }
}

/// Converts Arabic-Indic (U+0660-0669) and Persian (U+06F0-06F9) digits to
/// ASCII 0-9. Each digit maps to one code unit, so the selection is unchanged.
class _ArabicDigitsFormatter extends TextInputFormatter {
  const _ArabicDigitsFormatter();

  static int _ascii(int unit) {
    if (unit >= 0x0660 && unit <= 0x0669) return unit - 0x0660 + 0x30;
    if (unit >= 0x06F0 && unit <= 0x06F9) return unit - 0x06F0 + 0x30;
    return unit;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final units = newValue.text.codeUnits;
    final converted = String.fromCharCodes(units.map(_ascii));
    return converted == newValue.text
        ? newValue
        : newValue.copyWith(text: converted);
  }
}
