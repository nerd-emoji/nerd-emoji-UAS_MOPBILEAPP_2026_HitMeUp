import 'package:flutter/material.dart';
import '../../widgets/common_widgets.dart';
import '../../theme/app_theme.dart';
import 'step6_interests_screen.dart';

class Step5MeetGenderScreen extends StatefulWidget {
  const Step5MeetGenderScreen({super.key});

  @override
  State<Step5MeetGenderScreen> createState() => _Step5MeetGenderScreenState();
}

class _Step5MeetGenderScreenState extends State<Step5MeetGenderScreen> {
  String? _selected;

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
                        child: StepIndicator(totalSteps: 6, currentStep: 4),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Who do you want\nto meet?',
                        style: AppTextStyles.heading,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Choose the gender that you want to meet',
                        style: AppTextStyles.subHeading,
                      ),
                      const SizedBox(height: 32),
                      for (final option in ['Woman', 'Man', 'Everyone']) ...[
                        ChoiceButton(
                          label: option,
                          isSelected: _selected == option,
                          onTap: () => setState(() => _selected = option),
                        ),
                        const SizedBox(height: 16),
                      ],
                      const Spacer(),
                      PrimaryButton(
                        label: 'CONTINUE',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const Step6InterestsScreen(),
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
