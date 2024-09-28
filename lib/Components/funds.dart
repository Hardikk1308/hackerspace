// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'Emloyeedetails.dart';
// // import 'employees_screen.dart'; // Import your EmployeesScreen

// class WalletFundingWidget extends StatefulWidget {
//   const WalletFundingWidget({Key? key}) : super(key: key);

//   @override
//   _WalletFundingWidgetState createState() => _WalletFundingWidgetState();
// }

// class _WalletFundingWidgetState extends State<WalletFundingWidget> {
//   bool _isFunding = false;
//   String _balance = '100000'; // Initialize balance
//   final TextEditingController _publicKeyController = TextEditingController(); // Controller for public key input

//   Future<void> _fundWallet() async {
//     final publicKey = _publicKeyController.text.trim();

//     if (publicKey.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please enter a public key')),
//       );
//       return;
//     }

//     setState(() {
//       _isFunding = true;
//     });

//     try {
//       final response = await http.post(
//         Uri.parse('https://friendbot.diamcircle.io/?addr=${publicKey}'), // Replace with your computer's IP address
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           'publicKey': publicKey,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _balance = data['balance']?.toString() ?? '0';
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Fund successfully!')),
//         );

//         // Navigate to EmployeesScreen with the publicKey
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => EmployeesScreen(publicKey: publicKey), // Pass the publicKey
//           ),
//         );
//       } else {
//         final errorData = jsonDecode(response.body);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(errorData['error'] ?? 'Failed to fund wallet')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error funding wallet: ${e.toString()}')),
//       );
//     } finally {
//       setState(() {
//         _isFunding = false;
//       });
//     }
//   }

//   Future<void> _copyPublicKey() async {
//     final publicKey = _publicKeyController.text.trim();
//     if (publicKey.isNotEmpty) {
//       await Clipboard.setData(ClipboardData(text: publicKey));
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Public key copied to clipboard')),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('No public key to copy')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Fund Wallet'),
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: SingleChildScrollView( // To handle overflow when keyboard appears
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: _publicKeyController,
//                   decoration: InputDecoration(
//                     labelText: 'Public Key',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: _isFunding ? null : _fundWallet,
//                   child: _isFunding
//                       ? SizedBox(
//                           width: 24,
//                           height: 24,
//                           child: CircularProgressIndicator(
//                             color: Colors.white,
//                             strokeWidth: 2.0,
//                           ),
//                         )
//                       : Text('Fund Wallet'),
//                 ),
//                 const SizedBox(height: 8),
//                 TextButton(
//                   onPressed: _copyPublicKey,
//                   child: Text('Copy Public Key'),
//                 ),
//                 const SizedBox(height: 16),
//                 SelectableText(
//                   'Total Balance: $_balance', // Display the balance
//                   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
