import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show
        PointSelection,
        ListTile,
        SimpleDialog,
        Chart,
        Container,
        Divider; // Import only Material components needed
import 'package:graphic/graphic.dart';
import 'package:provider/provider.dart';
import '../../backend/app_state.dart';
import 'package:intl/intl.dart'; // Import for DateFormat

// Helper function to get icon based on transaction type
IconData _getIconForTransactionType(TransactionType type) {
  switch (type) {
    case TransactionType.food:
      return CupertinoIcons.cart;
    case TransactionType.personal:
      return CupertinoIcons.person;
    case TransactionType.utility:
      return CupertinoIcons.lightbulb;
    case TransactionType.transportation:
      return CupertinoIcons.car;
    case TransactionType.health:
      return CupertinoIcons.bandage;
    case TransactionType.leisure:
      return CupertinoIcons.gamecontroller;
    case TransactionType.other:
      return CupertinoIcons.square_grid_2x2;
    default:
      return CupertinoIcons.square_grid_2x2; // Default fallback
  }
}

class BudgetSummaryScreen extends StatelessWidget {
  const BudgetSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transList = Provider.of<TransList>(context);
    final insights = transList.generateInsights();

   final chartData = insights.entries
    .where((entry) => entry.value > 0)
    .map((entry) => {
      'category': transTypeToString(entry.key),
      'amount': entry.value,
    }).toList();


    final insightListTiles =
        insights.entries.where((entry) => entry.value > 0).map((entry) {
      // Get the specific category type
      final categoryType = entry.key;
      // Filter transactions for this category
      final categoryTransactions = transList.transactions
          .where((trans) => trans.transType == categoryType)
          .toList();

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: CupertinoColors.systemGrey5, width: 0.5),
          ),
        ),
        child: GestureDetector(
          onTap: () {
            _showCategoryTransactions(
                context, categoryType, categoryTransactions);
          },
          child: Row(
            children: [
              Icon(_getIconForTransactionType(categoryType)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(transTypeToString(categoryType)),
              ),
              Text(entry.value.toStringAsFixed(2)),
            ],
          ),
        ),
      );
    }).toList();

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          children: [
            // Title text instead of navigation bar
            const Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 16.0),
              child: Text(
                'Budget Summary',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: CupertinoColors.systemBackground,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    chartData.isEmpty
                        ? const Center(
                            child: Text(
                                'No transaction data available for summary.'))
                        : SizedBox(
                            height: 200,
                            child: Container(
                              margin: const EdgeInsets.only(top: 10),
                              width: 350,
                              height: 300,
                              child: Chart(
                                data: chartData,
                                variables: {
                                  'category': Variable(
                                    accessor: (Map map) =>
                                        map['category'] as String,
                                  ),
                                  'amount': Variable(
                                    accessor: (Map map) => map['amount'] as num,
                                    scale: LinearScale(min: 0),
                                  ),
                                },
                                transforms: [
                                  Proportion(
                                    variable: 'amount',
                                    as: 'percent',
                                  )
                                ],
                                marks: [
                                  IntervalMark(
                                    position:
                                        Varset('percent') / Varset('category'),
                                    label: LabelEncode(
                                        encoder: (tuple) => Label(
                                              tuple['category'].toString(),
                                            )),
                                    color: ColorEncode(
                                        variable: 'category',
                                        values: Defaults.colors10),
                                    modifiers: [StackModifier()],
                                  )
                                ],
                                coord: PolarCoord(
                                  transposed: true,
                                  dimCount: 1,
                                  startRadius: 0.4,
                                ),
                                selections: {'tap': PointSelection()},
                              ),
                            ),
                          ),
                    const Divider(),
                    Expanded(
                      child: insightListTiles.isEmpty
                          ? const Center(child: Text('No spending details.'))
                          : ListView(
                              children: insightListTiles,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryTransactions(BuildContext context,
      TransactionType categoryType, List<Trans> transactions) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('${transTypeToString(categoryType)} Transactions'),
          content: transactions.isEmpty
              ? const Text('No transactions found.')
              : SizedBox(
                  height: 300,
                  child: SingleChildScrollView(
                    child: Column(
                      children: transactions.map((trans) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trans.transName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                DateFormat('yyyy-MM-dd')
                                    .format(trans.transactionDate),
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: CupertinoColors.systemGrey),
                              ),
                              Text(
                                '${trans.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const Divider(),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
