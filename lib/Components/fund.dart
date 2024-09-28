// WalletFundingWidget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WalletFundingWidget extends StatefulWidget {
  const WalletFundingWidget({Key? key}) : super(key: key);

  @override
  _WalletFundingWidgetState createState() => _WalletFundingWidgetState();
}

class _WalletFundingWidgetState extends State<WalletFundingWidget> {
  bool _isFunding = false;
  bool _isGeneratingKeypair = false; // New loading state for keypair generation
  double _balance = 0.0; // Initialize balance as double
  final TextEditingController _publicKeyController = TextEditingController(); // Controller for public key input

  Future<void> _generateKeypair() async {
    setState(() {
      _isGeneratingKeypair = true; // Set loading state for keypair generation
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.67.15:3001/create-keypair'), // Replace with your backend URL
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Populate the public key controller with the generated public key
        _publicKeyController.text = data['publicKey'];
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Keypair created successfully!')),
        );
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorData['error'] ?? 'Failed to create keypair')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating keypair: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isGeneratingKeypair = false; // Reset loading state
      });
    }
  }

  Future<void> _fundWallet() async {
    final publicKey = _publicKeyController.text.trim();

    if (publicKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a public key')),
      );
      return;
    }

    setState(() {
      _isFunding = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://friendbot.diamcircle.io/?addr=$publicKey'), // Replace with your backend URL if different
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'publicKey': publicKey,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _balance = double.tryParse(data['balance']?.toString() ?? '0') ?? 0.0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wallet funded successfully!')),
        );

        // Pass the publicKey and balance back to the previous screen
        Navigator.pop(context, {
          'publicKey': publicKey,
          'balance': _balance,
        });
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorData['error'] ?? 'Failed to fund wallet')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error funding wallet: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isFunding = false;
      });
    }
  }

  Future<void> _copyPublicKey() async {
    final publicKey = _publicKeyController.text.trim();
    if (publicKey.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: publicKey));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Public key copied to clipboard')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No public key to copy')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fund Wallet'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView( // To handle overflow when keyboard appears
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _publicKeyController,
                  decoration: const InputDecoration(
                    labelText: 'Public Key',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isGeneratingKeypair ? null : _generateKeypair,
                  child: _isGeneratingKeypair
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.0,
                          ),
                        )
                      : const Text('Generate Keypair'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isFunding ? null : _fundWallet,
                  child: _isFunding
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.0,
                          ),
                        )
                      : const Text('Fund Wallet'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _copyPublicKey,
                  child: const Text('Copy Public Key'),
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
