import 'dart:ui';

import 'package:budget_tracker/models/failure_model.dart';
import 'package:budget_tracker/repositories/budget_repository.dart';
import 'package:budget_tracker/spending_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

import 'models/item_model.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: BudgetScreen(),
    );
  }
}

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final BudgetRepository _budgetRepository = BudgetRepository();
  late Future<List<Item>> _futureItems;

  @override
  void initState() {
    super.initState();
    _futureItems = _budgetRepository.getItems();
  }

  @override
  void dispose() {
    _budgetRepository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Tracker'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _futureItems = _budgetRepository.getItems();
          setState(() {});
        },
        child: SafeArea(
          child: Stack(
            children: [
              FutureBuilder(
                initialData: const <Item>[],
                future: _futureItems,
                builder: (context, AsyncSnapshot<List<Item>> snapshot) {
                  if (snapshot.hasData) {
                    final items = snapshot.data ?? <Item>[];
                    return ListView.builder(
                      itemCount: items.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) return SpendingChart(items: items);

                        final item = items[index - 1];
                        return Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              width: 2,
                              color: getCategoryColor(item.category),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 6),
                            ],
                          ),
                          child: ListTile(
                            title: Text(item.name),
                            subtitle: Text(
                                '${item.category} - ${DateFormat('MMM dd, yyyy').format(item.date)}'),
                            trailing:
                                Text('Ksh ${item.price.toStringAsFixed(2)}'),
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    final failure = snapshot.error as Failure;
                    return Center(
                      child: Text(failure.message),
                    );
                  }

                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
              Positioned(
                bottom: 15,
                right: 15,
                child: FloatingActionButton(
                  elevation: 5,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Column(
                          children: [
                            Center(
                              child: Text("hello world"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Image.asset('assets/images/add_icon.png'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color getCategoryColor(String category) {
  switch (category) {
    case 'Entertainment':
      return Colors.red[400]!;
    case 'Food':
      return Colors.green[400]!;
    case 'Personal':
      return Colors.blue[400]!;
    case 'Transportation':
      return Colors.purple[400]!;
    default:
      return Colors.orange[400]!;
  }
}
