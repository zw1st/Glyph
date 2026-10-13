import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:glyph/data/database/table/doc_table.dart';
import 'package:glyph/data/database/table/page_table.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'dao/doc_dao.dart';
import 'dao/page_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Docs, Pages], daos: [DocDao, PageDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationSupportDirectory();
    final file = File(p.join(directory.path, 'app.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}
