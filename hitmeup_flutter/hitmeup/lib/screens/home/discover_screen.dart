import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SwipeCardScreen extends StatefulWidget {
  const SwipeCardScreen({super.key});

  @override
  State<SwipeCardScreen> createState() => _SwipeCardScreenState();
}

class _SwipeCardScreenState extends State<SwipeCardScreen> {
  static const double _swipeThreshold = 140;
  static const Duration _animationDuration = Duration(milliseconds: 260);
  static const double _maxDragDistance = 220;
  static const double _maxLift = 42;
  static const double _maxRotation = 0.14;

  final List<ProfileCardData> _profiles = const [
    ProfileCardData(
      name: 'Frezz',
      age: 25,
      level: 3,
      location: 'Bintaro, Tangerang Selatan',
      score: 3,
      imageUrl: 'https://i.pravatar.cc/900?img=12',
    ),
    ProfileCardData(
      name: 'Alea',
      age: 23,
      level: 5,
      location: 'Kemang, Jakarta Selatan',
      score: 8,
      imageUrl: 'https://i.pravatar.cc/900?img=32',
    ),
    ProfileCardData(
      name: 'Rafi',
      age: 27,
      level: 4,
      location: 'Cilandak, Jakarta Selatan',
      score: 6,
      imageUrl: 'https://i.pravatar.cc/900?img=15',
    ),
    ProfileCardData(
      name: 'Naya',
      age: 24,
      level: 2,
      location: 'BSD, Tangerang',
      score: 4,
      imageUrl: 'https://i.pravatar.cc/900?img=47',
    ),
  ];

  Offset _dragOffset = Offset.zero;
  int _currentIndex = 0;
  bool _isAnimating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        title: Text(
          'Discover',
          style: AppTextStyles.heading.copyWith(color: Colors.black),
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradient.background),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          for (
                            int depth = math.min(2, _profiles.length - 1);
                            depth >= 0;
                            depth--
                          )
                            _buildLayeredCard(constraints, depth),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                _BottomSwipeBar(
                  onReject: () => _swipeCard(-1),
                  onAccept: () => _swipeCard(1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLayeredCard(BoxConstraints constraints, int depth) {
    final profile = _profiles[(_currentIndex + depth) % _profiles.length];
    final isTopCard = depth == 0;
    final rawHorizontalDrag = _dragOffset.dx;
    final progress = isTopCard
        ? (rawHorizontalDrag.abs() / _swipeThreshold).clamp(0.0, 1.0)
        : 0.0;
    final constrainedHorizontalDrag = rawHorizontalDrag.clamp(
      -_maxDragDistance,
      _maxDragDistance,
    );
    final normalizedDrag = (constrainedHorizontalDrag / _maxDragDistance).clamp(
      -1.0,
      1.0,
    );
    final baseScale = 1 - (depth * 0.04);
    final scale = isTopCard ? 1.0 : baseScale + (progress * 0.04);
    final verticalOffset = isTopCard ? 0.0 : 18.0 * depth - (progress * 18.0);
    final horizontalOffset = isTopCard ? rawHorizontalDrag : 0.0;
    final dragYOffset = isTopCard ? -normalizedDrag.abs() * _maxLift : 0.0;
    final rotation = isTopCard ? -normalizedDrag * _maxRotation : 0.0;

    return AnimatedContainer(
      duration: _isAnimating ? _animationDuration : Duration.zero,
      curve: Curves.easeOut,
      transform: Matrix4.identity()
        ..translate(horizontalOffset, verticalOffset + dragYOffset)
        ..rotateZ(rotation)
        ..scale(scale),
      child: Align(
        child: isTopCard
            ? GestureDetector(
                onPanUpdate: _isAnimating
                    ? null
                    : (details) {
                        setState(() {
                          final nextDx = (_dragOffset.dx + details.delta.dx)
                              .clamp(-_maxDragDistance, _maxDragDistance);
                          _dragOffset = Offset(nextDx, 0);
                        });
                      },
                onPanEnd: _isAnimating ? null : (_) => _handlePanEnd(),
                child: _ProfileCard(profile: profile),
              )
            : IgnorePointer(child: _ProfileCard(profile: profile)),
      ),
    );
  }

  void _handlePanEnd() {
    if (_dragOffset.dx.abs() >= _swipeThreshold) {
      _swipeCard(_dragOffset.dx.isNegative ? -1 : 1);
      return;
    }

    setState(() {
      _dragOffset = Offset.zero;
    });
  }

  Future<void> _swipeCard(double direction) async {
    if (_isAnimating) {
      return;
    }

    final screenWidth = MediaQuery.of(context).size.width;

    setState(() {
      _isAnimating = true;
      _dragOffset = Offset(direction * (screenWidth + 180), -_maxLift * 0.9);
    });

    await Future<void>.delayed(_animationDuration);

    if (!mounted) {
      return;
    }

    setState(() {
      _currentIndex = (_currentIndex + 1) % _profiles.length;
      _dragOffset = Offset.zero;
      _isAnimating = false;
    });
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile});

  final ProfileCardData profile;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AspectRatio(
        aspectRatio: 0.66,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(profile.imageUrl, fit: BoxFit.cover),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.08),
                      Colors.black.withValues(alpha: 0.18),
                      Colors.black.withValues(alpha: 0.62),
                    ],
                    stops: const [0, 0.45, 1],
                  ),
                ),
              ),
              Positioned(
                top: 18,
                right: 18,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.blueBottom.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.diamond_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${profile.score}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${profile.name} ${profile.age}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Level ${profile.level}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.location,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomSwipeBar extends StatelessWidget {
  const _BottomSwipeBar({required this.onReject, required this.onAccept});

  final VoidCallback onReject;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: _BarIconButton(
              icon: Icons.thumb_down_alt_rounded,
              color: const Color.fromARGB(255, 233, 30, 33),
              alignment: Alignment.centerLeft,
              onTap: onReject,
            ),
          ),
          Expanded(
            child: _BarIconButton(
              icon: Icons.thumb_up_alt_rounded,
              color: const Color.fromARGB(255, 29, 233, 182),
              alignment: Alignment.centerRight,
              onTap: onAccept,
            ),
          ),
        ],
      ),
    );
  }
}

class _BarIconButton extends StatelessWidget {
  const _BarIconButton({
    required this.icon,
    required this.color,
    required this.alignment,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final Alignment alignment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Align(
          alignment: alignment,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Icon(icon, color: color, size: 40),
          ),
        ),
      ),
    );
  }
}

class ProfileCardData {
  const ProfileCardData({
    required this.name,
    required this.age,
    required this.level,
    required this.location,
    required this.score,
    required this.imageUrl,
  });

  final String name;
  final int age;
  final int level;
  final String location;
  final int score;
  final String imageUrl;
}
