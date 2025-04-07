import 'package:accountable/backend/app_state.dart';
import 'package:accountable/presentation/pages/transaction_details_screen.dart';
import 'package:accountable/presentation/pages/addTransaction.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show DateUtils;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final String detailsPath;

  const HomePage({super.key, required this.detailsPath});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime selectedDate = DateTime.now();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransList>(context, listen: false).getTransactionsFromDB();
    });
  }

  IconData _getIconForType(TransactionType type) {
    switch (type) {
      case TransactionType.food:
        return CupertinoIcons.cart;
      case TransactionType.personal:
        return CupertinoIcons.person;
      case TransactionType.utility:
        return CupertinoIcons.lightbulb;
      case TransactionType.transportation:
        return CupertinoIcons.bus;
      case TransactionType.health:
        return CupertinoIcons.bandage;
      case TransactionType.leisure:
        return CupertinoIcons.film;
      case TransactionType.other:
      default:
        return CupertinoIcons.square_grid_2x2;
    }
  }

  String getFormattedDate(DateTime date) {
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String getMonthName(int month) {
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  List<DailyTransList> getAllDaysInMonth(AppState appState, DateTime date) {
    final year = date.year;
    final month = date.month;
    final lastDay = DateUtils.getDaysInMonth(year, month);

    List<DailyTransList> allDays = [];

    for (int day = 1; day <= lastDay; day++) {
      final dateForDay = DateTime(year, month, day);
      final dailyList = appState.getDailyTransList(dateForDay);
      if (dailyList.transactions.isNotEmpty) {
        allDays.add(dailyList);
      }
    }

    return allDays;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          Consumer<TransList>(
            builder: (context, transList, child) {
              final appState = AppState();
              appState.transList = transList;

              final allDailyTrans = getAllDaysInMonth(appState, selectedDate);
              debugPrint("DailyTransList for month: $allDailyTrans");

              // Monthly total
              final totalExpense = allDailyTrans
                  .expand((day) => day.transactions)
                  .fold(0.0, (sum, t) => sum + t.amount)
                  .toStringAsFixed(2);

              return SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Month selection controls
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey6,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                child: const Icon(CupertinoIcons.left_chevron),
                                onPressed: () {
                                  setState(() {
                                    selectedDate = DateTime(
                                      selectedDate.year,
                                      selectedDate.month - 1,
                                    );
                                  });
                                },
                              ),
                              GestureDetector(
                                onTap: () async {
                                  _showDatePicker(context);
                                },
                                child: Text(
                                  '${getMonthName(selectedDate.month)} ${selectedDate.year}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                child: const Icon(CupertinoIcons.right_chevron),
                                onPressed: () {
                                  setState(() {
                                    selectedDate = DateTime(
                                      selectedDate.year,
                                      selectedDate.month + 1,
                                    );
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemIndigo,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Monthly Total: $totalExpense',
                            style: const TextStyle(
                                fontSize: 24, color: CupertinoColors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (allDailyTrans.isEmpty)
                          const Center(
                              child: Text("No transactions for this month.",
                                  style: TextStyle(
                                      color: CupertinoColors.systemGrey)))
                        else
                          ...allDailyTrans.map((dailyList) {
                            final dayTotal = dailyList.transactions
                                .fold(0.0, (sum, t) => sum + t.amount)
                                .toStringAsFixed(2);

                            final expenseWidgets =
                                dailyList.transactions.map((trans) {
                              return _buildExpenseItem(
                                icon: _getIconForType(trans.transType),
                                title: transTypeToString(trans.transType),
                                subtitle: trans.transName,
                                amount: trans.amount.toStringAsFixed(2),
                                context: context,
                                transaction: trans,
                              );
                            }).toList();

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildDayExpense(
                                day: getFormattedDate(dailyList.getDate()),
                                totalExpense: dayTotal,
                                expenses: expenseWidgets,
                              ),
                            );
                          }).toList(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Floating Action Button
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: CupertinoColors.systemIndigo,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.systemGrey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).push(
                    CupertinoPageRoute(
                      builder: (context) => const AddTransaction(),
                    ),
                  );
                },
                child: const Icon(
                  CupertinoIcons.add,
                  color: CupertinoColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDatePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 300,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: selectedDate,
            onDateTimeChanged: (DateTime newDate) {
              setState(() {
                selectedDate = newDate;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildDayExpense({
    required String day,
    required String totalExpense,
    required List<Widget> expenses,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemIndigo.darkHighContrastColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                day,
                style:
                    const TextStyle(fontSize: 16, color: CupertinoColors.white),
              ),
              Row(
                children: [
                  const Icon(CupertinoIcons.arrow_up,
                      size: 16, color: CupertinoColors.white),
                  Text(
                    'Expense $totalExpense',
                    style: const TextStyle(
                        fontSize: 14, color: CupertinoColors.white),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...expenses,
        ],
      ),
    );
  }

  Widget _buildExpenseItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
    required BuildContext context,
    Trans? transaction,
  }) {
    return GestureDetector(
      onTap: () {
        if (transaction != null) {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (context) => TransactionDetailScreen(
                transaction: transaction,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(40, 0, 0, 20),
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 25),
        decoration: BoxDecoration(
          color: CupertinoColors.systemIndigo.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: CupertinoColors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, color: CupertinoColors.white)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 14, color: CupertinoColors.white)),
                ],
              ),
            ),
            Text(amount,
                style: const TextStyle(
                    fontSize: 16, color: CupertinoColors.white)),
          ],
        ),
      ),
    );
  }
}
