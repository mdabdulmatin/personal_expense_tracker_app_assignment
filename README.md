# Expense Tracker

A Flutter personal expense tracker. Transactions are stored locally in SQLite, so the records remain available after the app is closed and reopened.

## Features

- Dashboard with total income, total expense and current balance.
- Recent transactions and a complete transaction list.
- Add and edit income or expense records.
- Separate categories for income and expenses.
- Transaction date selection and input validation.
- Transaction details and delete confirmation.
- Automatic dashboard recalculation after every database change.
- Pull-to-refresh on the dashboard and transaction list.

## Packages

- `sqflite` — local SQLite database.
- `path` — database file path handling.
- `provider` — app state management.
- `intl` — date and amount formatting.

## Requirements

- Flutter 3.47.0 or later (the Android project uses AGP 9 built-in Kotlin).
- Dart 3.13.7 or later, as specified in `pubspec.yaml`.

## Run the project

1. Make sure Flutter and Android Studio are installed.
2. Open this project folder in your IDE.
3. Run `flutter pub get` in the project terminal.
4. Connect an Android device or start an emulator.
5. Run `flutter run`.

The Flutter tool generates the machine-specific `android/local.properties` file when the project is configured on your computer. Do not copy a `local.properties` file from another computer.

## Database

- Database: `expense_tracker.db`
- Table: `transactions`
- Columns: `id`, `title`, `amount`, `category`, `type`, `date`

Transaction dates are stored as `YYYY-MM-DD`, which also allows them to be sorted chronologically in SQLite.
