import 'package:drift/drift.dart';

import '../app_database.dart';
import '../table/page_table.dart';

part 'page_dao.g.dart';

@DriftAccessor(tables: [Pages])
class PageDao extends DatabaseAccessor<AppDatabase> with _$PageDaoMixin {
  PageDao(super.db);

  Future<int> createPage({
    required int docId,
    required String imagePath,
    required String recognizedText,
    required DateTime createdAt,
  }) {
    return transaction(() async {
      final lastPage =
          await (select(pages)
                ..where((p) => p.docId.equals(docId))
                ..orderBy([(p) => OrderingTerm.desc(p.position)])
                ..limit(1))
              .getSingleOrNull();

      final nextPosition = (lastPage?.position ?? -1) + 1;

      return into(pages).insert(
        PagesCompanion.insert(
          docId: docId,
          position: Value(nextPosition) as int,
          imagePath: imagePath,
          recognizedText: recognizedText,
          editedText: recognizedText,
          createdAt: createdAt,
        ),
      );
    });
  }

  Future<List<PageRow>> readPages({int? docId, String? search}) {
    final query = select(pages)
      ..where((p) {
        final docCondition = docId == null
            ? const Constant(true)
            : p.docId.equals(docId);

        final normalizedSearch = search?.trim();
        final textCondition =
            normalizedSearch == null || normalizedSearch.isEmpty
            ? const Constant(true)
            : p.editedText.contains(normalizedSearch);

        return docCondition & textCondition;
      })
      ..orderBy([
        (p) => OrderingTerm.asc(p.docId),
        (p) => OrderingTerm.asc(p.position),
      ]);

    return query.get();
  }

  Future<PageRow?> getPageById(int pageId) {
    return (select(pages)..where((p) => p.id.equals(pageId))).getSingleOrNull();
  }

  // Сохраняет пользовательскую редакцию.
  Future<bool> editText({required int pageId, required String newText}) async {
    final affectedRows =
        await (update(pages)..where((p) => p.id.equals(pageId))).write(
          PagesCompanion(editedText: Value(newText)),
        );

    return affectedRows > 0;
  }

  Future<bool> resetText({required int pageId}) async {
    final page = await getPageById(pageId);
    if (page == null) return false;

    return editText(pageId: pageId, newText: page.recognizedText);
  }

  Future<int> deletePage(int pageId) {
    return (delete(pages)..where((p) => p.id.equals(pageId))).go();
  }

  Future<bool> movePage({required int pageId, required int newPosition}) async {
    return transaction(() async {
      final page = await getPageById(pageId);
      if (page == null) return false;

      final oldPosition = page.position;
      if (oldPosition == newPosition) return true;

      final docId = page.docId;

      if (newPosition < oldPosition) {
        // Сдвигаем вправо страницы между новой и старой позициями.
        await (update(pages)..where(
              (p) =>
                  p.docId.equals(docId) &
                  p.position.isBiggerOrEqualValue(newPosition) &
                  p.position.isSmallerThanValue(oldPosition),
            ))
            .write(
              PagesCompanion.custom(
                position: pages.position + const Constant(1),
              ),
            );
      } else {
        // Сдвигаем влево страницы между старой и новой позициями.
        await (update(pages)..where(
              (p) =>
                  p.docId.equals(docId) &
                  p.position.isBiggerThanValue(oldPosition) &
                  p.position.isSmallerOrEqualValue(newPosition),
            ))
            .write(
              PagesCompanion.custom(
                position: pages.position - const Constant(1),
              ),
            );
      }

      // Ставим перемещаемую страницу на новую позицию.
      await (update(pages)..where((p) => p.id.equals(pageId))).write(
        PagesCompanion(position: Value(newPosition)),
      );

      return true;
    });
  }
}
