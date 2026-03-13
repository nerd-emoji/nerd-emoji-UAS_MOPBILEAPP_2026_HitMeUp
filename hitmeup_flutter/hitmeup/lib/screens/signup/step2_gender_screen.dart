import 'package:flutter/material.dart';
import '../../widgets/common_widgets.dart';
import '../../theme/app_theme.dart';
import 'step3_birthday_screen.dart';

class Step2GenderScreen extends StatefulWidget {
  const Step2GenderScreen({super.key});

  @override
  State<Step2GenderScreen> createState() => _Step2GenderScreenState();
}

class _Step2GenderScreenState extends State<Step2GenderScreen> {
  String? _selectedGender;

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
                        child: StepIndicator(totalSteps: 6, currentStep: 1),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Your Gender',
                        style: AppTextStyles.heading,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Choose the gender that best describes you',
                        style: AppTextStyles.subHeading,
                      ),
                      const SizedBox(height: 32),
                      ChoiceButton(
                        label: 'Woman',
                        isSelected: _selectedGender == 'Woman',
                        onTap: () =>
                            setState(() => _selectedGender = 'Woman'),
                      ),
                      const SizedBox(height: 16),
                      ChoiceButton(
                        label: 'Man',
                        isSelected: _selectedGender == 'Man',
                        onTap: () =>
                            setState(() => _selectedGender = 'Man'),
                      ),
                      const SizedBox(height: 24),
                      const Center(
                        child: Text(
                          'Make friends with people who match your vibe!',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white38, thickness: 1),
                      const Spacer(),
                      PrimaryButton(
                        label: 'CONTINUE',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const Step3BirthdayScreen(),
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
}
