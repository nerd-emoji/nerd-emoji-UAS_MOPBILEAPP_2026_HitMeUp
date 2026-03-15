import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/common_widgets.dart';
import '../../theme/app_theme.dart';
import 'step2_gender_screen.dart';

class Step3BirthdayScreen extends StatefulWidget {
  const Step3BirthdayScreen({super.key});

  @override
  State<Step3BirthdayScreen> createState() => _Step3BirthdayScreenState();
}

class _Step3BirthdayScreenState extends State<Step3BirthdayScreen> {
  bool _showOnProfile = false;

  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  @override
  void dispose() {
    _monthController.dispose();
    _dayController.dispose();
    _yearController.dispose();
    super.dispose();
  }

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
                  padding: const EdgeInsets.only(left: 36, right: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Center(
                        child: StepIndicator(totalSteps: 6, currentStep: 1),
                      ),
                      const SizedBox(height: 36),
                      const Text(
                        'Your Birthday',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 40),
                      _buildDateInputRow(),
                      const Spacer(),
                      Center(child: _buildShowOnProfile()),
                      const SizedBox(height: 24),
                      _buildContinueButton(context),
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

  Widget _buildDateInputRow() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.blueBottom, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _buildDateCell(
              controller: _monthController,
              hint: 'Month',
              borderRight: true,
              keyboardType: TextInputType.text,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                LengthLimitingTextInputFormatter(10),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildDateCell(
              controller: _dayController,
              hint: 'DD',
              borderRight: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: _buildDateCell(
              controller: _yearController,
              hint: 'YYYY',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCell({
    required TextEditingController controller,
    required String hint,
    bool borderRight = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: borderRight
            ? const Border(
                right: BorderSide(color: AppColors.blueBottom, width: 1.5),
              )
            : null,
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 18,
            color: Colors.black54,
          ),
          border: InputBorder.none,
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildShowOnProfile() {
    return GestureDetector(
      onTap: () => setState(() => _showOnProfile = !_showOnProfile),
      child: Container(
        width: 182,
        height: 39,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Show on profile',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B6B6B),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _showOnProfile ? Colors.black : Colors.transparent,
                border: Border.all(
                  color: Colors.black,
                  width: 1.5,
                ),
              ),
              child: _showOnProfile
                  ? const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 67,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF656565),
          elevation: 3,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const Step2GenderScreen()),
          );
        },
        child: const Text(
          'CONTINUE',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Color(0xFF656565),
          ),
        ),
      ),
    );
  }
}