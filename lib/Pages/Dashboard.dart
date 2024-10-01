import 'dart:async';
import 'package:flutter/material.dart';
import 'package:secure_pay/Components/Manage_crypto.dart';
import 'package:secure_pay/Components/fund.dart';
import '../Components/Emloyeedetails.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Components/Transaction_page.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with RouteAware {
  double _totalBalance = 0.0;
  String _publicKey = '';

  Timer? _balanceRefreshTimer;

  bool _isFetchingBalance = false;

  @override
  void initState() {
    super.initState();

    if (_publicKey.isNotEmpty) {
      _fetchBalance();
    }
    _startBalanceRefreshTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);

    _balanceRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didPush() {
    _fetchBalance();
  }

  @override
  void didPopNext() {
    _fetchBalance();
  }

  void _startBalanceRefreshTimer() {
    _balanceRefreshTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      _fetchBalance();
    });
  }

  Future<void> _fetchBalance() async {
    if (_publicKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fund your wallet to fetch balance')),
      );
      return;
    }

    setState(() {
      _isFetchingBalance = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://diamtestnet.diamcircle.io/accounts/$_publicKey'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['balances'] != null && data['balances'] is List) {
          bool nativeFound = false;
          for (var balance in data['balances']) {
            if (balance['asset_type'] == 'native') {
              double nativeBalance =
                  double.tryParse(balance['balance'] ?? '0') ?? 0.0;

              setState(() {
                _totalBalance = nativeBalance;
              });

              nativeFound = true;
              break;
            }
          }

          if (!nativeFound) {
            setState(() {
              _totalBalance = 0.0;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Native asset balance not found.')),
            );
          }
        } else {
          // 'balances' field is missing or not a list
          setState(() {
            _totalBalance = 0.0;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Balances data is unavailable.')),
          );
        }
      } else {
        // Handle non-200 responses
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(errorData['error'] ?? 'Failed to fetch balance')),
        );
      }
    } catch (e) {
      // Handle network or parsing errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching balance: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isFetchingBalance = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DIAM Wallet '),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchBalance, // Manual refresh button
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.grey),
              child: Text('DIAM Wallet',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Manage Crypto'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ManageCryptoPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Employees'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => EmployeesScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Transactions'),
              onTap: () {
                Navigator.pop(context);
                if (_publicKey.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Please fund your wallet to view transactions'),
                    ),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TransactionHistoryScreen(publicKey: _publicKey),
                  ),
                );
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.insert_chart),
            //   title: const Text('Reports'),
            //   onTap: () {
            //     Navigator.pop(context);
            //     Navigator.push(context,
            //         MaterialPageRoute(builder: (context) => ReportsScreen()));
            //   },
            // ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Fund Wallet'),
              onTap: () async {
                Navigator.pop(context);
                // Navigate to WalletFundingWidget and wait for the result
                final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WalletFundingWidget()));

                // If a new balance and publicKey are returned, update the state
                if (result != null && result is Map<String, dynamic>) {
                  setState(() {
                    _publicKey = result['publicKey'] ?? '';

                    // Add the new balance to the existing total balance
                    double newBalance = result['balance'] ?? 0.0;
                    _totalBalance +=
                        newBalance; // Update to add to existing balance
                  });

                  // Optionally, fetch the latest balance to ensure accuracy
                  _fetchBalance();
                }
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Welcome, marcos',
                style: Theme.of(context).textTheme.headline5,
              ),
              const SizedBox(height: 20),
              _buildBalanceCard(), // Displays the balance
              const SizedBox(height: 20),
              _buildActionButtons(context), // Action buttons grid
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Center(
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Total Balance', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                _isFetchingBalance
                    ? CircularProgressIndicator()
                    : Text(
                        '\$${_totalBalance.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      childAspectRatio: 2.5,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      physics: const NeverScrollableScrollPhysics(),
      children: <Widget>[
        _buildActionButton(context, Icons.account_balance_wallet,
            'Manage Crypto', ManageCryptoPage()),
        _buildActionButton(
            context, Icons.people, 'Employees', EmployeesScreen()),
        _buildActionButton(context, Icons.swap_horiz, 'Transactions',
            TransactionHistoryScreen(publicKey: _publicKey)),
        // _buildActionButton(
        //     context, Icons.insert_chart, 'Reports', ReportsScreen()),
        _buildActionButton(context, Icons.account_balance_wallet, 'Fund Wallet',
            WalletFundingWidget()),
      ],
    );
  }

  Widget _buildActionButton(
      BuildContext context, IconData icon, String label, Widget page) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.blue,
        backgroundColor: Colors.white,
      ),
      onPressed: () async {
        // If the button is for funding, wait for the result
        if (label == 'Fund Wallet') {
          final result = await Navigator.push(
              context, MaterialPageRoute(builder: (context) => page));

          if (result != null && result is Map<String, dynamic>) {
            setState(() {
              _publicKey = result['publicKey'] ?? '';

              // Add the new balance to the existing total balance
              double newBalance = result['balance'] ?? 0.0;
              _totalBalance += newBalance; // Update to add to existing balance
            });

            // Optionally, fetch the latest balance to ensure accuracy
            _fetchBalance();
          }
        } else {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => page));
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}
