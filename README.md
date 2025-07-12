# Mini-POS Checkout Core

A headless checkout engine in Dart using BLoC, designed for POS/ESS apps. No UI, no database, no plugins—pure business logic, fully unit-tested.

## Requirements
- Flutter 3.7.2
- Dart 3.7.2

## Features
- Static product catalog loaded from `assets/catalog.json`
- CartBloc: add/remove/change qty/discount, clear cart
- Business rules: VAT (15%), per-line discount, running totals
- Undo/redo last N cart actions
- Hydration: CartBloc state survives restart
- 100% line coverage (see below)
- Money extension: `num.get asMoney ⇒ "12.34"`
- Pure function receipt builder
- All state is immutable and value-based

## Folder Structure
```
lib/
  src/
    catalog/
      item.dart
      catalog_bloc.dart
    cart/
      models.dart
      cart_bloc.dart
      receipt.dart
    util/
      money_extension.dart
assets/
  catalog.json
```

## Setup & Testing
1. Install dependencies:
   ```sh
   flutter pub get
   ```
2. Run all tests:
   ```sh
   flutter test --coverage
   ```
3. View coverage report (optional):
   ```sh
   genhtml coverage/lcov.info -o coverage/html
   open coverage/html/index.html
   ```

## Time Spent
- ~2.5 hours (including nice-to-haves and coverage)

## Finished Items
- All must-have requirements (CatalogBloc, CartBloc, business rules, receipt builder, tests, code quality)
- All nice-to-have features (undo/redo, hydration, 100% coverage, money extension)

## Notes
- No UI, no database, no plugins—logic only
- All classes public under `lib/src/...` for testability
- See tests in `test/` for usage examples

---
Happy coding!
