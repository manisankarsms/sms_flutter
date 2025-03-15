import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatflow/chatflow.dart';
import 'package:flutter_chatflow/models.dart';

import '../bloc/chat/chat_bloc.dart';
import '../bloc/chat/chat_event.dart';
import '../bloc/chat/chat_repository.dart';
import '../bloc/chat/chat_state.dart';

class MessagesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(chatRepository: ChatRepository())..add(LoadMessages()),
      child: Scaffold(
        appBar: AppBar(title: Text('Chat')),
        body: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            if (state is ChatLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is ChatLoaded) {
              return ChatFlow(
                messages: state.messages,
                chatUser: ChatUser(userID: 'randomID'),
                onSendPressed: (message, {Message? repliedTo}) {
                  context.read<ChatBloc>().add(SendMessage(message, repliedTo: repliedTo));
                },
              );
            } else {
              return Center(child: Text('Error loading messages'));
            }
          },
        ),
      ),
    );
  }
}
