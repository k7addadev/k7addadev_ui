# k7addadev_ui example

A small registration form that shows `K7TextField` in action:

- name with validation
- phone number (`digitsOnly`, `maxLength: 10`, Arabic digits converted)
- email forced to left-to-right inside an Arabic layout
- password with a show/hide `IconButton`
- read-only birth date that opens a date picker

The **English / عربي** button in the app bar switches the whole form between
LTR and RTL.

```bash
flutter run
```
