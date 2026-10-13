import 'package:drift/drift.dart';

@DataClassName('DocRow')
class Docs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  DateTimeColumn get createdAt => dateTime()();
}
