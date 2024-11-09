import 'package:flutter/material.dart';
import '../services/network_service.dart';
import '../widgets/custom_input_field.dart';
import 'package:loading_indicator/loading_indicator.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final NetworkService _networkService = NetworkService();
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  bool _isWaitingForResponse = false;
  final ScrollController _scrollController = ScrollController();
  bool _showExamplePrompts = true;

  final List<Map<String, String>> examplePrompts = [
    {
      'prompt': 'أريد أمثلة على الطباق في الشعر العربي',
    },
    {
      'prompt': 'ما هو البحر المناسب لكتابة قصيدة حماسية؟',
    },
    {
      'prompt': 'ما الفرق بين التشبيه والاستعارة في الشعر العربي؟',
    },
    {
      'prompt': 'ما هي أشهر قصائد المتنبي في المدح؟',
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {}
  }

  void _startNewConversation() {
    setState(() {
      _messages.clear();
    });
  }

  Future<void> sendMessage(String message) async {
    setState(() {
      _messages.add({"sender": "user", "message": message});
      _isWaitingForResponse = true;
      _showExamplePrompts = false;
    });
    _scrollToBottom();

    try {
      final response = await _networkService.getChatResponse(_messages);
      setState(() {
        _messages.add({"sender": "ai", "message": response});
        _isWaitingForResponse = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({"sender": "ai", "message": "Error: $e"});
        _isWaitingForResponse = false;
      });
    } finally {
      _scrollToBottom();
    }
  }

  Widget _buildExamplePrompts() {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            constraints: const BoxConstraints(
              maxWidth: 1200, // Maximum width for the container
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 16.0,
                runSpacing: 16.0,
                children: examplePrompts.map((prompt) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width > 768
                        ? 250 // Fixed width for larger screens
                        : MediaQuery.of(context).size.width /
                            2.2, // Responsive width for smaller screens
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () => sendMessage(prompt['prompt']!),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 12),
                              Text(
                                prompt['prompt']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(height: 32),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    child: Icon(
                                      Icons.arrow_upward,
                                      size: 32,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QasidaGPT"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _startNewConversation,
            tooltip: 'New Conversation',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: EdgeInsets.only(
                bottom: 16,
                top: MediaQuery.of(context).padding.bottom + 16,
              ),
              itemCount: _messages.length +
                  (_isWaitingForResponse ? 1 : 0) +
                  (_showExamplePrompts && _messages.isEmpty ? 1 : 0),
              itemBuilder: (context, index) {
                if (_showExamplePrompts && _messages.isEmpty && index == 0) {
                  return _buildExamplePrompts();
                }

                final adjustedIndex = _showExamplePrompts && _messages.isEmpty
                    ? index - 1
                    : index;
                final reversedIndex =
                    (_messages.length + (_isWaitingForResponse ? 1 : 0) - 1) -
                        adjustedIndex;

                if (reversedIndex == _messages.length &&
                    _isWaitingForResponse) {
                  return Container(
                    alignment: Alignment.centerLeft,
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: LoadingIndicator(
                          indicatorType: Indicator.ballPulseSync,
                          colors: [Colors.grey],
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  );
                }

                if (reversedIndex >= 0 && reversedIndex < _messages.length) {
                  final message = _messages[reversedIndex];
                  final isUser = message['sender'] == 'user';
                  return _buildMessageBubble(message['message'], isUser);
                }

                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomInputField(
              controller: _inputController,
              isLoading: _isWaitingForResponse,
              onSend: () {
                final message = _inputController.text;
                if (message.isNotEmpty) {
                  sendMessage(message);
                  _inputController.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(dynamic message, bool isUser) {
    return Container(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).primaryColor.withOpacity(0.2)
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(10),
        child: message is String
            ? Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  message,
                  style: const TextStyle(fontSize: 16),
                ),
              )
            : message,
      ),
    );
  }
}
