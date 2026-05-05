import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_learning_sales/models/order_model.dart';
import 'package:english_learning_sales/models/sales_agent_model.dart';
import 'package:flutter/material.dart';

enum DateFilter { today, week, month, custom }

class SalesmanOrdersPage extends StatefulWidget {
  final SalesAgent salesman; // Updated model
  const SalesmanOrdersPage({super.key, required this.salesman});

  @override
  State<SalesmanOrdersPage> createState() => _SalesmanOrdersPageState();
}

class _SalesmanOrdersPageState extends State<SalesmanOrdersPage> {
  DateFilter _selectedFilter = DateFilter.today;
  DateTimeRange? _customDateRange;

  // Calculates the start date based on the selected filter
  DateTime _getStartDate() {
    DateTime now = DateTime.now();
    switch (_selectedFilter) {
      case DateFilter.today:
        return DateTime(now.year, now.month, now.day);
      case DateFilter.week:
        return DateTime(now.year, now.month, now.day - now.weekday + 1);
      case DateFilter.month:
        return DateTime(now.year, now.month, 1);
      case DateFilter.custom:
        return _customDateRange?.start ??
            DateTime(now.year, now.month, now.day);
    }
  }

  // Calculates the end date based on the selected filter
  DateTime _getEndDate() {
    DateTime now = DateTime.now();
    switch (_selectedFilter) {
      case DateFilter.today:
        return DateTime(now.year, now.month, now.day, 23, 59, 59);
      case DateFilter.week:
        DateTime startOfWeek = DateTime(
          now.year,
          now.month,
          now.day - now.weekday + 1,
        );
        return startOfWeek.add(
          const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
        );
      case DateFilter.month:
        return DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      case DateFilter.custom:
        return _customDateRange?.end.add(
              const Duration(hours: 23, minutes: 59, seconds: 59),
            ) ??
            now;
    }
  }

  Future<void> _pickCustomDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedFilter = DateFilter.custom;
        _customDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.salesman.personalInfo.fullName}\'s Sales'),
      ), // Updated field
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Today'),
                  selected: _selectedFilter == DateFilter.today,
                  onSelected: (_) =>
                      setState(() => _selectedFilter = DateFilter.today),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('This Week'),
                  selected: _selectedFilter == DateFilter.week,
                  onSelected: (_) =>
                      setState(() => _selectedFilter = DateFilter.week),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('This Month'),
                  selected: _selectedFilter == DateFilter.month,
                  onSelected: (_) =>
                      setState(() => _selectedFilter = DateFilter.month),
                ),
                const SizedBox(width: 8),
                ActionChip(
                  avatar: const Icon(Icons.date_range, size: 16),
                  label: Text(
                    _selectedFilter == DateFilter.custom &&
                            _customDateRange != null
                        ? '${_customDateRange!.start.day}/${_customDateRange!.start.month} - ${_customDateRange!.end.day}/${_customDateRange!.end.month}'
                        : 'Custom Date',
                  ),
                  onPressed: _pickCustomDateRange,
                  backgroundColor: _selectedFilter == DateFilter.custom
                      ? Colors.blue.shade100
                      : null,
                ),
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where(
                    'salesmanUid',
                    isEqualTo: widget.salesman.agentId,
                  ) // Updated field
                  .where(
                    'purchaseDate',
                    isGreaterThanOrEqualTo: Timestamp.fromDate(_getStartDate()),
                  )
                  .where(
                    'purchaseDate',
                    isLessThanOrEqualTo: Timestamp.fromDate(_getEndDate()),
                  )
                  .orderBy('purchaseDate', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  debugPrint(snapshot.error.toString());
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No sales found for this period.'),
                  );
                }

                var orders = snapshot.data!.docs.map((doc) {
                  return OrderModel.fromJson(
                    doc.data() as Map<String, dynamic>,
                  );
                }).toList();

                double totalSales = orders.fold(
                  0,
                  (sum, item) => sum + item.amountPaid,
                );

                // Updated Commission Logic based on new contract terms
                int totalOrders = orders.length;
                int target = widget.salesman.contractTerms.monthlyTarget;
                double estimatedCommission = 0.0;

                if (totalOrders < target) {
                  estimatedCommission =
                      totalOrders *
                      widget.salesman.contractTerms.belowTargetPerSale;
                } else {
                  estimatedCommission =
                      widget.salesman.contractTerms.baseTargetPayout +
                      ((totalOrders - target) *
                          widget.salesman.contractTerms.bonusPerSale);
                }

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.grey.shade200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sales ($totalOrders): ₹${totalSales.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Est. Comm: ₹${estimatedCommission.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          final date = order.purchaseDate.toDate();
                          return ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.receipt),
                            ),
                            title: Text(order.batchName),
                            subtitle: Text(
                              '${date.day}/${date.month}/${date.year} • ${order.paymentMethod}',
                            ),
                            trailing: Text(
                              '₹${order.amountPaid}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
