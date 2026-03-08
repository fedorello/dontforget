import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/medicines/presentation/pages/medicines_page.dart';
import '../../features/medicines/presentation/pages/add_medicine_page.dart';
import '../../features/medicines/presentation/pages/medicine_detail_page.dart';
import '../../features/shopping/presentation/pages/shopping_page.dart';
import '../../features/shopping/presentation/pages/shopping_list_page.dart';
import '../../features/todos/presentation/pages/todos_page.dart';
import '../../features/profiles/presentation/pages/profiles_page.dart';
import '../../features/profiles/presentation/pages/profile_form_page.dart';
import '../../shared/widgets/main_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/today',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(path: '/today', builder: (_, __) => const DashboardPage()),
        GoRoute(path: '/medicines', builder: (_, __) => const MedicinesPage()),
        GoRoute(path: '/shopping', builder: (_, __) => const ShoppingPage()),
        GoRoute(path: '/todos', builder: (_, __) => const TodosPage()),
      ],
    ),
    GoRoute(
      path: '/medicines/add',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const AddMedicinePage(),
    ),
    GoRoute(
      path: '/medicines/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) => MedicineDetailPage(id: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/shopping/:listId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) => ShoppingListPage(listId: state.pathParameters['listId']!),
    ),
    GoRoute(
      path: '/profiles',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const ProfilesPage(),
    ),
    GoRoute(
      path: '/profiles/new',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const ProfileFormPage(),
    ),
    GoRoute(
      path: '/profiles/:id/edit',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) => ProfileFormPage(profileId: state.pathParameters['id']),
    ),
  ],
);
