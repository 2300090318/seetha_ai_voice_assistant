import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/chat_provider.dart';
import '../utils/constants.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = Provider.of<ChatProvider>(context);
    final messages = chat.messages;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Clear All'),
                  content: const Text('Delete all chat history?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirm == true) {
                await chat.clearAll();
              }
            },
          )
        ],
      ),
      body: messages.isEmpty
          ? const Center(child: Text('No conversations yet', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final time = DateFormat.jm().format(msg.timestamp);

                return Dismissible(
                  key: Key(msg.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    if (msg.id != null) chat.deleteMessage(msg.id!);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // User message (right)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryPurple,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                            ),
                            child: Text(msg.userMsg, style: const TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Seetha message (left)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.cardBg,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                              border: Border.all(color: AppColors.secondaryBlue.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (msg.toolUsed != null) ...[
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.build, size: 12, color: AppColors.secondaryBlue),
                                      const SizedBox(width: 4),
                                      Text(msg.toolUsed!, style: const TextStyle(fontSize: 10, color: AppColors.secondaryBlue)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                ],
                                Text(msg.seethaMsg, style: const TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
