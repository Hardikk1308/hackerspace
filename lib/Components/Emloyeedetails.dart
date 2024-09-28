import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

class EmployeesScreen extends StatefulWidget {
  @override
  _EmployeesScreenState createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  final String backendUrl = 'https://diamtestnet.diamcircle.io/';
  List<Employee> employees = [
    Employee(id: '1', name: 'John Doe', role: 'Developer', wallet: 'DIAM123456', balance: 0),
    Employee(id: '2', name: 'Jane Smith', role: 'Designer', wallet: 'DIAM789012', balance: 0),
    Employee(id: '3', name: 'Mike Johnson', role: 'Manager', wallet: 'DIAM345678', balance: 0),
  ];

  bool _isBulkFunding = false;
  bool _isSingleFunding = false;

  Future<void> _sendBulkDIAM() async {
    final TextEditingController _amountController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Send DIAM to All Employees'),
          content: SingleChildScrollView(
            child: TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Total Amount to Send',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Send'),
              onPressed: () async {
                final amountText = _amountController.text.trim();
                final amount = double.tryParse(amountText);

                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid amount')),
                  );
                  return;
                }

                bool confirm = await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Confirm Bulk Payment'),
                      content: Text('Send $amount DIAM to all employees?'),
                      actions: [
                        TextButton(child: const Text('No'), onPressed: () => Navigator.of(context).pop(false)),
                        ElevatedButton(child: const Text('Yes'), onPressed: () => Navigator.of(context).pop(true)),
                      ],
                    );
                  },
                );

                if (confirm) {
                  Navigator.of(context).pop();
                  await _makeBulkPayment(amount);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE94560),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _makeBulkPayment(double totalAmount) async {
    setState(() {
      _isBulkFunding = true;
    });

    try {
      List<String> employeeAddresses = employees.map((e) => e.wallet).toList();
      List<Transaction> transactions = await distributeCryptoCurrency(totalAmount, employeeAddresses);

      setState(() {
        for (var tx in transactions) {
          final employeeIndex = employees.indexWhere((e) => e.wallet == tx.recipientAddress);
          if (employeeIndex != -1) {
            employees[employeeIndex].balance += tx.amount;
          }
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bulk Payment Successful')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending bulk DIAM: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isBulkFunding = false;
      });
    }
  }

  Future<List<Transaction>> distributeCryptoCurrency(double totalAmount, List<String> employeeAddresses) async {
    if (employeeAddresses.isEmpty) {
      throw ArgumentError('Employee list cannot be empty');
    }

    if (totalAmount <= 0) {
      throw ArgumentError('Total amount must be greater than zero');
    }

    int numberOfEmployees = employeeAddresses.length;
    double amountPerEmployee = totalAmount / numberOfEmployees;
    amountPerEmployee = (amountPerEmployee * 1e8).floor() / 1e8; // Round down to 8 decimal places

    List<Transaction> transactions = [];
    double remainingAmount = totalAmount;

    for (int i = 0; i < numberOfEmployees; i++) {
      double currentAmount;
      if (i == numberOfEmployees - 1) {
        currentAmount = remainingAmount; // Last employee gets any remaining amount
      } else {
        currentAmount = amountPerEmployee;
      }

      transactions.add(Transaction(employeeAddresses[i], currentAmount));
      remainingAmount -= currentAmount;
    }

    await Future.delayed(Duration(seconds: 2)); // Simulate transaction time
    return transactions;
  }

  Future<void> _sendDIAM(Employee employee) async {
    final TextEditingController _amountController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Send DIAM to ${employee.name}'),
          content: SingleChildScrollView(
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount to Send',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Send'),
              onPressed: () async {
                final amountText = _amountController.text.trim();
                final amount = double.tryParse(amountText);

                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a valid amount')),
                  );
                  return;
                }

                Navigator.of(context).pop();
                await _makeSinglePayment(employee, amount);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE94560),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _makeSinglePayment(Employee employee, double amount) async {
    setState(() {
      _isSingleFunding = true;
    });

    try {
      // Simulate sending DIAM
      await Future.delayed(Duration(seconds: 2));

      setState(() {
        employee.balance += amount;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Successful')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending DIAM: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isSingleFunding = false;
      });
    }
  }

  // Other existing functions remain unchanged...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color.fromARGB(255, 235, 239, 247),
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            tooltip: 'Send DIAM to All',
            onPressed: (_isBulkFunding || _isSingleFunding) ? null : _sendBulkDIAM,
          ),
        ],
      ),
      body: Container(
        color: const Color.fromARGB(255, 235, 239, 247),
        child: employees.isEmpty
            ? const Center(child: Text('No employees available.', style: TextStyle(fontSize: 16)))
            : ListView.builder(
                itemCount: employees.length,
                itemBuilder: (context, index) {
                  final employee = employees[index];
                  return Card(
                    color: const Color(0xFF0F3460),
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ExpansionTile(
                      title: Text(employee.name, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(employee.role, style: const TextStyle(color: Colors.white70)),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Wallet Address: ${employee.wallet}', style: const TextStyle(color: Colors.white)),
                              const SizedBox(height: 8),
                              Text('Balance: ${employee.balance.toStringAsFixed(2)} DIAM', style: const TextStyle(color: Colors.white70)),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                child: const Text('Send DIAM'),
                                onPressed: (_isBulkFunding || _isSingleFunding) ? null : () => _sendDIAM(employee),
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE94560)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFF0F3460),
        onPressed: _addEmployee,
      ),
    );
  }

  void _addEmployee() {
    // Implement the logic to add a new employee
  }
}

class Employee {
  final String id;
  final String name;
  final String role;
  final String wallet;
  double balance;

  Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.wallet,
    this.balance = 0.0,
  });
}

class Transaction {
  final String recipientAddress;
  final double amount;

  Transaction(this.recipientAddress, this.amount);
}
