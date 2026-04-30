import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import '../presentation/bloc/expense_bloc.dart';
import '../presentation/bloc/expense_event.dart';
import '../presentation/bloc/expense_state.dart';
import '../presentation/widgets/custom_detail_header.dart';
import '../presentation/widgets/custom_map_card.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final String expenseId;
  const ExpenseDetailScreen({super.key, required this.expenseId});

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  @override
  void initState() {
    super.initState();
    final currentState = BlocProvider.of<ExpenseBloc>(context).state;
    if(currentState is! ExpenseLoaded) {
      BlocProvider.of<ExpenseBloc>(context).add(LoadLogs());
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Apple Dark Mode background
      appBar: AppBar(
        // title: const Text('Expense Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return const Center(child: CircularProgressIndicator());
          } 
          
          if (state is ExpenseLoaded) {
            try {
              final expense = state.expenses.firstWhere(
                (e) => e.cloudId == widget.expenseId
              );

              final hasLocation = expense.latitude != 0.0 && expense.longitude != 0.0;
              final expenseLocation = LatLng(expense.latitude, expense.longitude);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomDetailHeader(expense: expense),
                  Expanded(
                    child: CustomMapCard(
                      hasLocation: hasLocation,
                      location: expenseLocation,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            } catch (e) {
              return _buildErrorUI('Expense not found or deleted.');
            }
          }

          return _buildErrorUI('Failed to load expense data.');
        },
      ),
    );
  }

  Widget _buildErrorUI(String message) {
    return Center(
      child: Text(
        message, 
        style: const TextStyle(color: Colors.white)
      ),
    );
  }
}
