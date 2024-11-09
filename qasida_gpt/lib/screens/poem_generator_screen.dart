import 'package:flutter/material.dart';
import '../services/network_service.dart';
import '../widgets/custom_input_field.dart';
import '../constants.dart';
import 'package:loading_indicator/loading_indicator.dart';

class PoemGenerator extends StatefulWidget {
  const PoemGenerator({super.key});

  @override
  State<PoemGenerator> createState() => _PoemGeneratorState();
}

class _PoemGeneratorState extends State<PoemGenerator> {
  final NetworkService _networkService = NetworkService();
  final TextEditingController _promptController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isWaitingForResponse = false;
  bool _showChat = false;
  String? _selectedMeter;
  String? _selectedTheme;
  String? _selectedRhyme;
  String? _selectedEra;
  String? _selectedPoet;
  String _currentPrompt = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _promptController.addListener(_onPromptChanged);
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _promptController.removeListener(_onPromptChanged);
    _promptController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // Handle scroll to bottom if needed
    }
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

  void _startNewConversation() {
    setState(() {
      _messages.clear();
      _showChat = false;
      _promptController.clear();
      _currentPrompt = '';
      _selectedMeter = null;
      _selectedTheme = null;
      _selectedRhyme = null;
      _selectedEra = null;
      _selectedPoet = null;
    });
  }

  void _onPromptChanged() {
    setState(() {
      _currentPrompt = _promptController.text;
    });
  }

  void _updateSettings({
    String? meter,
    String? theme,
    String? rhyme,
    String? era,
    String? poet,
  }) {
    setState(() {
      _selectedMeter = meter;
      _selectedTheme = theme;
      _selectedRhyme = rhyme;
      _selectedEra = era;
      _selectedPoet = poet;
    });
  }

  void _showSettingsDialog() {
    String? tempMeter = _selectedMeter;
    String? tempTheme = _selectedTheme;
    String? tempRhyme = _selectedRhyme;
    String? tempEra = _selectedEra;
    String? tempPoet = _selectedPoet;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(maxWidth: 400),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Poem Settings",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                            splashRadius: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSettingsSection(
                        "Meter",
                        "Choose the rhythmic structure",
                        tempMeter,
                        meters,
                        (value) {
                          setDialogState(() => tempMeter = value);
                        },
                        () {
                          setDialogState(() => tempMeter = null);
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildSettingsSection(
                        "Theme",
                        "Select the poem's theme",
                        tempTheme,
                        themes,
                        (value) {
                          setDialogState(() => tempTheme = value);
                        },
                        () {
                          setDialogState(() => tempTheme = null);
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildSettingsSection(
                        "Rhyme",
                        "Choose the rhyme scheme",
                        tempRhyme,
                        rhyme,
                        (value) {
                          setDialogState(() => tempRhyme = value);
                        },
                        () {
                          setDialogState(() => tempRhyme = null);
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildSettingsSection(
                        "Era",
                        "Choose the poetic era",
                        tempEra,
                        eras,
                        (value) {
                          setDialogState(() => tempEra = value);
                        },
                        () {
                          setDialogState(() => tempEra = null);
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildSettingsSection(
                        "Poet's style",
                        "Choose preferred style",
                        tempPoet,
                        poets,
                        (value) {
                          setDialogState(() => tempPoet = value);
                        },
                        () {
                          setDialogState(() => tempPoet = null);
                        },
                      ),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            _updateSettings(
                              meter: tempMeter,
                              theme: tempTheme,
                              rhyme: tempRhyme,
                              era: tempEra,
                              poet: tempPoet,
                            );
                            Navigator.of(context).pop();
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingsSection(
    String title,
    String description,
    String? selectedValue,
    List<String> options,
    ValueChanged<String?> onChanged,
    VoidCallback onClear,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedValue,
                  hint: Text('Select $title'),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  items: options.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: onChanged,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  dropdownColor: Colors.white,
                ),
              ),
            ),
            if (selectedValue !=
                null) // Show clear button only if there's a selection
              IconButton(
                icon: Icon(Icons.clear, color: Colors.grey[600]),
                onPressed: onClear,
                tooltip: 'Clear $title Selection',
              ),
          ],
        ),
      ],
    );
  }

  Future<void> generateInitialPoem() async {
    final userPrompt = _promptController.text;

    setState(() {
      _showChat = true;
      _messages.add({'sender': 'user', 'message': userPrompt});
      _isWaitingForResponse = true;
      _promptController.clear();
      _currentPrompt = '';
    });

    _scrollToBottom();

    try {
      final response = await _networkService.generatePoem({
        'prompt': userPrompt,
        'meter': _selectedMeter,
        'theme': _selectedTheme,
        'rhyme': _selectedRhyme,
        'era': _selectedEra,
        'poet': _selectedPoet,
      });

      setState(() {
        _messages.add({'sender': 'ai', 'message': response});
      });
    } catch (e) {
      print('Error generating poem: $e');
      setState(() {
        _messages.add({
          'sender': 'ai',
          'message': 'Error generating poem. Please try again.'
        });
      });
    } finally {
      setState(() {
        _isWaitingForResponse = false;
      });
      _scrollToBottom();
    }
  }

  Future<void> sendMessage(String message) async {
    setState(() {
      _messages.add({"sender": "user", "message": message});
      _isWaitingForResponse = true;
    });
    _scrollToBottom();

    try {
      final response = await _networkService.getChatResponse(_messages);
      setState(() {
        _messages.add({"sender": "ai", "message": response});
      });
    } catch (e) {
      setState(() {
        _messages.add({"sender": "ai", "message": "Error: $e"});
      });
    } finally {
      setState(() {
        _isWaitingForResponse = false;
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QasidaGPT"),
        actions: [
          if (_showChat) // Show the refresh button only in chat mode
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _startNewConversation,
              tooltip: 'New Conversation',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _showChat ? _buildChatUI() : _buildInitialInputUI(),
      ),
    );
  }

  Widget _buildInitialInputUI() {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              const Text(
                'What kind of poem do you want?',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Describe your poem idea and let AI create it for you.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: TextField(
                  onChanged: (value) {
                    // Additional onChange handler for extra safety
                    setState(() {
                      _currentPrompt = value;
                    });
                  },
                  controller: _promptController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'How can I help you create a poem today?',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              // Changed to IconButton
                              onPressed: _showSettingsDialog,
                              icon: const Icon(Icons.tune)),
                          const SizedBox(width: 8),
                          IconButton(
                              onPressed: _currentPrompt.isNotEmpty &&
                                      !_isWaitingForResponse
                                  ? generateInitialPoem
                                  : null,
                              icon: const Icon(Icons.auto_awesome)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16), // Space for chips

              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  _buildSettingChip("Meter", _selectedMeter, Colors.blue[100]!),
                  _buildSettingChip(
                      "Theme", _selectedTheme, Colors.green[100]!),
                  _buildSettingChip(
                      "Rhyme", _selectedRhyme, Colors.orange[100]!),
                  _buildSettingChip("Era", _selectedEra, Colors.purple[100]!),
                  _buildSettingChip("Poet", _selectedPoet, Colors.pink[100]!),
                ],
              ),

              const SizedBox(height: 32),
              Wrap(
                spacing: 8.0,
                runSpacing: 12.0,
                alignment: WrapAlignment.center,
                children: [
                  _buildSuggestionChip(
                      "اكتب قصيدة على نمط المعلقات عن الصحراء"),
                  _buildSuggestionChip("اكتب موشحاً أندلسياً عن حدائق الحمراء"),
                  _buildSuggestionChip("اكتب قصيدة حب على طريقة قيس وليلى"),
                  _buildSuggestionChip(
                      "نظّم قصيدة عن القهوة العربية وطقوس الضيافة"),
                  _buildSuggestionChip("اكتب قصيدة حديثة عن جمال مدينة الرياض"),
                  _buildSuggestionChip(
                      "اكتب قصيدة على نهج المتنبي في الحكمة والفلسفة"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingChip(String label, String? value, Color color) {
    if (value == null) return const SizedBox.shrink();

    return Chip(
      label: Text('$label: $value'),
      backgroundColor: color,
      deleteIconColor: Colors.grey[600],
      onDeleted: () {
        setState(() {
          switch (label) {
            case "Meter":
              _selectedMeter = null;
              break;
            case "Theme":
              _selectedTheme = null;
              break;
            case "Rhyme":
              _selectedRhyme = null;
              break;
            case "Era":
              _selectedEra = null;
              break;
            case "Poet":
              _selectedPoet = null;
              break;
          }
        });
      },
    );
  }

  Widget _buildSuggestionChip(String label) {
    return ActionChip(
      label: Text(label),
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.grey[300]!),
      onPressed: () {
        _promptController.text = label;
        generateInitialPoem();
      },
    );
  }

  Widget _buildChatUI() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            reverse: true,
            itemCount: _messages.length + (_isWaitingForResponse ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == 0 && _isWaitingForResponse) {
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

              final adjustedIndex = _isWaitingForResponse ? index - 1 : index;
              final message = _messages[_messages.length - 1 - adjustedIndex];
              final isUser = message['sender'] == 'user';
              return _buildMessageBubble(message['message'], isUser);
            },
          ),
        ),
        CustomInputField(
          controller: _promptController,
          isLoading: _isWaitingForResponse,
          onSend: () {
            final message = _promptController.text;
            if (message.isNotEmpty) {
              sendMessage(message);
              _promptController.clear();
              setState(() {
                _currentPrompt = '';
              });
            }
          },
        ),
      ],
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
            ? Text(message, style: const TextStyle(fontSize: 16))
            : message,
      ),
    );
  }
}
