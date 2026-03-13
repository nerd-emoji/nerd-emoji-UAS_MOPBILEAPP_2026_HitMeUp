import 'package:flutter/material.dart';
import '../../widgets/common_widgets.dart';
import '../../theme/app_theme.dart';
import 'step5_meet_gender_screen.dart';

class Step4LocationScreen extends StatefulWidget {
  const Step4LocationScreen({super.key});

  @override
  State<Step4LocationScreen> createState() => _Step4LocationScreenState();
}

class _Step4LocationScreenState extends State<Step4LocationScreen> {
  String _selectedLocation = 'Tangerang Selatan';

  final List<String> _locations = [
    'Tangerang Selatan',
    'Jakarta Selatan',
    'Jakarta Pusat',
    'Jakarta Barat',
    'Jakarta Timur',
    'Jakarta Utara',
    'Depok',
    'Bekasi',
    'Bogor',
    'Bandung',
    'Surabaya',
    'Yogyakarta',
    'Medan',
    'Makassar',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        child: StepIndicator(totalSteps: 6, currentStep: 2),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Where do you live?',
                        style: AppTextStyles.heading,
                      ),
                      const SizedBox(height: 32),
                      _buildDropdown(),
                      const Spacer(),
                      PrimaryButton(
                        label: 'CONTINUE',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const Step5MeetGenderScreen(),
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

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLocation,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textDark,
          ),
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textDark,
            fontWeight: FontWeight.w500,
          ),
          onChanged: (value) {
            if (value != null) setState(() => _selectedLocation = value);
          },
          items: _locations
              .map((loc) => DropdownMenuItem(value: loc, child: Text(loc)))
              .toList(),
        ),
      ),
    );
  }
}
