import 'package:flutter/material.dart';
import 'package:social_crossplatform/core/constants/constants.dart';

class MessagesScreen extends StatefulWidget {
  final List<Map<String, dynamic>> messages;
  const MessagesScreen({Key? key, required this.messages}) : super(key: key);

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    return ListView.separated(
      itemBuilder: (context, index) {
        final message = widget.messages[index];
        final bool isUserMessage = message['isUserMessage'];
        return Container(
          margin: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment:
                isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isUserMessage)
                Image.asset(
                    Constants.logoPath,
                    height: 40,
                  ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomRight: Radius.circular(isUserMessage ? 0 : 20),
                      topLeft: Radius.circular(isUserMessage ? 20 : 0),
                    ),
                    color: isUserMessage
                        ? Colors.blue.shade600
                        : Colors.grey.shade900.withOpacity(0.8),
                  ),
                  constraints: BoxConstraints(maxWidth: w * 2 / 3),
                  child: Text(
                    message['message'].text.text[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (isUserMessage)
                const CircleAvatar(
                  backgroundColor: Colors.red,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        );
      },
      separatorBuilder: (_, __) => const Padding(padding: EdgeInsets.only(top: 10)),
      itemCount: widget.messages.length,
    );
  }
}
