import 'package:flutter_chatflow/models.dart';
import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMessages extends ChatEvent {}

class SendMessage extends ChatEvent {
  final String text;
  final Message? repliedTo;

  SendMessage(this.text, {this.repliedTo});

  @override
  List<Object?> get props => [text, repliedTo];
}


