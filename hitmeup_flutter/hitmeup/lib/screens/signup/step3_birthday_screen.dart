import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../widgets/common_widgets.dart';
import '../../theme/app_theme.dart';
import 'step4_location_screen.dart';

class Step3BirthdayScreen extends StatefulWidget {
  const Step3BirthdayScreen({super.key});

  @override
  State<Step3BirthdayScreen> createState() => _Step3BirthdayScreenState();
}

class _Step3BirthdayScreenState extends State<Step3BirthdayScreen> {
  DateTime _selectedDate = DateTime(2002, 5, 8);
  bool _showOnProfile = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          SignupAppBar(onBack: () => Navigator.pop(context)),
          Expanded(
            child: GradientBackground(
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Center(
                        child: StepIndicator(totalSteps: 6, currentStep: 1),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Your Birthday',
                        style: AppTextStyles.heading,
                      ),
                      const SizedBox(height: 24),
                      _buildDatePicker(),
                      const Spacer(),
                      _buildShowOnProfile(),
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: 'CONTINUE',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const Step4LocationScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.date,
        initialDateTime: _selectedDate,
        maximumDate: DateTime.now(),
        onDateTimeChanged: (dt) => setState(() => _selectedDate = dt),
      ),
    );
  }

  Widget _buildShowOnProfile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Show on profile',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(width: 12),
          CupertinoSwitch(
            value: _showOnProfile,
            onChanged: (v) => setState(() => _showOnProfile = v),
            activeColor: AppColors.pinkTop,
          ),
        ],
      ),
    );
  }
}
