import 'package:accountable/backend/app_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class AddTransaction extends StatefulWidget {
  final String? initialAmount;
  final String? initialNotes;

  const AddTransaction({
    super.key,
    this.initialAmount,
    this.initialNotes,
  });

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  String transactionType = 'Withdraw';
  String? selectedCategory;
  DateTime? selectedDate;
  final List<String> categories = [
    'food',
    'personal',
    'utility',
    'transportation',
    'health',
    'leisure',
    'other'
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with passed data if available
    if (widget.initialAmount != null) {
      amountController.text = widget.initialAmount!;
    }
    if (widget.initialNotes != null) {
      notesController.text = widget.initialNotes!;
      // Attempt to automatically generate the category based on notes
      _autoGenerateCategory(widget.initialNotes!);
    }

    // Initialize date to today
    selectedDate = DateTime.now();
  }

  // Helper function to call generateCategory asynchronously
  Future<void> _autoGenerateCategory(String notes) async {
    // Create a temporary transaction object just for category generation
    // We need some dummy values for date and amount, they aren't used by generateCategory
    final tempTrans = Trans(
      transName: notes,
      transactionDate: DateTime.now(), // Dummy date
      amount: 0.0, // Dummy amount
      transType: TransactionType.other, // Start with default
    );

    await tempTrans.generateCategory(); // Call the Firestore function

    // Update the state if a category other than 'other' was generated
    if (tempTrans.transType != TransactionType.other) {
      setState(() {
        // Convert the generated enum back to the lowercase string used by the UI
        selectedCategory = transTypeToString(tempTrans.transType).toLowerCase();
        debugPrint("Automatically set category to: $selectedCategory");
      });
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void _showCategoryDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text('Select Category'),
          actions: categories.map((category) {
            return CupertinoActionSheetAction(
              onPressed: () {
                setState(() {
                  selectedCategory = category;
                });
                Navigator.pop(context);
              },
              child: Text(category),
            );
          }).toList(),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        );
      },
    );
  }

  void _showTransactionTypeDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text('Select Transaction Type'),
          actions: ['Deposit', 'Withdraw'].map((type) {
            return CupertinoActionSheetAction(
              onPressed: () {
                setState(() {
                  transactionType = type;
                });
                Navigator.pop(context);
              },
              child: Text(type),
            );
          }).toList(),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        );
      },
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
            initialDateTime: selectedDate ?? DateTime.now(),
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      navigationBar: CupertinoNavigationBar(
        previousPageTitle: 'Back',
        middle: const Text('Add Transaction'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Amount',
                  style: TextStyle(
                      fontSize: 16, color: CupertinoColors.systemGrey)),
              CupertinoTextField(
                controller: amountController,
                placeholder: 'Enter amount',
                suffix: const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Text('THB'),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Date',
                  style: TextStyle(
                      fontSize: 16, color: CupertinoColors.systemGrey)),
              GestureDetector(
                onTap: () => _showDatePicker(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: CupertinoColors.systemGrey3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedDate == null
                            ? 'Select Date'
                            : '${selectedDate!.toLocal()}'.split(' ')[0],
                      ),
                      const Icon(CupertinoIcons.calendar,
                          color: CupertinoColors.systemGrey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Notes',
                  style: TextStyle(
                      fontSize: 16, color: CupertinoColors.systemGrey)),
              CupertinoTextField(
                controller: notesController,
                placeholder: 'Enter notes',
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              const SizedBox(height: 20),
              const Text('Category',
                  style: TextStyle(
                      fontSize: 16, color: CupertinoColors.systemGrey)),
              GestureDetector(
                onTap: () => _showCategoryDialog(),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: CupertinoColors.systemGrey3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(selectedCategory ?? 'Select Category'),
                      const Icon(CupertinoIcons.chevron_down,
                          color: CupertinoColors.systemGrey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Transaction Type',
                  style: TextStyle(
                      fontSize: 16, color: CupertinoColors.systemGrey)),
              GestureDetector(
                onTap: () => _showTransactionTypeDialog(),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: CupertinoColors.systemGrey3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(transactionType),
                      const Icon(CupertinoIcons.chevron_down,
                          color: CupertinoColors.systemGrey),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: () {
                    if (amountController.text.isEmpty ||
                        selectedCategory == null) {
                      _showValidationError(
                          'Please fill in all required fields');
                      return;
                    }

                    final double amount =
                        double.tryParse(amountController.text) ?? 0.0;
                    // For withdraw, amount should be positive in display but negative in data
                    final double finalAmount =
                        transactionType == 'Withdraw' ? amount : amount;

                    // Convert the selected category string to TransactionType enum
                    final TransactionType transType =
                        stringToTransType(selectedCategory!);

                    // Create a new transaction object
                    final newTrans = Trans(
                      transName: notesController.text,
                      transactionDate: selectedDate ?? DateTime.now(),
                      amount: finalAmount,
                      transType: transType,
                    );

                    // Add to the list via the provider
                    Provider.of<TransList>(context, listen: false)
                        .addTransaction(newTrans);

                    // Navigate back
                    Navigator.pop(context);
                  },
                  child: const Text('Save Transaction'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showValidationError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
