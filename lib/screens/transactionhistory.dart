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
      appBar: AppBar(
        title: Text('Transaction History'),
      ),
      body: FutureBuilder<List<Payment>>(
        future: _payments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No payments found'));
          }

          final payments = snapshot.data!;

          return ListView.builder(
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index];
              return ListTile(
                title: Text(payment.productName),
                subtitle: Text('₱${payment.price.toStringAsFixed(2)}'),
                trailing: Text('${payment.quantity} units'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Payment Details'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Product Name: ${payment.productName}'),
                            Text('Quantity: ${payment.quantity}'),
                            Text('Price: ₱${payment.price.toStringAsFixed(2)}'),
                            Text('Payment Date: ${payment.paymentDate}'),
                            Text('Location: ${payment.location}'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
