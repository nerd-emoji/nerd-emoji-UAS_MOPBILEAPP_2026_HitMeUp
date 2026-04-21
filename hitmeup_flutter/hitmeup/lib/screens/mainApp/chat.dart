import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'community.dart';
import 'discover.dart';
import 'friends.dart';
import 'profile.dart';
import 'requests.dart';
import 'ai_chat_screen.dart';
import 'community_chat_screen.dart';
import 'create_community_screen.dart';
import 'direct_chat_screen.dart';
import 'chat_models.dart';
import '../../services/api_config.dart';
import '../../services/auth_session.dart';
import '../../services/chat_service.dart';
import '../../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int _diamondBalance = 17;
  int _selectedBottomNavIndex = 2;
  bool _isLoadingDirectChats = true;
  bool _isLoadingCommunities = true;
  List<DirectChat> _directChats = [];
  List<_CommunityItemData> _communities = const [
    _CommunityItemData(
      id: 'create_new',
      title: 'Create a new\ncommunity',
      participants: '',
      icon: Icons.add,
      iconBackground: Color(0xFFD6E5EA),
    ),
  ];

  List<_ChatPreviewData> get _recentChats => _directChats
      .map((chat) => _ChatPreviewData(
            id: chat.id.toString(),
            name: chat.name,
            message: chat.lastMessage,
            avatarUrl: _resolveProfileImageUrl(chat.avatarUrl),
            directChat: chat,
          ))
      .toList();

  @override
  void initState() {
    super.initState();
    _hydrateDiamondsFromSession();
    _loadLoggedInUserDiamonds();
    _loadDirectChats();
    _loadUserCommunities();
  }

  String _resolveCommunityImageUrl(dynamic rawPath) {
    final value = (rawPath ?? '').toString().trim();
    if (value.isEmpty) {
      return 'assets/FallBackProfile.png';
    }
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    final base = ApiConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');
    final path = value.startsWith('/') ? value : '/$value';
    return '$base$path';
  }

  String _resolveProfileImageUrl(dynamic rawPath) {
    final value = (rawPath ?? '').toString().trim();
    if (value.isEmpty) {
      return 'assets/FallBackProfile.png';
    }
    if (value.startsWith('assets/')) {
      return value;
    }
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    final base = ApiConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');
    final path = value.startsWith('/') ? value : '/$value';
    return '$base$path';
  }

  Future<void> _loadUserCommunities() async {
    final userId = AuthSession.instance.userId;
    if (userId == null) {
      if (mounted) {
        setState(() {
          _isLoadingCommunities = false;
        });
      }
      return;
    }

    try {
      final userData = await ChatService.fetchUser(userId);
      final userCommunityIds = ((userData['communities'] as List?) ?? const [])
          .map((id) => id.toString())
          .toSet();

      final allCommunities = await ChatService.fetchCommunities();
      final userCommunities = allCommunities.where((community) {
        final communityId = community['id']?.toString();
        return communityId != null && userCommunityIds.contains(communityId);
      }).map((community) {
        final rawPicture = community['communityPicture'];
        final hasPicture = rawPicture != null && rawPicture.toString().trim().isNotEmpty;
        return _CommunityItemData(
          id: (community['id'] ?? '').toString(),
          title: (community['name'] ?? 'Community').toString(),
          participants: '${community['totalParticipants'] ?? 0} Participants',
          imageUrl: hasPicture ? _resolveCommunityImageUrl(rawPicture) : 'assets/FallBackProfile.png',
          imageIsAsset: !hasPicture,
        );
      }).toList();

      userCommunities.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

      if (!mounted) return;
      setState(() {
        _communities = [
          ...userCommunities,
          const _CommunityItemData(
            id: 'create_new',
            title: 'Create a new\ncommunity',
            participants: '',
            icon: Icons.add,
            iconBackground: Color(0xFFD6E5EA),
          ),
        ];
        _isLoadingCommunities = false;
      });
    } catch (_) {
      // Keep only create tile when request fails.
      if (mounted) {
        setState(() {
          _isLoadingCommunities = false;
        });
      }
    }
  }

  void _hydrateDiamondsFromSession() {
    final cachedUser = AuthSession.instance.currentUser;
    final diamondsRaw = cachedUser?['diamonds'];
    final diamonds = diamondsRaw is int
        ? diamondsRaw
        : int.tryParse(diamondsRaw?.toString() ?? '');
    if (diamonds != null) {
      _diamondBalance = diamonds;
    }
  }

  Future<void> _loadDirectChats() async {
    final userId = AuthSession.instance.userId;
    if (userId == null) {
      if (mounted) {
        setState(() {
          _isLoadingDirectChats = false;
        });
      }
      return;
    }

    try {
      final chats = await ChatService.fetchDirectChats(userId);
      final List<DirectChat> directChats = [];

      for (var chatData in chats) {
        try {
          final otherUser = await ChatService.getOtherUser(
            chat: chatData,
            currentUserId: userId,
          );
          
          final directChat = DirectChat.fromJson(
            chatData,
            otherUserName: otherUser['name'] as String? ?? 'Unknown',
            otherUserAvatar: otherUser['profilepicture'] as String?,
            otherUserGender: otherUser['gender'] as String?,
          );
          directChats.add(directChat);
        } catch (e) {
          // Skip chats that fail to load
          continue;
        }
      }

      if (mounted) {
        setState(() {
          _directChats = directChats;
          _isLoadingDirectChats = false;
        });
      }
    } catch (e) {
      // Silently fail - will just show empty chats
      if (mounted) {
        setState(() {
          _isLoadingDirectChats = false;
        });
      }
    }
  }

  Future<void> _loadLoggedInUserDiamonds() async {
    final userId = AuthSession.instance.userId;
    if (userId == null) {
      return;
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/users/$userId/');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return;
      }

      final diamondsRaw = decoded['diamonds'];
      final diamonds = diamondsRaw is int
          ? diamondsRaw
          : int.tryParse(diamondsRaw?.toString() ?? '');

      if (!mounted || diamonds == null) {
        return;
      }

      setState(() {
        _diamondBalance = diamonds;
      });

      await AuthSession.instance.saveUser(decoded);
    } catch (_) {
      // Keep session value silently when request fails.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        title: Text(
          'Chat',
          style: AppTextStyles.heading.copyWith(color: Colors.black),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF448AFF)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/diamond.png',
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$_diamondBalance',
                    style: const TextStyle(
                      color: Color(0xFF4F8FF7),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomNavBar(
        selectedIndex: 2,
        onItemTap: _handleBottomNavTap,
      ),
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppGradient.background),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 16),
              child: Column(
                children: [
                  // Chat.AI
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AiChatScreen()),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F3F3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/AIBrain.png',
                              width: 30,
                              height: 30,
                              fit: BoxFit.contain,
                            ),
                            Container(
                              width: 1,
                              height: 58,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              color: const Color(0xFF717171),
                            ),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Chat.AI',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 25,
                                      fontWeight: FontWeight.w800,
                                      height: 1,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'temukan keluh kesah mu disini dengan bantuan AI',
                                    style: TextStyle(
                                      color: Color(0xFF6A6A6A),
                                      fontSize: 9,
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
                  ),
                  const SizedBox(height: 16),
                  // Community section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F3F3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        if (_isLoadingCommunities)
                          const Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _CommunityLoadingTile(),
                              _CommunityLoadingTile(),
                              _CommunityLoadingTile(),
                            ],
                          )
                        else ...[
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            spacing: 10,
                            runSpacing: 10,
                            children: _communities
                                .map((item) => _CommunityItemTile(
                                      data: item,
                                      onTap: () => _handleCommunityTap(item),
                                    ))
                                .toList(),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const CommunityScreen(),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: const Padding(
                                padding: EdgeInsets.only(right: 2, top: 2),
                                child: Text(
                                  'more...',
                                  style: TextStyle(
                                    color: Color(0xFF5A5A5A),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Recent chats
                  if (_isLoadingDirectChats)
                    ...List.generate(
                      3,
                      (_) => const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: _RecentChatLoadingTile(),
                      ),
                    )
                  else
                    ..._recentChats.map(
                      (chat) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _RecentChatTile(
                          data: chat,
                          onTap: () {
                            if (chat.directChat == null) return;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    DirectChatScreen(chat: chat.directChat!),
                              ),
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
      ),
    );
  }

  void _handleCommunityTap(_CommunityItemData data) {
    if (data.icon == Icons.add) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CreateCommunityScreen()),
      ).then((_) {
        _loadUserCommunities();
      });
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CommunityChatScreen(
            community: Community(
              id: data.id,
              name: data.title,
              participants: int.tryParse(
                    data.participants.replaceAll(RegExp(r'[^0-9]'), ''),
                  ) ??
                  0,
              imageUrl: data.imageUrl,
            ),
          ),
        ),
      );
    }
  }

  void _handleBottomNavTap(int index) {
    if (index == _selectedBottomNavIndex) return;

    final Widget? destination = switch (index) {
      0 => const SwipeCardScreen(),
      1 => const RequestsScreen(),
      2 => const ChatScreen(),
      3 => const FriendsScreen(),
      4 => const ProfileScreen(),
      _ => null,
    };

    if (destination == null) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (_, __, ___) => destination,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }
}

