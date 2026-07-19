import 'package:flutter/material.dart';
import '../../services/groq_service.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({Key? key}) : super(key: key);

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController chatController = TextEditingController();
  final GroqService _groqService = GroqService();

  final List<Map<String, dynamic>> _messages = [
    {
      'text':
          'Hello! I am your MedIntel Assistant. How can I help you manage your health today?',
      'isUser': false,
    },
  ];

  bool _isLoading = false;

  Future<void> _sendPrompt([String? presetText]) async {
    final text = presetText ?? chatController.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add({'text': text, 'isUser': true});
      _isLoading = true;
      if (presetText == null) chatController.clear();
    });

    final reply = await _groqService.sendMessage(text);

    if (!mounted) return;
    setState(() {
      _messages.add({'text': reply, 'isUser': false});
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1962A1);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400, maxHeight: 750),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Bounded App Header Element
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade100),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black87,
                            size: 20,
                          ),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 12),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: primaryColor,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                            Container(
                              width: 12,
                              height: 32,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF90CAF9),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Virtual Doctor AI',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Chat Stream Canvas
                  Expanded(
                    child: Container(
                      color: Colors.grey.shade50.withOpacity(0.5),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length + (_isLoading ? 1 : 0),
                        itemBuilder: (context, idx) {
                          if (idx == _messages.length) {
                            return const Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF1962A1),
                                  ),
                                ),
                              ),
                            );
                          }
                          final msg = _messages[idx];
                          final isUser = msg['isUser'] == true;

                          return Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.65,
                              ),
                              decoration: BoxDecoration(
                                color: isUser ? primaryColor : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(14),
                                  topRight: const Radius.circular(14),
                                  bottomLeft: Radius.circular(isUser ? 14 : 4),
                                  bottomRight: Radius.circular(isUser ? 4 : 14),
                                ),
                                border: isUser
                                    ? null
                                    : Border.all(color: Colors.grey.shade200),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                msg['text'],
                                style: TextStyle(
                                  color: isUser ? Colors.white : Colors.black87,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Dynamic Smart Suggestion Chips Area
                  Container(
                    color: Colors.grey.shade50.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['Fever', 'Headache', 'Consult Dr. Faisal']
                            .map((tag) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                child: ActionChip(
                                  label: Text(
                                    tag,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  backgroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  side: BorderSide(
                                    color: primaryColor.withOpacity(0.2),
                                  ),
                                  onPressed: () => _sendPrompt(tag),
                                ),
                              );
                            })
                            .toList(),
                      ),
                    ),
                  ),

                  // Premium Input Bar Dock
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: chatController,
                            enabled: !_isLoading,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: 'Ask about symptoms...',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 13,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: const BorderSide(
                                  color: primaryColor,
                                  width: 1.2,
                                ),
                              ),
                            ),
                            textInputAction: TextInputAction.send,
                            onFieldSubmitted: (_) => _sendPrompt(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            onPressed: () => _sendPrompt(),
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
      ),
    );
  }
}