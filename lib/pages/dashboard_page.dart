import 'package:english_learning_sales/pages/profile_page.dart';
import 'package:english_learning_sales/provider/user_provider.dart';
import 'package:english_learning_sales/pages/sales_list_page.dart';
import 'package:english_learning_sales/widget/sales_stats_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Inside DashboardPage build method...
    final allOrders = ref.watch(salesAgentOrdersProvider).value ?? [];
    final now = DateTime.now();

    final salesmanAsync = ref.watch(salesAgentDataProvider);
    final stats = ref.watch(salesStatsProvider);

    // Navigation Helper
    void navigateToDetails(String title, DateTime startDate) {
      final filtered = allOrders
          .where((o) => o.purchaseDate.toDate().isAfter(startDate))
          .toList();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              SalesDetailsPage(title: title, filteredOrders: filtered),
        ),
      );
    }

    return salesmanAsync.when(
      data: (salesman) {
        if (salesman == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("User profile not found."),
                SizedBox(height: 30),
                OutlinedButton(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  child: const Text('Login again'),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text(
              "HiSir Sales Console",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: false,
            actions: [
              IconButton.filledTonal(
                onPressed: () {
                  // Logic to copy referral link
                  Clipboard.setData(
                    ClipboardData(
                      text:
                          'https://play.google.com/store/apps/details?id=com.digital_era.english_learning&referrer=${salesman.referralCode}',
                    ),
                  ).then((v) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Referral Link Copied!')),
                    );
                  });
                },
                icon: const Icon(Icons.link),
                tooltip: "Copy Link",
              ),
              SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) {
                        return SalesmanProfilePage();
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.person),
                tooltip: "Profile",
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello, ${salesman.personalInfo.fullName} 👋",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "Referral Code: ${salesman.referralCode}",
                              style: const TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            TextButton.icon(
                              onPressed: () {
                                // Logic to copy referral link
                                Clipboard.setData(
                                  ClipboardData(text: salesman.referralCode),
                                ).then((v) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Referral Code Copied!'),
                                    ),
                                  );
                                });
                              },
                              icon: const Icon(Icons.copy, size: 18),
                              label: Container(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Stats Cards Grid
                // Stats Cards Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth > 1000
                        ? 3
                        : (constraints.maxWidth > 600 ? 2 : 1);
                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 2.5,
                      children: [
                        StatCard(
                          title: "Today's Sales",
                          // Removed currency format, just showing the count
                          value: "${stats['dailySales'] ?? 0}",
                          icon: Icons.trending_up,
                          color: Colors.blue,
                          onTap: () => navigateToDetails(
                            "Today's Sales",
                            DateTime(now.year, now.month, now.day),
                          ),
                        ),
                        StatCard(
                          title: "Monthly Sales (Target: 15)",
                          value: "${stats['monthlySales'] ?? 0}",
                          icon: Icons.track_changes,
                          onTap: () => navigateToDetails(
                            "Monthly Sales",
                            DateTime(now.year, now.month, 1),
                          ),
                          color: Colors.orange,
                        ),
                        StatCard(
                          title: "Est. Commission",
                          // Using currentMonthEarnings which is a double, so format() works
                          value: '${stats['currentMonthEarnings'] ?? 0}',
                          icon: Icons.account_balance_wallet_outlined,
                          onTap:
                              () {}, // Maybe navigate to a payout history page later
                          color: Colors.green,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 40),

                // Transactions Table
                // const Text(
                //   "Recent Sales History",
                //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                // ),
                // const SizedBox(height: 16),
                // Card(
                //   elevation: 0,
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(12),
                //     side: BorderSide(color: Colors.grey.shade200),
                //   ),
                //   child: SizedBox(
                //     width: double.infinity,
                //     child: DataTable(
                //       headingRowColor: MaterialStateProperty.all(
                //         Colors.grey[50],
                //       ),
                //       columns: const [
                //         DataColumn(label: Text('Date')),
                //         DataColumn(label: Text('Customer ID')),
                //         DataColumn(label: Text('Batch')),
                //         DataColumn(label: Text('Amount')),
                //       ],
                //       rows: (stats['recentOrders'] as List).map((order) {
                //         return DataRow(
                //           cells: [
                //             DataCell(
                //               Text(
                //                 DateFormat(
                //                   'dd MMM, yyyy',
                //                 ).format(order.purchaseDate.toDate()),
                //               ),
                //             ),
                //             DataCell(
                //               Text(order.userId.substring(0, 8) + "..."),
                //             ),
                //             DataCell(Text(order.batchName)),
                //             DataCell(
                //               Text(
                //                 currencyFormat.format(order.amountPaid),
                //                 style: const TextStyle(
                //                   fontWeight: FontWeight.bold,
                //                 ),
                //               ),
                //             ),
                //           ],
                //         );
                //       }).toList(),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text("Error: $err")),
    );
  }
}
