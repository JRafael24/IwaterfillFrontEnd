import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:iwaterfill/screens/dashboard.dart';
import 'package:iwaterfill/services/payment.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuyWater extends StatefulWidget {
  const BuyWater({Key? key}) : super(key: key);

  @override
  State<BuyWater> createState() => _BuyWaterState();
}

Future<Map<String, dynamic>> _loadCredential() async {
  final prefs = await SharedPreferences.getInstance();
  int userId = int.parse(prefs.get('userId').toString());

  return <String, dynamic>{
    'userId': userId
  };
}

class _BuyWaterState extends State<BuyWater> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  int _selectedIndex = -1; // -1 means no item selected
  int _quantity = 1;

  final List<Map<String, dynamic>> _items = [
    {'label': 'Container', 'image': 'assets/CONTAINER.png', 'price': 250.00},
    {'label': 'Dispenser', 'image': 'assets/ROUND CONTAINER.png', 'price': 300.00},
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _dateController.text = DateFormat('MM/dd/yyyy').format(_selectedDate);

    _dateController.addListener(() {
      final text = _dateController.text;
      _dateController.value = _dateController.value.copyWith(
        text: _formatDate(text),
        selection: TextSelection.collapsed(offset: _formatDate(text).length),
      );
    });
  }

  String _formatDate(String text) {
    text = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length >= 3) {
      text = text.substring(0, 2) + '/' + text.substring(2);
    }
    if (text.length >= 6) {
      text = text.substring(0, 5) + '/' + text.substring(5);
    }
    return text;
  }

  void _updateAmount() {
    if (_selectedIndex >= 0) {
      double totalAmount = _items[_selectedIndex]['price'] * _quantity;
      _amountController.text = '₱' + totalAmount.toStringAsFixed(2);
    } else {
      _amountController.text = '₱0.00';
    }
  }

  Future<void> _placeOrder() async {
    if (_selectedIndex == -1 || _quantity <= 0) {
      // No item selected or invalid quantity
      return;
    }

    final userCredentials = await _loadCredential();
    final url = Uri.parse('http://10.0.2.2:8080/api/v1/payment/new');
    final headers = {"Content-Type": "application/json"};
    final paymentId = DateTime.now().millisecondsSinceEpoch.toString();
    final selectedItem = _items[_selectedIndex];

    // Create a list of items with their quantities and prices
    final itemsOrdered = [
      {
        'productName': selectedItem['label'],
        'quantity': _quantity,
        'price': selectedItem['price'] * _quantity,
      }
    ];

    // Print the order data for debugging
    print('Order Data:');
    print('User ID: ${userCredentials['userId']}');
    print('Payment ID: $paymentId');
    print('Location: ${_locationController.text}');
    print('Items Ordered: $itemsOrdered');

    // Create Payment object for each item (even though there's only one item here)
    for (var item in itemsOrdered) {
      final payment = Payment(
        id: 0,
        userId: userCredentials['userId'],
        paymentId: paymentId,
        productName: item['productName'],
        quantity: item['quantity'],
        paymentDate: _selectedDate,
        location: _locationController.text,
        price: item['price'],
      );

      final body = jsonEncode(payment.toJson());

      // Send the request
      final response = await http.post(url, headers: headers, body: body);

      // Check response status
      if (response.statusCode != 200) {
        throw Exception('Failed to place order');
      }
    }

    // Navigate to the Dashboard after successful order placement
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Dashboard()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.blue[300],
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        centerTitle: true,
        title: Text('Make purchase'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
               Image.asset(
                'assets/new.png',
                width: 250, // Adjust width as needed
                height: 150, // Adjust height as needed
                fit: BoxFit.contain, // Adjust the fit as needed
              ),

            GestureDetector(
              onTap: () {
                _selectDate(context);
              },
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _dateController,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    labelText: 'DATE',
                    hintText: 'MM/DD/YYYY',
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),

            // Display Selected Date
            Text(
              'Selected Date: ${_dateController.text}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 16.0),

            ListView.builder(
              shrinkWrap: true,
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                      _quantity = 1; // Reset quantity to 1 when a new item is selected
                      _updateAmount();
                    });
                  },
                  child: Container(
                    color: _selectedIndex == index ? Colors.blue[100] : Colors.transparent,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              _items[index]['image'],
                              height: 50.0,
                              width: 50.0,
                            ),
                            SizedBox(width: 10.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _items[index]['label'],
                                  style: TextStyle(fontSize: 16.0),
                                ),
                                Text(
                                  '₱${_items[index]['price'].toString()}',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            if (_selectedIndex == index)
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove),
                                    onPressed: () {
                                      setState(() {
                                        if (_quantity > 1) {
                                          _quantity--;
                                          _updateAmount();
                                        }
                                      });
                                    },
                                  ),
                                  Text(_quantity.toString()),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      setState(() {
                                        _quantity++;
                                        _updateAmount();
                                      });
                                    },
                                  ),
                                ],
                              ),
                          ],
                        ),
                        SizedBox(height: 16.0),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Location Field
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'LOCATION',
              ),
            ),
            SizedBox(height: 16.0),

            // Amount Field
            TextField(
              controller: _amountController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'AMOUNT',
              ),
            ),
            SizedBox(height: 16.0),

            // Place Order Button
            ElevatedButton(
              onPressed: _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800], // Background color
                foregroundColor: Colors.black, // Color for the text and icon
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0), // Optional: Rounded corners
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart, color: Colors.black),
                  SizedBox(width: 10.0),
                  Text('Place Order', style: TextStyle(color: Colors.black)),
                ],
              ),
            )

          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            colorScheme: ColorScheme.light(primary: Colors.blue),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('MM/dd/yyyy').format(pickedDate);
        _updateAmount(); // Update the amount if the date changes
      });
    }
  }
}
