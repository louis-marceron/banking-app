import 'package:banking_app/features/transaction/transaction_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:banking_app/features/transaction/transaction_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../common_widgets/snackbar/info_floating_snackbar.dart';
import './category_icons.dart';

class EditTransactionView extends StatefulWidget {
  final String? transactionId;

  EditTransactionView({Key? key, this.transactionId}) : super(key: key);

  @override
  _EditTransactionViewState createState() => _EditTransactionViewState();
}

class _EditTransactionViewState extends State<EditTransactionView> {
  late TransactionViewModel _transactionController;
  late Transaction? _transaction;
  late String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
  _transactionController = Provider.of<TransactionViewModel>(context, listen: false);
  _transactionController.fetchTransactionsForCurrentUser();
}

@override
Widget build(BuildContext context) {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  return Scaffold(
    appBar: AppBar(
      title: Text('Edit Transaction'),
      ),
      body: Center(
        child: FutureBuilder<Transaction?>(
          future: _transactionController.getTransactionById(userId ?? "", widget.transactionId ?? ""),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              _transaction = snapshot.data;

              // Prefill text controllers with transaction data
              if (_transaction != null) {
                _transactionController.labelController.text = _transaction!.label;
                _transactionController.amountController.text = _transaction!.amount.toString();
                _transactionController.categoryController.text = _transaction!.category ?? '';
                _transactionController.typeController.text = _transaction!.type;
                _transactionController.bankNameController.text = _transaction!.bankName;
                _transactionController.dateController.text = _transaction!.date.toString();
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextField(
                      controller: _transactionController.labelController,
                      decoration: InputDecoration(
                        labelText: 'Label',
                      ),
                    ),
                    TextField(
                      controller: _transactionController.amountController,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                      ),
                    ),
                    Consumer<TransactionViewModel>(
                      builder: (context, transactionController, _) {
                        //FIXME Default value of the segmented button is not set
                        return SegmentedButton(
                          style: SegmentedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            selectedBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          ),
                          segments: [
                            ButtonSegment(
                              value: "Expense",
                              label: Text('Expense'),
                              icon: Icon(Icons.remove),
                            ),
                            ButtonSegment(
                              value: "Income",
                              label: Text('Income'),
                              icon: Icon(Icons.add),
                            ),
                          ],
                          selected: transactionController.selectedTransactionType,
                          onSelectionChanged: (selected) {
                            transactionController.updateSelectedTransactionType(selected);
                            transactionController.notify();
                          },
                          emptySelectionAllowed: false,
                        );
                      },
                    ),
                    TextField(
                      controller: _transactionController.bankNameController,
                      decoration: InputDecoration(
                        labelText: 'Bank Name',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.pushNamed('categories').then((selectedCategory) {
                          if (selectedCategory != null) {
                            setState(() {
                              print('Selected category: $selectedCategory');
                              _selectedCategory = selectedCategory as String;
                            });
                          }
                        });
                      },
                      child: Icon(
                        categoryIcons[_selectedCategory] ?? Icons.error,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // Show date picker to select a new date
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: _transactionController.dateController.text.isNotEmpty
                              ? DateTime.tryParse(_transactionController.dateController.text) ?? DateTime.now()
                              : DateTime.now(),
                          firstDate: DateTime(DateTime.now().year - 1),
                          lastDate: DateTime(DateTime.now().year + 2),
                        );

                        // Update selected date in ViewModel
                        if (selectedDate != null) {
                          print('Selected date: $selectedDate');
                          _transactionController.updateSelectedDate(selectedDate);
                        } else {
                          print('No date selected');
                          print(_transactionController.dateController.text.isNotEmpty
                              ? DateTime.tryParse(_transactionController.dateController.text) ?? DateTime.now()
                              : DateTime.now());
                        }
                      },
                      child: Icon(Icons.calendar_today),
                    ),
                    ElevatedButton(
                      onPressed: () {

                        _transactionController.categoryController.text = _selectedCategory;

                        print(_transactionController.categoryController.text);

                        // Create the updated transaction object using ViewModel method
                        final updatedTransaction = _transactionController.createUpdatedTransaction(_transaction!, _transactionController);

                        // Call the updateTransaction method from the ViewModel
                        _transactionController.updateTransaction(userId ?? "", updatedTransaction);

                        _transactionController.fetchTransactionsForCurrentUser();

                        InfoFloatingSnackbar.show(context, 'Transaction modified');

                        // Navigate back to the previous screen
                          context.go("/transactions");
                      },
                      child: Text('Update Transaction'),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}