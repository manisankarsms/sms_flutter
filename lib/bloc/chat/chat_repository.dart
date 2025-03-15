import 'package:flutter_chatflow/models.dart';

class ChatRepository {
  final List<Message> _messages = [];

  Future<List<Message>> fetchMessages() async {
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    return _messages;
  }

  Future<void> sendMessage(Message message) async {
    await Future.delayed(Duration(milliseconds: 500)); // Simulate sending delay
    _messages.insert(0, message);
  }
}
