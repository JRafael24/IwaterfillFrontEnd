import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Payment {
  final int id;
  final int userId;
  final String paymentId;
  final String productName;
  final int quantity;
  final DateTime paymentDate;
  final String location;
  final double price;

  Payment({
    required this.id,
    required this.userId,
    required this.paymentId,
    required this.productName,
    required this.quantity,
    required this.paymentDate,
    required this.location,
    required this.price,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      userId: json['userId'],
      paymentId: json['paymentId'],
      productName: json['productName'],
      quantity: json['quantity'],
      paymentDate: DateTime.parse(json['paymentDate']),
      location: json['location'],
      price: json['price'].toDouble(),
    );
  }
}

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({Key? key}) : super(key: key);

  @override
  _TransactionHistoryState createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  late Future<List<Payment>> _payments;
  late int _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = int.parse(prefs.get('userId').toString());
      _payments = fetchPaymentsByUserId(_userId);
    });
  }

  Future<List<Payment>> fetchPaymentsByUserId(int userId) async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8080/api/v1/payment/user/$userId'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((payment) => Payment.fromJson(payment)).toList();
    } else {
      throw Exception('Failed to load payments');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.blue[200],
      appBar: AppBar(
        backgroundColor: Colors.blue[800], // Gradient effect for the AppBar
        centerTitle: true,
        title: Text(
          'Transaction History',
          style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
        ),
        elevation: 8.0, // Enhanced shadow for depth
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[300]!, Colors.blue[500]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FutureBuilder<List<Payment>>(
          future: _payments,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800]!),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Failed to load data', style: TextStyle(color: Colors.red)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No payments found', style: TextStyle(color: Colors.black54)));
            }

            final payments = snapshot.data!;

            return ListView.builder(
              itemCount: payments.length,
              itemBuilder: (context, index) {
                final payment = payments[index];
                return Card(
                  elevation: 10.0, // Increased elevation for depth
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0), // Rounded corners
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[50]!, Colors.blue[100]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[300],
                        child: Icon(Icons.payment, color: Colors.white),
                      ),
                      title: Text(
                        payment.productName,
                        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      subtitle: Text(
                        'Price: ₱${payment.price.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 16.0, color: Colors.black),
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: Colors.blue[200], // Set background color of the dialog
                              title: Row(
                                children: [
                                  Icon(Icons.payment, color: Colors.blue[800]),
                                  SizedBox(width: 10.0),
                                  Text(
                                    'Payment Details',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22.0, // Enhanced title font size
                                    ),
                                  ),
                                  Spacer(),
                                  IconButton(
                                    icon: Icon(Icons.close, color: Colors.black),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                              content: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Product Name: ${payment.productName}',
                                      style: TextStyle(color: Colors.black, fontSize: 16.0),
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      'Quantity: ${payment.quantity}',
                                      style: TextStyle(color: Colors.black, fontSize: 16.0),
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      'Price: ₱${payment.price.toStringAsFixed(2)}',
                                      style: TextStyle(color: Colors.black, fontSize: 16.0),
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      'Payment Date: ${payment.paymentDate}',
                                      style: TextStyle(color: Colors.black, fontSize: 16.0),
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      'Location: ${payment.location}',
                                      style: TextStyle(color: Colors.black, fontSize: 16.0),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                Padding(
                                  padding: EdgeInsets.only(right: 16.0, bottom: 8.0),
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.blue[700]!, Colors.blue[900]!],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      child: Text(
                                        'Close',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              elevation: 12.0, // Increased shadow for depth
                            );
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
