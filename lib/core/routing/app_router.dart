import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_expense_tracker_app/features/expenses/presentation/add_expense_screen.dart';
import 'package:pocket_expense_tracker_app/features/expenses/presentation/home_screen.dart';
import 'package:pocket_expense_tracker_app/features/sync_station/presentation/sync_screen.dart';

final GoRouter appRouter = GoRouter(
    routes: [
        GoRoute(
            path: '/',
            builder: (BuildContext context, GoRouterState state) => const HomeScreen(),
        ),
        GoRoute(
            path:'/add-expense',
            builder: (BuildContext context, GoRouterState state) => const AddExpenseScreen(),
        ),
        GoRoute(
            path:'/sync',
            builder: (BuildContext context, GoRouterState state) => const SyncScreen(),
        )
    ]
);