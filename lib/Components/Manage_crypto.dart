import 'package:flutter/material.dart';
import 'Currency_page.dart';
import 'Setexchangerate.dart';
// import 'package:secure_pay/Components/CreateCurrencyPage.dart'; // Ensure correct import
// import 'package:secure_pay/Components/SetExchangeRatePage.dart'; // Ensure correct import

class ManageCryptoPage extends StatelessWidget {
  static const String currencyName = 'Company Coin';
  static const String currencyAmount = '1,000,000';
  static const String exchangeRate = '1 CC = \$0.1';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Cryptocurrency'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildCurrencyCard(currencyName, currencyAmount, exchangeRate),
          const SizedBox(height: 20),
          _buildActionButton(context, 'Create/Issue New Currency', CreateCurrencyPage()),
          const SizedBox(height: 20),
          _buildActionButton(context, 'Set Exchange Rates', SetExchangeRatePage()),
          const SizedBox(height: 20),
          Text('Wallets', style: Theme.of(context).textTheme.headline6),
          _buildWalletList(),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String title, Widget page) {
    return ElevatedButton(
      child: Text(title),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }

  Widget _buildCurrencyCard(String name, String amount, String exchangeRate) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Amount: $amount', style: const TextStyle(fontSize: 16)),
            Text('Exchange Rate: $exchangeRate', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletList() {
    // Example wallet data
    final List<String> wallets = ['Wallet 1', 'Wallet 2', 'Wallet 3'];

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: wallets.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(wallets[index]),
          onTap: () {
            // Handle wallet tap, navigate or show details
          },
        );
      },
    );
  }
}
