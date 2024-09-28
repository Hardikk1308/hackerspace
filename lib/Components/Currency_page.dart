import 'package:flutter/material.dart';


class CreateCurrencyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create New Currency')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(decoration: InputDecoration(labelText: 'Currency Name')),
            SizedBox(height: 12),
            TextField(decoration: InputDecoration(labelText: 'Initial Supply')),
            SizedBox(height: 12),
            TextField(decoration: InputDecoration(labelText: 'Symbol')),
            SizedBox(height: 24),
            ElevatedButton(
              child: Text('Create Currency'),
              onPressed: () {
                // TODO: Implement currency creation logic
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
