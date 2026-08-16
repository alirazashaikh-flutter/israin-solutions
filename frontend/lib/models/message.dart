class Message {
  final String id;
  final String inquiryId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String text;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.inquiryId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.text,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'],
      inquiryId: json['inquiry_id'],
      senderId: json['sender_id'] is Map ? json['sender_id']['_id'] : json['sender_id'],
      senderName: json['sender_id'] is Map ? json['sender_id']['name'] : 'Unknown',
      senderRole: json['sender_id'] is Map ? json['sender_id']['role'] : 'customer',
      text: json['text'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
