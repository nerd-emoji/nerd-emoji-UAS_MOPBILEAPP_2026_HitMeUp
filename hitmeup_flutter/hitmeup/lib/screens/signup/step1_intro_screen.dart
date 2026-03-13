import 'package:flutter/material.dart';
import '../../widgets/common_widgets.dart';
import '../../theme/app_theme.dart';
import 'step2_gender_screen.dart';

class Step1IntroScreen extends StatelessWidget {
  const Step1IntroScreen({super.key});

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
                        child: StepIndicator(totalSteps: 6, currentStep: 0),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Hello! Please introduce\nyourself',
                        style: AppTextStyles.heading,
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Colors.white38, thickness: 1),
                      const SizedBox(height: 24),
                      const CustomTextField(hint: 'Input your name'),
                      const SizedBox(height: 14),
                      const CustomTextField(
                        hint: 'Input mail',
                        prefixIcon: Icons.mail_outline_rounded,
                      ),
                      const SizedBox(height: 14),
                      const CustomTextField(
                        hint: 'Input password',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: true,
                      ),
                      const Spacer(),
                      PrimaryButton(
                        label: 'CONTINUE',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const Step2GenderScreen(),
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
