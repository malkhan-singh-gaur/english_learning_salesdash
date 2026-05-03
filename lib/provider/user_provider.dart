import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_learning_sales/models/order_model.dart';
// Ensure this imports the file where you saved the SalesAgent model
import 'package:english_learning_sales/models/sales_agent_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

/// Provides the Firestore document for the currently logged-in sales agent
final salesAgentDataProvider = StreamProvider<SalesAgent?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);

      return FirebaseFirestore.instance
          .collection('salesmen') // Kept 'salesmen' collection to match your existing DB, change to 'agents' if you renamed it
          .doc(user.uid)
          .snapshots()
          .map((snapshot) {
        if (!snapshot.exists || snapshot.data() == null) return null;
        return SalesAgent.fromJson(snapshot.data()!);
      });
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// 1. Fetch all successful orders for the current agent
final salesAgentOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('orders')
      .where('salesmanUid', isEqualTo: user.uid)
      .where('paymentStatus', isEqualTo: 'Success')
      .orderBy('purchaseDate', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
        .map((doc) => OrderModel.fromJson(doc.data()))
        .toList(),
  );
});

// 2. Computed provider to calculate stats and dynamic commission
final salesStatsProvider = Provider((ref) {
  final orders = ref.watch(salesAgentOrdersProvider).value ?? [];
  final agent = ref.watch(salesAgentDataProvider).value; // Grab the agent to access contract terms

  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final today = DateTime(now.year, now.month, now.day);

  int dailySales = 0;
  int weeklySales = 0;
  int monthlySales = 0;

  // We count the NUMBER of successful sales instead of the amount paid
  for (var order in orders) {
    // Assuming purchaseDate is a Timestamp. Adjust if it's a DateTime string.
    final date = order.purchaseDate.toDate();

    // Normalize order date to midnight to compare accurately with 'today'
    final orderDay = DateTime(date.year, date.month, date.day);

    if (orderDay.isAtSameMomentAs(today) || orderDay.isAfter(today)) dailySales++;
    if (date.isAfter(startOfWeek)) weeklySales++;
    if (date.isAfter(startOfMonth)) monthlySales++;
  }

  // Calculate Expected Commission for the Current Month
  double currentMonthEarnings = 0.0;
  int targetRemaining = 15;

  if (agent != null) {
    final terms = agent.contractTerms;
    targetRemaining = (terms.monthlyTarget - monthlySales).clamp(0, 999);

    if (monthlySales < terms.monthlyTarget) {
      // Less than 15 sales -> ₹500 per sale
      currentMonthEarnings = monthlySales * terms.belowTargetPerSale;
    } else if (monthlySales == terms.monthlyTarget) {
      // Exactly 15 sales -> Flat ₹8,000
      currentMonthEarnings = terms.baseTargetPayout;
    } else {
      // More than 15 sales -> ₹8,000 + (₹300 * extra sales)
      final extraSales = monthlySales - terms.monthlyTarget;
      currentMonthEarnings = terms.baseTargetPayout + (extraSales * terms.bonusPerSale);
    }
  }

  return {
    'dailySales': dailySales,
    'weeklySales': weeklySales,
    'monthlySales': monthlySales,
    'totalSalesCount': orders.length,
    'currentMonthEarnings': currentMonthEarnings, // Display this on their dashboard so they know exactly what you owe them
    'targetRemaining': targetRemaining, // Good for UI: "Only 3 more sales to hit your ₹8000 base!"
    'recentOrders': orders.take(10).toList(), // For your recent orders table
  };
});