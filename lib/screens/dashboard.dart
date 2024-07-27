import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    home: Dashboard(),

  ));
}

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Future<Map<String, String>> _loadCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String _email = prefs.getString('email') ?? '';
      String _password = prefs.getString('password') ?? '';

      return <String, String>{
        'email': _email,
        'password': _password,
      };
    } catch (err) {
      return <String, String>{
        'error': err.toString(),
      };
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCredentials().then((result) {
      print(result['email']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        centerTitle: true,
        title: Image.asset(
          'assets/city.png',
          width: 100,
          height: 80,
          fit: BoxFit.contain, // Adjust the fit as needed
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 150),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                padding: EdgeInsets.all(20),
                children: <Widget>[
                  buildDashboardButton(
                    imagePath: 'assets/profile.png',
                    label: 'PROFILE',
                    onPressed: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                  ),
                  buildDashboardButton(
                    imagePath: 'assets/transaction_history.png',
                    label: 'TRANSACTION HISTORY',
                    onPressed: () {
                      Navigator.pushNamed(context, '/transactionhistory');
                    },
                  ),
                  buildDashboardButton(
                    imagePath: 'assets/buy_water.png',
                    label: 'BUY WATER',
                    onPressed: () {
                      Navigator.pushNamed(context, '/buywater');
                    },
                  ),
                  buildDashboardButton(
                    imagePath: 'assets/refillwater.png',
                    label: 'REFILL',
                    onPressed: () {
                      Navigator.pushNamed(context, '/refill');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDashboardButton({
    required String imagePath,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      shadowColor: Colors.grey,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[100],
          foregroundColor: Colors.blue[800],
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 50, // Adjust width as needed
              height: 50, // Adjust height as needed
            ),
            SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blue[800],
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
