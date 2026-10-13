import 'package:drift/drift.dart';
import 'package:glyph/data/database/table/doc_table.dart';

@DataClassName('PageRow')
@TableIndex(name: 'pages_doc_position_idx', columns: {#docId, #position})
class Pages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get position => integer()();
  IntColumn get docId =>
      integer().references(Docs, #id, onDelete: KeyAction.cascade)();
  TextColumn get imagePath => text()();
  TextColumn get recognizedText => text()();
  TextColumn get editedText => text()();
  DateTimeColumn get createdAt => dateTime()();
}
