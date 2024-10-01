// TransactionHistoryScreen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Define a Transaction model
class TransactionModel {
  final String id;
  final String transactionHash;
  final DateTime createdAt;
  final String sourceAccount;
  final String type;
  final double amount;
  final String assetType;
  final String description;

  TransactionModel({
    required this.id,
    required this.transactionHash,
    required this.createdAt,
    required this.sourceAccount,
    required this.type,
    required this.amount,
    required this.assetType,
    required this.description,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      transactionHash: json['transaction_hash'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      sourceAccount: json['source_account'] ?? '',
      type: json['type'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      assetType: json['asset_type'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class TransactionHistoryScreen extends StatefulWidget {
  final String publicKey;

  const TransactionHistoryScreen({Key? key, required this.publicKey}) : super(key: key);

  @override
  _TransactionHistoryScreenState createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<TransactionModel> _transactions = []; // List to store transactions
  String? _nextCursor;
  bool _isFetching = false;
  bool _isFetchingMore = false;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions({String? cursor, bool isRefresh = false}) async {
    if (_isFetching || _isFetchingMore) return;

    if (isRefresh) {
      setState(() {
        _isFetching = true;
        _nextCursor = null;
      });
    } else if (cursor != null) {
      setState(() {
        _isFetchingMore = true;
      });
    } else {
      setState(() {
        _isFetching = true;
      });
    }

    // Define the base URL for transactions
    String transactionsUrl =
        'https://diamtestnet.diamcircle.io/accounts/${widget.publicKey}/transactions';

    // Add query parameters if cursor is provided
    if (cursor != null) {
      transactionsUrl += '?cursor=$cursor&limit=10&order=desc';
    } else {
      transactionsUrl += '?limit=10&order=desc'; // Default parameters
    }

    try {
      final response = await http.get(
        Uri.parse(transactionsUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<TransactionModel> fetchedTransactions = [];

        if (data['_embedded'] != null &&
            data['_embedded']['records'] != null &&
            data['_embedded']['records'] is List) {
          for (var tx in data['_embedded']['records']) {
            fetchedTransactions.add(TransactionModel.fromJson(tx));
          }
        }

        setState(() {
          if (isRefresh) {
            _transactions = fetchedTransactions;
          } else {
            _transactions.addAll(fetchedTransactions);
          }

          // Update the cursor for the next page
          _nextCursor = data['paging_token'] ?? null;
        });
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorData['error'] ?? 'Failed to fetch transactions')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching transactions: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isFetching = false;
        _isFetchingMore = false;
      });
    }
  }

  Future<void> _fetchMoreTransactions() async {
    if (_nextCursor == null) return;
    await _fetchTransactions(cursor: _nextCursor);
  }

  Future<void> _refreshTransactions() async {
    await _fetchTransactions(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction History', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF16213E),
      ),
      body: Container(
        color: Colors.white,
        child: _isFetching && _transactions.isEmpty
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _refreshTransactions,
                child: ListView.builder(
                  itemCount: _transactions.length + 1, // Add one for the loading indicator
                  itemBuilder: (context, index) {
                    if (index == _transactions.length) {
                      // Display a loading indicator at the end
                      return _isFetchingMore
                          ? Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : SizedBox.shrink();
                    }

                    final tx = _transactions[index];
                    return Card(
                      color: Color(0xFF16213E),
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: Icon(
                          _getTransactionIcon(tx.type),
                          color: _getTransactionColor(tx.type),
                        ),
                        title: Text(
                          '${_capitalize(tx.type)} - ${tx.amount > 0 ? '+' : ''}${tx.amount.toStringAsFixed(2)} DIAM',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          tx.description.isNotEmpty
                              ? tx.description
                              : 'Transaction ID: ${tx.transactionHash}',
                          style: TextStyle(color: Colors.white70),
                        ),
                        trailing: Text(
                          DateFormat('yyyy-MM-dd').format(tx.createdAt),
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  IconData _getTransactionIcon(String type) {
    switch (type.toLowerCase()) {
      case 'fund':
      case 'payment':
        return type.toLowerCase() == 'fund' ? Icons.add : Icons.payment;
      case 'create_account':
        return Icons.person_add;
      // Add more cases as needed
      default:
        return Icons.swap_horiz;
    }
  }

  Color _getTransactionColor(String type) {
    switch (type.toLowerCase()) {
      case 'fund':
        return Colors.green;
      case 'payment':
        return Colors.blue;
      case 'create_account':
        return Colors.orange;
      // Add more cases as needed
      default:
        return Colors.grey;
    }
  }

  String _capitalize(String s) => s.length > 0 ? '${s[0].toUpperCase()}${s.substring(1)}' : '';
}
