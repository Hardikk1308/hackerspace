// import 'package:flutter/material.dart';
// import 'package:secure_pay/Pages/Dashboard.dart';

// import 'Signup_page.dart';

// class LoginScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Login')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const TextField(decoration: InputDecoration(labelText: 'Email')),
//             const SizedBox(height: 12),
//             const TextField(decoration: InputDecoration(labelText: 'Password'), obscureText: true),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               child: const Text('Login'),
//               onPressed: () {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => DashboardScreen()),
//                 );
//               },
//             ),
//             TextButton(
//               child: const Text('New user? Sign up'),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => SignUpScreen()),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
