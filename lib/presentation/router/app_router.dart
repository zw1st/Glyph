import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/doc_model.dart';
import '../../domain/repo_interface/page_repo_interface.dart';
import '../../utils/di.dart';
import '../screens/doc_screen/cubit/doc_cubit.dart';
import '../screens/doc_screen/doc_screen.dart';
import '../screens/home_screen/cubit/home_cubit.dart';
import '../screens/home_screen/home_screen.dart';
import '../screens/page_screen/cubit/page_cubit.dart';
import '../screens/page_screen/page_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) {
        return BlocProvider(
          create: (_) => locator<HomeCubit>()..loadDocs(),
          child: HomeScreen(
            onDocTap: (doc) {
              context.pushNamed(
                'doc',
                pathParameters: {'docId': doc.id.toString()},
                extra: doc,
              );
            },
          ),
        );
      },
    ),
    GoRoute(
      path: '/docs/:docId',
      name: 'doc',
      builder: (context, state) {
        final docId = int.parse(state.pathParameters['docId']!);

        final doc = state.extra as DocModel?;
        final docName = doc?.name ?? 'Документ';

        return BlocProvider(
          create: (_) =>
              DocCubit(pageRepo: locator<PageRepoInterface>(), docId: docId)
                ..loadPages(),
          child: DocScreen(
            docId: docId,
            docName: docName,
            onEditPage: (page) {
              context.pushNamed(
                'page',
                pathParameters: {'pageId': page.id.toString()},
                extra: doc,
              );
            },
          ),
        );
      },
    ),
    GoRoute(
      path: '/pages/:pageId',
      name: 'page',
      builder: (context, state) {
        final pageId = int.parse(state.pathParameters['pageId']!);

        return BlocProvider(
          create: (_) =>
              PageCubit(pageRepo: locator<PageRepoInterface>(), pageId: pageId)
                ..loadPage(),
          child: PageScreen(pageId: pageId),
        );
      },
    ),
  ],
);
