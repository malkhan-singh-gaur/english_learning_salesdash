import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/sales_agent_model.dart';
import '../../ui_utils/my_custom_decorations.dart';

class CreateSalesmanPage extends StatefulWidget {
  const CreateSalesmanPage({super.key});

  @override
  State<CreateSalesmanPage> createState() => _CreateSalesmanPageState();
}

class _CreateSalesmanPageState extends State<CreateSalesmanPage> {
  final _formKey = GlobalKey<FormState>();

  // --- Personal Info Controllers ---
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  // --- KYC & Bank Controllers ---
  final _aadhaarController = TextEditingController();
  final _panController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _ifscController = TextEditingController();

  // --- Contract & Sales Controllers ---
  final _referralController = TextEditingController();
  final _monthlyTargetController = TextEditingController(text: '15');
  final _baseTargetPayoutController = TextEditingController(text: '8000');
  final _belowTargetPerSaleController = TextEditingController(text: '500');
  final _bonusPerSaleController = TextEditingController(text: '300');

  bool _isLoading = false;

  bool isFormSubmitted = false;
  final myEmailController = TextEditingController();
  final myPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _aadhaarController.dispose();
    _panController.dispose();
    _bankAccountController.dispose();
    _ifscController.dispose();
    _referralController.dispose();
    _monthlyTargetController.dispose();
    _baseTargetPayoutController.dispose();
    _belowTargetPerSaleController.dispose();
    _bonusPerSaleController.dispose();
    super.dispose();
  }

  // --- Logic Methods ---
  Future<void> _createSalesman(String previousUid) async {
    setState(() => _isLoading = true);

    try {
      final String inputReferral = _referralController.text.trim();

      // 1. Check if the Referral Code already exists
      final querySnapshot = await FirebaseFirestore.instance
          .collection('salesmen')
          .where('referralCode', isEqualTo: inputReferral)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        _showSnackBar(
          'This referral code already exists. Please choose another.',
          isError: true,
        );
        isFormSubmitted = false;
        setState(() => _isLoading = false);
        return;
      }

      // 2. Create User in Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      String uid = userCredential.user!.uid;

      // 3. Create nested objects for SalesAgent
      final personalInfo = PersonalInfo(
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
      );

      final kycDetails = KycAndBankDetails(
        aadhaarNumber: _aadhaarController.text.trim(),
        panNumber: _panController.text.trim(),
        bankAccountNumber: _bankAccountController.text.trim(),
        ifscCode: _ifscController.text.trim(),
        isKycVerified: false,
      );

      final contractTerms = ContractTerms(
        monthlyTarget: int.parse(_monthlyTargetController.text.trim()),
        baseTargetPayout: double.parse(_baseTargetPayoutController.text.trim()),
        belowTargetPerSale: double.parse(
          _belowTargetPerSaleController.text.trim(),
        ),
        bonusPerSale: double.parse(_bonusPerSaleController.text.trim()),
        consecutiveMonthsMissed: 0,
      );

      final newSalesAgent = SalesAgent(
        agentId: uid,
        status: 'active',
        referralCode: inputReferral,
        createdAt: Timestamp.now(),
        personalInfo: personalInfo,
        kycAndBankDetails: kycDetails,
        contractTerms: contractTerms,
        role: 'salesman',
        mySupervisor: previousUid,
        myManager: '',
      );

      // 4. Save to Firestore
      await FirebaseFirestore.instance
          .collection('salesmen')
          .doc(uid)
          .set(newSalesAgent.toJson());

      // Success
      _showSnackBar('Sales Agent created successfully!', isError: false);
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? 'Authentication Error', isError: true);
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      await loginBackAgain();
      if (mounted) setState(() => _isLoading = false);
      Navigator.pop(context);
    }
  }

  Future<UserCredential> loginBackAgain() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    return await auth.signInWithEmailAndPassword(
      email: myEmailController.text.trim(),
      password: myPasswordController.text.trim(),
    );
  }

  // void _clearForm() {
  //   _fullNameController.clear();
  //   _emailController.clear();
  //   _passwordController.clear();
  //   _phoneController.clear();
  //   _aadhaarController.clear();
  //   _panController.clear();
  //   _bankAccountController.clear();
  //   _ifscController.clear();
  //   _referralController.clear();
  //   _monthlyTargetController.text = '15';
  //   _baseTargetPayoutController.text = '8000';
  //   _belowTargetPerSaleController.text = '500';
  //   _bonusPerSaleController.text = '300';
  //   myEmailController.clear();
  //   myPasswordController.clear();
  // }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // --- UI Methods ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4, top: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          color: Colors.blueGrey.shade400,
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String label,
    String hint,
    TextEditingController controller,
    IconData icon, {
    bool isObscure = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.blueGrey,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: isObscure,
          keyboardType: keyboardType,
          decoration: MyCustomDecorations.inputDecoration(
            context,
            hint,
            prefixIcon: Icon(icon, size: 20, color: Colors.blueGrey.shade300),
          ),
          validator: validator,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isFormSubmitted) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E293B),
          centerTitle: true,
          title: const Text(
            'Varify Your Identity',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              color: theme.dividerColor.withOpacity(0.2),
              height: 1,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(24.0),
            padding: const EdgeInsets.all(20),
            decoration: MyCustomDecorations.cardDecoration(context),
            child: Column(
              children: [
                _buildTextField(
                  context,
                  "Email Address",
                  "agent@example.com",
                  myEmailController,
                  Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                _buildTextField(
                  context,
                  "Password (Auth)",
                  "Min. 6 characters",
                  myPasswordController,
                  Icons.lock_outline_rounded,
                  isObscure: true,
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            setState(() {
                              _isLoading = true;
                            });
                            if (myEmailController.text.isNotEmpty &&
                                myPasswordController.text.isNotEmpty) {
                              FirebaseAuth auth = FirebaseAuth.instance;
                              String previousUid = auth.currentUser!.uid;

                              UserCredential user = await loginBackAgain();
                              if (user.user!.uid != previousUid) {
                                _showSnackBar(
                                  'Invalid credentials',
                                  isError: true,
                                );
                                auth.signOut();
                                Navigator.pop(context);
                                Navigator.pop(context);
                              } else {
                                _createSalesman(previousUid);
                              }
                            }
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Varify',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        centerTitle: true,
        title: const Text(
          'Create Sales Agent',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: theme.dividerColor.withOpacity(0.2),
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("PERSONAL INFO"),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: MyCustomDecorations.cardDecoration(context),
                child: Column(
                  children: [
                    _buildTextField(
                      context,
                      "Full Name",
                      "Enter full name",
                      _fullNameController,
                      Icons.person_outline_rounded,
                      validator: (v) => v!.isEmpty ? 'Enter name' : null,
                    ),
                    _buildTextField(
                      context,
                      "Email Address",
                      "agent@example.com",
                      _emailController,
                      Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v!.isEmpty || !v.contains('@')
                          ? 'Enter a valid email'
                          : null,
                    ),
                    _buildTextField(
                      context,
                      "Phone Number",
                      "Enter phone number",
                      _phoneController,
                      Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          v!.isEmpty ? 'Enter phone number' : null,
                    ),
                    _buildTextField(
                      context,
                      "Password (Auth)",
                      "Min. 6 characters",
                      _passwordController,
                      Icons.lock_outline_rounded,
                      isObscure: true,
                      validator: (v) => v!.length < 6
                          ? 'Password must be at least 6 characters'
                          : null,
                    ),
                  ],
                ),
              ),

              _buildSectionHeader("KYC & BANK DETAILS"),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: MyCustomDecorations.cardDecoration(context),
                child: Column(
                  children: [
                    _buildTextField(
                      context,
                      "Aadhaar Number",
                      "12-digit Aadhaar",
                      _aadhaarController,
                      Icons.badge_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    _buildTextField(
                      context,
                      "PAN Number",
                      "10-character PAN",
                      _panController,
                      Icons.credit_card_outlined,
                    ),
                    _buildTextField(
                      context,
                      "Bank Account Number",
                      "Account Number",
                      _bankAccountController,
                      Icons.account_balance_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    _buildTextField(
                      context,
                      "IFSC Code",
                      "Bank IFSC Code",
                      _ifscController,
                      Icons.numbers_outlined,
                    ),
                  ],
                ),
              ),

              _buildSectionHeader("CONTRACT TERMS"),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: MyCustomDecorations.cardDecoration(context),
                child: Column(
                  children: [
                    _buildTextField(
                      context,
                      "Referral Code",
                      "e.g. AGENT50",
                      _referralController,
                      Icons.local_offer_outlined,
                      validator: (v) =>
                          v!.isEmpty ? 'Enter a unique referral code' : null,
                    ),
                    _buildTextField(
                      context,
                      "Monthly Target (Sales)",
                      "e.g. 15",
                      _monthlyTargetController,
                      Icons.track_changes_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    _buildTextField(
                      context,
                      "Base Target Payout (₹)",
                      "e.g. 8000",
                      _baseTargetPayoutController,
                      Icons.currency_rupee_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    _buildTextField(
                      context,
                      "Below Target Per Sale (₹)",
                      "e.g. 500",
                      _belowTargetPerSaleController,
                      Icons.trending_down_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    _buildTextField(
                      context,
                      "Bonus Per Sale (₹)",
                      "e.g. 300",
                      _bonusPerSaleController,
                      Icons.trending_up_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              isFormSubmitted = true;
                            });
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'CREATE SALES AGENT',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