class _CommunityItemTile extends StatelessWidget {
  const _CommunityItemTile({required this.data, required this.onTap});

  final _CommunityItemData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 102,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                clipBehavior: Clip.antiAlias,
                child: data.imageUrl != null
                  ? (data.imageIsAsset
                    ? Image.asset(data.imageUrl!, fit: BoxFit.cover)
                    : Image.network(data.imageUrl!, fit: BoxFit.cover))
                    : DecoratedBox(
                        decoration: BoxDecoration(
                          color: data.iconBackground ?? const Color(0xFFD6E5EA),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          data.icon ?? Icons.groups_rounded,
                          size: 56,
                          color: data.icon == Icons.add
                              ? Colors.black
                              : const Color(0xFFE9FFFF),
                        ),
                      ),
              ),
              const SizedBox(height: 6),
              Text(
                data.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              if (data.participants.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    data.participants,
                    style: const TextStyle(
                      color: Color(0xFF5E5E5E),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommunityLoadingTile extends StatelessWidget {
  const _CommunityLoadingTile();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 102,
      child:  Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 88,
            height: 88,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFE6E6E6),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F8FF7)),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
          SizedBox(
            width: 70,
            height: 10,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFDCDCDC),
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentChatTile extends StatelessWidget {
  const _RecentChatTile({required this.data, required this.onTap});

  final _ChatPreviewData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isAssetAvatar = data.avatarUrl.startsWith('assets/');
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F3F3),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFE0E0E0),
                child: ClipOval(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: isAssetAvatar
                        ? Image.asset(data.avatarUrl, fit: BoxFit.cover)
                        : Image.network(
                            data.avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(
                              'assets/FallBackProfile.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF4F4F4F),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
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

class _RecentChatLoadingTile extends StatelessWidget {
  const _RecentChatLoadingTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE0E0E0),
              ),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F8FF7)),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 26,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFFE6E6E6),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunityItemData {
  const _CommunityItemData({
    required this.id,
    required this.title,
    required this.participants,
    this.imageUrl,
    this.imageIsAsset = false,
    this.icon,
    this.iconBackground,
  });

  final String id;
  final String title;
  final String participants;
  final String? imageUrl;
  final bool imageIsAsset;
  final IconData? icon;
  final Color? iconBackground;
}

