import 'package:drift/drift.dart';

import '../app_database.dart';
import '../table/doc_table.dart';

part 'doc_dao.g.dart';

@DriftAccessor(tables: [Docs])
class DocDao extends DatabaseAccessor<AppDatabase> with _$DocDaoMixin {
  DocDao(super.db);

  Future<int> createDoc({required String name, required DateTime createdAt}) {
    return into(
      docs,
    ).insert(DocsCompanion.insert(name: name, createdAt: createdAt));
  }

  Future<List<DocRow>> readDocs({String? search}) {
    final query = select(docs)..orderBy([(d) => OrderingTerm.asc(d.name)]);

    if (search != null && search.trim().isNotEmpty) {
      query.where((d) => d.name.contains(search.trim()));
    }

    return query.get();
  }

  Future<DocRow?> getDocById(int docId) {
    return (select(docs)..where((d) => d.id.equals(docId))).getSingleOrNull();
  }

  Future<bool> renameDoc({required int docId, required String newName}) async {
    final affectedRows = await (update(docs)..where((d) => d.id.equals(docId)))
        .write(DocsCompanion(name: Value(newName)));

    return affectedRows > 0;
  }

  Future<int> deleteDoc(int docId) {
    return (delete(docs)..where((d) => d.id.equals(docId))).go();
  }
}
