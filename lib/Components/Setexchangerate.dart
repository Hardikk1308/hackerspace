import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SetExchangeRatePage extends StatefulWidget {
  const SetExchangeRatePage({super.key});

  @override
  State<SetExchangeRatePage> createState() => _SetExchangeRatePageState();
}

class _SetExchangeRatePageState extends State<SetExchangeRatePage> {
  String? _selectedCurrency;
  final TextEditingController _exchangeRateController = TextEditingController();
  bool _isLoading = false;

  Future<void> _setExchangeRate() async {
    final exchangeRate = double.tryParse(_exchangeRateController.text.trim());

    if (_selectedCurrency == null || exchangeRate == null || exchangeRate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a currency and enter a valid exchange rate')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.67.15:3001/api/exchange-rate'), // Replace with your backend URL
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'currency': _selectedCurrency,
          'exchangeRate': exchangeRate,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exchange rate set successfully')),
        );
        Navigator.pop(context);
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorData['error'] ?? 'Failed to set exchange rate')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error setting exchange rate: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Exchange Rate')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            DropdownButton<String>(
              hint: const Text('Select Currency'),
              value: _selectedCurrency,
              items: <String>['Company Coin', 'USD', 'EUR', 'GBP'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCurrency = newValue;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _exchangeRateController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Exchange Rate'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Set Rate'),
              onPressed: _isLoading ? null : _setExchangeRate,
            ),
          ],
        ),
      ),
    );
  }
}