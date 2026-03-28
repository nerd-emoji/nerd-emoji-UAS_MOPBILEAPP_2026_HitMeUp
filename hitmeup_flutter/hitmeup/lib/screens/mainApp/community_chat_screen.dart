import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'chat_models.dart';
import 'ai_chat_screen.dart';
import 'chat.dart';

class CommunityChatScreen extends StatefulWidget {
  final Community community;
  const CommunityChatScreen({super.key, required this.community});

  @override
  State<CommunityChatScreen> createState() => _CommunityChatScreenState();
}

class _CommunityChatScreenState extends State<CommunityChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showAttachMenu = false;
  int? _selectedPollOption;
  bool _hasVoted = false;

  final List<String> _pollOptions = ['Ayoo mabar!!', 'Maaf lagi gabisa'];
  final List<int> _pollVotes = [24, 7];

  static const Color _bubbleBlue = Color(0xFF73A4F5);

  List<Map<String, dynamic>> get _messages {
    // Import the centralized data from ChatDataProvider
    // ignore: invalid_use_of_protected_member
    final data = ChatDataProvider.communityChatData[widget.community.id];
    if (data != null) return data;
    return [
      {'id': '${widget.community.id}_001', 'communityId': widget.community.id, 'senderId': 'me', 'text': 'Halo semua!', 'isMe': true, 'sender': '', 'time': '10:00', 'type': 'text'},
      {'id': '${widget.community.id}_002', 'communityId': widget.community.id, 'senderId': 'other', 'text': 'Selamat datang!', 'isMe': false, 'sender': 'Member', 'time': '10:01', 'type': 'text'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: const Color(0xFFFCE4EC),
        child: Column(
          children: [
            Container(color: Colors.white, child: _buildAppBar(context)),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFF4081), Color(0xFFFCE4EC)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0, left: 0, right: 0,
                      child: Container(
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                      itemCount: _messages.length,
                      itemBuilder: (_, i) {
                        final msg = _messages[i];
                        if (msg['isPoll'] == true) return _buildPollBubble();
                        return _buildMessage(msg);
                      },
                    ),
                  ],
                ),
              ),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Chat.AI banner
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AiChatScreen()),
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 64,
                        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.blueBottom,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/AIBrain.png',
                              width: 28, height: 28,
                              fit: BoxFit.contain,
                              color: Colors.white,
                              errorBuilder: (_, __, ___) => const Icon(Icons.psychology_rounded, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 12),
                            Container(width: 1, height: 40, color: Colors.white),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Ask help to Chat.AI', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                                Text('ask AI to help you with itinerary or others...', style: TextStyle(fontSize: 10, color: Colors.white70)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Input bar
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.only(
                        left: 16, right: 16, top: 4,
                        bottom: MediaQuery.of(context).padding.bottom + 8,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => _showAttachMenu = !_showAttachMenu),
                              child: AnimatedRotation(
                                turns: _showAttachMenu ? 0.125 : 0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: Container(
                                  width: 32, height: 32,
                                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 2)),
                                  child: const Icon(Icons.add, size: 20, color: Colors.black),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                decoration: const InputDecoration(
                                  hintText: 'Message',
                                  hintStyle: TextStyle(color: Colors.black38),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.mic, color: Colors.black, size: 24),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_upward, color: Colors.black, size: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Popup attachment overlap di atas Chat.AI
                if (_showAttachMenu)
                  Positioned(
                    bottom: 80 + MediaQuery.of(context).padding.bottom + 16,
                    left: 16,
                    child: AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF448AFF), Colors.white, Color(0xFFFF4081)],
                            stops: [0.0, 0.5, 1.0],
                          ),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAttachItem(Icons.photo_library_rounded, 'Gallery'),
                            const SizedBox(height: 6),
                            _buildAttachItem(Icons.camera_alt_rounded, 'Camera'),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () {
                                setState(() => _showAttachMenu = false);
                                _showCreatePollDialog(context);
                              },
                              child: _buildAttachItem(Icons.align_horizontal_left_rounded, 'Poll'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 8, right: 16, bottom: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          CircleAvatar(
            radius: 28,
            backgroundImage: widget.community.imageUrl != null ? NetworkImage(widget.community.imageUrl!) : null,
            backgroundColor: AppColors.pinkTop.withOpacity(0.2),
            child: widget.community.imageUrl == null ? const Icon(Icons.people_rounded, color: AppColors.pinkTop) : null,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.community.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
              Text('${widget.community.participants} Participants', style: const TextStyle(fontSize: 11, color: Colors.black54)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    final isMe = msg['isMe'] as bool;
    final sender = msg['sender'] as String? ?? '';
    final text = msg['text'] as String;
    final time = msg['time'] as String;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? _bubbleBlue : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe && sender.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(sender, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black87)),
                    ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(child: Text(text, style: TextStyle(fontSize: 13, color: isMe ? Colors.white : Colors.black87))),
                      const SizedBox(width: 8),
                      Text(time, style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : Colors.black45)),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.done_all, size: 12, color: Colors.white70),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 14,
        decoration: BoxDecoration(color: const Color(0xFF2859C5), borderRadius: BorderRadius.circular(10)),
        child: Stack(
          children: [
            Positioned(
              top: 5, left: 12, right: 12,
              child: Container(
                height: 2,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPollBubble() {
    final totalVotes = _pollVotes.reduce((a, b) => a + b);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(color: _bubbleBlue, borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Yang ikut malem ini mabar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 14),
            ...List.generate(_pollOptions.length, (i) {
              final isSelected = _selectedPollOption == i;
              final voteCount = _hasVoted ? _pollVotes[i] : 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: GestureDetector(
                  onTap: () {
                    if (!_hasVoted) {
                      setState(() {
                        _selectedPollOption = i;
                        _pollVotes[i]++;
                        _hasVoted = true;
                      });
                    }
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 24, height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? Colors.black : Colors.transparent,
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text(_pollOptions[i],
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black))),
                                if (_hasVoted) ...[
                                  SizedBox(
                                    width: 36, height: 20,
                                    child: Stack(
                                      children: [
                                        Positioned(left: 0, child: CircleAvatar(radius: 10,
                                          backgroundImage: NetworkImage(i == 0 ? 'https://i.pravatar.cc/40?img=44' : 'https://i.pravatar.cc/40?img=13'))),
                                        Positioned(left: 14, child: CircleAvatar(radius: 10,
                                          backgroundImage: NetworkImage(i == 0 ? 'https://i.pravatar.cc/40?img=11' : 'https://i.pravatar.cc/40?img=24'))),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text('$voteCount', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                                ],
                              ],
                            ),
                            const SizedBox(height: 6),
                            _buildProgressBar(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('16:30', style: TextStyle(fontSize: 10, color: Colors.black54)),
                  SizedBox(width: 4),
                  Icon(Icons.done_all, size: 12, color: Colors.black54),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Container(height: 2, color: Colors.white),
            TextButton(
              onPressed: () {},
              child: const Center(
                child: Text('View votes', style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePollDialog(BuildContext context) {
    final questionController = TextEditingController();
    final option1Controller = TextEditingController();
    final option2Controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Buat Poll', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(controller: questionController,
                decoration: InputDecoration(hintText: 'Pertanyaan poll...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10))),
              const SizedBox(height: 10),
              TextField(controller: option1Controller,
                decoration: InputDecoration(hintText: 'Opsi 1',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10))),
              const SizedBox(height: 10),
              TextField(controller: option2Controller,
                decoration: InputDecoration(hintText: 'Opsi 2',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10))),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pinkTop,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    final newPollId = '${widget.community.id}_poll_${DateTime.now().millisecondsSinceEpoch}';
                    setState(() => _messages.add({
                      'id': newPollId,
                      'communityId': widget.community.id,
                      'isPoll': true,
                      'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                      'type': 'poll',
                    }));
                  },
                  child: const Text('Buat Poll', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachItem(IconData icon, String label) {
    return Container(
      width: 99, height: 24,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.pinkTop.withOpacity(0.4), width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Icon(icon, size: 13, color: Colors.black87),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87)),
        ],
      ),
    );
  }
}