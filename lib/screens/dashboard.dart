import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
buildShowDialog(BuildContext context){
  return showDialog(
      context:  context,
      barrierDismissible: false,
      builder:  (BuildContext context){
        return Center(
          child:  SpinKitWave(
            color: Colors.blue,
            size: 100,
          ),
        );
      }
  );
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
      body: Center(
        child: Column(
          children: [
             Image.asset(
              'assets/city.png',
              width: 300,
              height: 200,
              fit: BoxFit.contain, // Adjust the fit as needed
            ),
            Divider(height: 40.0,
            color: Colors.blue[800],
            thickness: 3.0,),
            SizedBox(height: 50),
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
      shadowColor: Colors.yellow,

      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[800],
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
                color: Colors.white,
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
