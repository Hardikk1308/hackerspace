import 'package:flutter/material.dart';

class CreateCurrencyPage extends StatefulWidget {
  @override
  _CreateCurrencyPageState createState() => _CreateCurrencyPageState();
}

class _CreateCurrencyPageState extends State<CreateCurrencyPage> {
  final TextEditingController _currencyNameController = TextEditingController();
  final TextEditingController _currencyAmountController = TextEditingController();
  final TextEditingController _exchangeRateController = TextEditingController();

  void _createCurrency() {
    final currencyName = _currencyNameController.text.trim();
    final currencyAmount = _currencyAmountController.text.trim();
    final exchangeRate = _exchangeRateController.text.trim();

    if (currencyName.isEmpty || currencyAmount.isEmpty || exchangeRate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Handle currency creation logic here (e.g., API call)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$currencyName created with amount $currencyAmount and exchange rate $exchangeRate')),
    );

    // Optionally, navigate back or reset fields
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Currency'),
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
              controller: _currencyAmountController,
              decoration: const InputDecoration(
                labelText: 'Currency Amount',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _exchangeRateController,
              decoration: const InputDecoration(
                labelText: 'Exchange Rate',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createCurrency,
              child: const Text('Create Currency'),
            ),
          ],
        ),
      ),
    );
  }
}
