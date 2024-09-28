// import 'package:flutter/material.dart';

// class ReportsScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Reports'),
//         backgroundColor: Color(0xFF16213E),
//       ),
//       body: Container(
//         color: Color(0xFF1A1A2E),
//         child: ListView(
//           padding: EdgeInsets.all(16),
//           children: [
//             _buildReportCard('Transaction Volume', '1,234,567 DIAM', Icons.show_chart),
//             _buildReportCard('Active Employees', '42', Icons.people),
//             _buildReportCard('Total Wallets', '56', Icons.account_balance_wallet),
//             ElevatedButton(
//               child: Text('Generate Detailed Report'),
//               onPressed: () {
//                 // TODO: Implement detailed report generation
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Color(0xFFE94560),
//                 padding: EdgeInsets.symmetric(vertical: 16),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildReportCard(String title, String value, IconData icon) {
//     return Card(
//       color: Color(0xFF0F3460),
//       margin: EdgeInsets.only(bottom: 16),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(color: Colors.white, fontSize: 18),
//                 ),
//                 Icon(icon, color: Color(0xFFE94560)),
//               ],
//             ),
//             SizedBox(height: 8),
//             Text(
//               value,
//               style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
