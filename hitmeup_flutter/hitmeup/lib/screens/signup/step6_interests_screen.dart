import 'package:flutter/material.dart';
import '../../widgets/common_widgets.dart';
import '../../theme/app_theme.dart';
import '../home/home_screen.dart';

class Step6InterestsScreen extends StatefulWidget {
  const Step6InterestsScreen({super.key});

  @override
  State<Step6InterestsScreen> createState() => _Step6InterestsScreenState();
}

class _Step6InterestsScreenState extends State<Step6InterestsScreen> {
  String? _selected;

  final Map<String, List<String>> _categories = {
    'Lifestyles': [
      'Content Creator', 'Gamer', 'Youtuber', 'Actor',
      'Voice Actor', 'Choreographer', 'Streamer', 'Freelance',
    ],
    'TV & Movies': [
      'Amazon Prime', 'TV', 'Netflix', 'Disney+',
      'Video', 'WeTv', 'Drakor.id',
    ],
    'Activities': [
      'Social Media', 'Vlogging', 'Youtube', 'Memes',
      'Video Gaming', 'Film Making', 'Theatre', 'Thrifting',
    ],
    'Games': [
      'Mobile Legends', 'PUBG', 'Roblox', 'Township',
      'Candy Crush', 'Freefire', 'Hayday',
    ],
  };

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
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            const Center(child: StepIndicator(totalSteps: 6, currentStep: 5)),
                            const SizedBox(height: 20),
                            _buildHeaderCard(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    for (final entry in _categories.entries) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.pinkTop,
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 48,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: entry.value.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 10),
                            itemBuilder: (_, i) {
                              final item = entry.value[i];
                              return InterestChip(
                                label: item,
                                isSelected: _selected == item,
                                onTap: () => setState(() {
                                  _selected = _selected == item ? null : item;
                                }),
                              );
                            },
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    ],
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                        child: PrimaryButton(
                          label: 'CONTINUE',
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const HomeScreen()),
                              (route) => false,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pick your interests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              decoration: TextDecoration.underline,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "We'll recommend people you have more in common with",
            style: TextStyle(fontSize: 13, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}