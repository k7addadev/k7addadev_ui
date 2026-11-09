## 0.1.0

* Initial release with `K7TextField`: a borderless form text field with
  digits-only and length limits, read-only tap mode, aligned prefix and suffix
  icons, theme-based colors, automatic RTL support with a per-field
  `textDirection` override, and the bundled Montserrat Arabic font.
* `digitsOnly` converts Arabic-Indic and Persian digits to 0-9.
* Disabled fields fade their text and hint; read-only fields disable text
  selection; icon boxes are 48 wide so an `IconButton` keeps its touch target;
  app-wide `InputDecorationTheme` fills and density are ignored.
