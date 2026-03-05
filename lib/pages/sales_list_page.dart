import 'package:english_learning_sales/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalesDetailsPage extends StatelessWidget {
  final String title;
  final List<OrderModel> filteredOrders;

  const SalesDetailsPage({
    super.key,
    required this.title,
    required this.filteredOrders,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: filteredOrders.isEmpty
          ? const Center(child: Text("No sales recorded for this period."))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filteredOrders.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.receipt_long_outlined),
                  ),
                  title: Text(
                    order.batchName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    DateFormat(
                      'dd MMM, yyyy • hh:mm a',
                    ).format(order.purchaseDate.toDate()),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormat.format(order.amountPaid),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        order.paymentStatus,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