class _ChatPreviewData {
  const _ChatPreviewData({
    required this.id,
    required this.name,
    required this.message,
    required this.avatarUrl,
    this.directChat,
  });

  final String id;
  final String name;
  final String message;
  final String avatarUrl;
  final DirectChat? directChat;
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.selectedIndex, required this.onItemTap});

  final int selectedIndex;
  final ValueChanged<int> onItemTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomNavItem(
              imageAssetPath: 'assets/navbar/discover.png',
              fallbackIcon: Icons.home_rounded,
              selected: selectedIndex == 0,
              onTap: () => onItemTap(0),
            ),
            _BottomNavItem(
              imageAssetPath: 'assets/navbar/requests.png',
              fallbackIcon: Icons.grid_view_rounded,
              selected: selectedIndex == 1,
              onTap: () => onItemTap(1),
            ),
            _BottomNavItem(
              imageAssetPath: 'assets/navbar/chatSelected.png',
              fallbackIcon: Icons.chat_bubble_outline_rounded,
              selected: selectedIndex == 2,
              onTap: () => onItemTap(2),
            ),
            _BottomNavItem(
              imageAssetPath: 'assets/navbar/friends.png',
              fallbackIcon: Icons.groups_rounded,
              selected: selectedIndex == 3,
              onTap: () => onItemTap(3),
            ),
            _BottomNavItem(
              imageAssetPath: 'assets/navbar/profile.png',
              fallbackIcon: Icons.account_circle_outlined,
              selected: selectedIndex == 4,
              onTap: () => onItemTap(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.imageAssetPath,
    required this.fallbackIcon,
    required this.selected,
    required this.onTap,
  });

  final String imageAssetPath;
  final IconData fallbackIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          width: 56,
          height: 56,
          child: Center(
            child: SizedBox(
              width: 40,
              height: 40,
              child: Image.asset(
                imageAssetPath,
                width: 32,
                height: 32,
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(fallbackIcon, color: Colors.black, size: 24);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
