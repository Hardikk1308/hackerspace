import 'package:flutter/material.dart';

class SetExchangeRatePage extends StatefulWidget {
  @override
  _SetExchangeRatePageState createState() => _SetExchangeRatePageState();
}

class _SetExchangeRatePageState extends State<SetExchangeRatePage> {
  final TextEditingController _currencyNameController = TextEditingController();
  final TextEditingController _newExchangeRateController = TextEditingController();

  void _setExchangeRate() {
    final currencyName = _currencyNameController.text.trim();
    final newExchangeRate = _newExchangeRateController.text.trim();

    if (currencyName.isEmpty || newExchangeRate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Handle setting exchange rate logic here (e.g., API call)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exchange rate for $currencyName set to $newExchangeRate')),
    );

    // Optionally, navigate back or reset fields
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Exchange Rate'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _currencyNameController,
              decoration: const InputDecoration(
                labelText: 'Currency Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newExchangeRateController,
              decoration: const InputDecoration(
                labelText: 'New Exchange Rate',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _setExchangeRate,
              child: const Text('Set Exchange Rate'),
            ),
          ],
        ),
      ),
    );
  }
}
