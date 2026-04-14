import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../utils/storage.dart';

class ChatProvider extends ChangeNotifier {
  List<MessageModel> _messages = [];
  bool _isLoading = false;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> loadHistory() async {
    final rows = await Storage.getAllConversations();
    _messages = rows.map((e) => MessageModel.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> addMessage({
    required String userMsg,
    required String seethaMsg,
    String? toolUsed,
  }) async {
    await Storage.insertConversation(
      userMsg: userMsg,
      seethaMsg: seethaMsg,
      toolUsed: toolUsed,
    );
    await loadHistory();
  }

  Future<void> deleteMessage(int id) async {
    await Storage.deleteConversation(id);
    await loadHistory();
  }

  Future<void> clearAll() async {
    await Storage.clearAllConversations();
    _messages = [];
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
