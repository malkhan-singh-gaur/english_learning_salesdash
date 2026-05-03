import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/user_provider.dart';

class SalesmanProfilePage extends ConsumerWidget {
  const SalesmanProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesmanAsync = ref.watch(salesAgentDataProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: salesmanAsync.when(
        data: (salesman) {
          if (salesman == null) {
            return const Center(child: Text("No profile found."));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    // Profile Header
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blueAccent.withOpacity(0.1),
                      child: Text(
                        salesman.personalInfo.fullName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      salesman.personalInfo.fullName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      salesman.personalInfo.email,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),

                    // Info Card
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          _ProfileTile(
                            label: "Referral Code",
                            value: salesman.referralCode,
                            icon: Icons.qr_code,
                            valueColor: Colors.blueAccent,
                          ),
                          const Divider(height: 1),
                          _ProfileTile(
                            label: "Phone Number",
                            value: salesman.personalInfo.phone.toString(),
                            icon: Icons.phone_outlined,
                          ),
                          const Divider(height: 1),
                          // _ProfileTile(
                          //   label: "Commission Rate",
                          //   value: "${salesman.commissionRate}%",
                          //   icon: Icons.percent,
                          // ),
                          const Divider(height: 1),
                          _ProfileTile(
                            label: "Account Status",
                            value: salesman.status,
                            icon: Icons.verified_user_outlined,
                            valueColor: salesman.status == 'active'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ],
                      ),
                    ),
                    // Spacer(),
                    // SizedBox())
                    // Expanded(child: Container()),
                    SizedBox(height: 100),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          elevation: 0,
                          color: Colors.red.shade200,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              FirebaseAuth.instance.signOut();
                            },
                            child: Text(
                              'Logout',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _ProfileTile({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }
}
