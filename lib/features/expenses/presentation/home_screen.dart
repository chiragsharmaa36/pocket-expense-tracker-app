import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/expense.dart';
import '../ui/expense_detail_screen.dart';
import 'add_expense_screen.dart';
import 'bloc/expense_bloc.dart';
import 'bloc/expense_state.dart';
import 'widgets/expense_chart.dart';
import 'widgets/expense_list_tile.dart';

enum ExpenseFilter { last24Hours, thisWeek, thisMonth }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ExpenseFilter _currentFilter = ExpenseFilter.thisWeek;

  Map<String, double> _generateChartData(List<Expense> expenses, ExpenseFilter filter) {
    final now = DateTime.now();
    Map<String, double> data = {};

    if (filter == ExpenseFilter.last24Hours) {
      final startTime = now.subtract(const Duration(hours: 24));
      final recent = expenses.where((e) => e.timestamp.isAfter(startTime));
      
      for (int i = 0; i < 6; i++) {
        final chunkStart = startTime.add(Duration(hours: i * 4));
        final label = '${chunkStart.hour}:00';
        data[label] = 0.0;
      }

      for (var e in recent) {
        final diffHours = e.timestamp.difference(startTime).inHours;
        final chunkIndex = (diffHours / 4).floor().clamp(0, 5);
        final chunkStart = startTime.add(Duration(hours: chunkIndex * 4));
        final label = '${chunkStart.hour}:00';
        data[label] = (data[label] ?? 0) + e.amount;
      }
    } else if (filter == ExpenseFilter.thisWeek) {
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startTime = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      final weekExpenses = expenses.where((e) => e.timestamp.isAfter(startTime));
      
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      for (var day in days) {
        data[day] = 0.0;
      }
      for (var e in weekExpenses) {
        final dayName = days[e.timestamp.weekday - 1];
        data[dayName] = (data[dayName] ?? 0) + e.amount;
      }
    } else if (filter == ExpenseFilter.thisMonth) {
      final startTime = DateTime(now.year, now.month, 1);
      final monthExpenses = expenses.where((e) => e.timestamp.isAfter(startTime));
      
      data = {'Week 1': 0, 'Week 2': 0, 'Week 3': 0, 'Week 4+': 0};
      for (var e in monthExpenses) {
        final day = e.timestamp.day;
        if (day <= 7) data['Week 1'] = (data['Week 1'] ?? 0) + e.amount;
        else if (day <= 14) data['Week 2'] = (data['Week 2'] ?? 0) + e.amount;
        else if (day <= 21) data['Week 3'] = (data['Week 3'] ?? 0) + e.amount;
        else data['Week 4+'] = (data['Week 4+'] ?? 0) + e.amount;
      }
    }

    return data;
  }

  List<Expense> _getFilteredExpenses(List<Expense> all, ExpenseFilter filter) {
    final now = DateTime.now();
    List<Expense> filtered;
    if (filter == ExpenseFilter.last24Hours) {
      final startTime = now.subtract(const Duration(hours: 24));
      filtered = all.where((e) => e.timestamp.isAfter(startTime)).toList();
    } else if (filter == ExpenseFilter.thisWeek) {
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startTime = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      filtered = all.where((e) => e.timestamp.isAfter(startTime)).toList();
    } else if (filter == ExpenseFilter.thisMonth) {
      final startTime = DateTime(now.year, now.month, 1);
      filtered = all.where((e) => e.timestamp.isAfter(startTime)).toList();
    } else {
      filtered = List.from(all);
    }
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Apple Dark Mode pure black background
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFBF5AF2), // Apple Purple
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => const AddExpenseScreen(),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        buildWhen: (previousState, currentState) {
          return currentState is! ExpenseActionSuccess;
        },
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return const Center(child: CupertinoActivityIndicator());
          }

          if (state is ExpenseError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.white)));
          }

          if (state is ExpenseLoaded) {
            final filteredExpenses = _getFilteredExpenses(state.expenses, _currentFilter);
            final chartData = _generateChartData(state.expenses, _currentFilter);

            return CustomScrollView(
              slivers: [
                const SliverAppBar(
                  expandedHeight: 120.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.black,
                  surfaceTintColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: false,
                    title: Text(
                      'Vault', 
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    titlePadding: EdgeInsets.only(left: 16, bottom: 16),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: CupertinoSlidingSegmentedControl<ExpenseFilter>(
                      backgroundColor: const Color(0xFF1C1C1E),
                      thumbColor: const Color(0xFF3A3A3C),
                      groupValue: _currentFilter,
                      children: const {
                        ExpenseFilter.last24Hours: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('24h', style: TextStyle(color: Colors.white)),
                        ),
                        ExpenseFilter.thisWeek: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('Week', style: TextStyle(color: Colors.white)),
                        ),
                        ExpenseFilter.thisMonth: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('Month', style: TextStyle(color: Colors.white)),
                        ),
                      },
                      onValueChanged: (ExpenseFilter? value) {
                        if (value != null) {
                          setState(() {
                            _currentFilter = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ExpenseChart(data: chartData),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
                    child: Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (filteredExpenses.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          'No expenses found.',
                          style: TextStyle(color: CupertinoColors.systemGrey),
                        ),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final expenseListTile = filteredExpenses[index];
                        return ExpenseListTile(
                          expense: expenseListTile,
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => ExpenseDetailScreen(expenseId: expenseListTile.cloudId!),
                              ),
                            );
                          },
                        );
                      },
                      childCount: filteredExpenses.length,
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100), // Extra padding for FAB
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
