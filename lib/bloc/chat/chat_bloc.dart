import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatflow/utils/types.dart';
import 'chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import 'package:flutter_chatflow/models.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;

  ChatBloc({required this.chatRepository}) : super(ChatLoading()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
  }

  Future<void> _onLoadMessages(LoadMessages event, Emitter<ChatState> emit) async {
    try {
      final messages = await chatRepository.fetchMessages();
      emit(ChatLoaded(messages));
    } catch (_) {
      emit(ChatError());
    }
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;

      final newMessage = TextMessage(
        author: ChatUser(userID: 'randomID'),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        text: event.text,
        status: DeliveryStatus.sending,
      );

      final updatedMessages = [newMessage, ...currentState.messages];
      emit(ChatLoaded(updatedMessages));

      await chatRepository.sendMessage(newMessage);

      // Instead of `copyWith`, create a new `TextMessage` instance with `status: sent`
      final sentMessage = TextMessage(
        author: newMessage.author,
        createdAt: newMessage.createdAt,
        text: newMessage.text,
        status: DeliveryStatus.sent, // Updated status
      );

      final updatedMessagesAfterSend = [sentMessage, ...currentState.messages];
      emit(ChatLoaded(updatedMessagesAfterSend));
    }
  }
}
