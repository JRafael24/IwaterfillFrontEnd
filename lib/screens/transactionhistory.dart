import 'package:flutter/material.dart';

class Transactionhistory extends StatefulWidget {
  @override
  _TransactionhistoryState createState() => _TransactionhistoryState();
}

class _TransactionhistoryState extends State<Transactionhistory> {
  List<Map<String, dynamic>> transactions = [
    {
      'id': '1',
      'dateTime': '2024-07-16T14:00:00',
      'quantity': 10,
      'location': 'Station 1',
      'amount': 100.0
    },
    {
      'id': '2',
      'dateTime': '2024-07-15T10:30:00',
      'quantity': 20,
      'location': 'Station 2',
      'amount': 200.0
    },
    // Add more transactions as needed
  ];

  List<Map<String, dynamic>> filteredTransactions = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    filteredTransactions = transactions;
  }

  void _filterTransactions(String query) {
    final filtered = transactions.where((transaction) {
      return transaction['id'].contains(query) ||
          transaction['location'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      searchQuery = query;
      filteredTransactions = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.blue[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        centerTitle: true,
        title: Text('Transaction History'),

      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by ID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: _filterTransactions,
            ),
          ),
          Expanded(
            child: filteredTransactions.isEmpty
                ? Center(child: Text('No transactions available.'))
                : ListView.builder(
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                final transaction = filteredTransactions[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0),
                    title: Text('ID: ${transaction['id']}', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date & Time: ${DateTime.parse(transaction['dateTime']).toLocal()}'),
                        Text('Quantity: ${transaction['quantity']}'),
                        Text('Location: ${transaction['location']}'),
                        Text('Amount: ₱${transaction['amount'].toStringAsFixed(2)}'),
                      ],
                    ),
                    onTap: () {},
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Transactionhistory(),
  ));
}
