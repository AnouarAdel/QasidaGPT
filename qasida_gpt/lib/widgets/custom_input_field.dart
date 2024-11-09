import 'package:flutter/material.dart';

class CustomInputField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading; 

  const CustomInputField({
    super.key,
    required this.controller,
    required this.onSend,
    required this.isLoading, 
  });

  @override
  CustomInputFieldState createState() => CustomInputFieldState();
}

class CustomInputFieldState extends State<CustomInputField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _showSendButton = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final showButton = widget.controller.text.isNotEmpty;
    if (showButton != _showSendButton) {
      setState(() {
        _showSendButton = showButton;
      });
      if (showButton) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                controller: widget.controller,
                decoration: const InputDecoration(
                  hintText: 'Enter a prompt here',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _animation,
            axis: Axis.horizontal,
            axisAlignment: 1,
            child: widget.isLoading // Conditionally render icon or indicator
                ? SizedBox(
                    width: 24, 
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2, 
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: widget.onSend,
                  ),
          ),
        ],
      ),
    );
  }
}