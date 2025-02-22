import 'dart:convert';

ChatMessage chatMessageFromJson(String str) =>
    ChatMessage.fromJson(json.decode(str));

String chatMessageToJson(ChatMessage data) => json.encode(data.toJson());

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.to,
    required this.from,
    required this.chatType,
    required this.toUserOnlineStatus,
  });

  String id;
  String to;
  String from;
  String chatType;
  bool toUserOnlineStatus;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json["id"],
        to: json["to"],
        from: json["from"],
        chatType: json["chat_type"],
        toUserOnlineStatus: json["to_user_online_status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "to": to,
        "from": from,
        "chat_type": chatType,
        "to_user_online_status": toUserOnlineStatus,
      };
}
