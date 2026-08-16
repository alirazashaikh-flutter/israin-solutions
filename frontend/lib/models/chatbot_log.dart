class ChatbotLog {
  final String id;
  final String inquiryId;
  final String customerQuery;
  final String botResponse;
  final bool escalated;
  final DateTime createdAt;

  ChatbotLog({
    required this.id,
    required this.inquiryId,
    required this.customerQuery,
    required this.botResponse,
    required this.escalated,
    required this.createdAt,
  });

  factory ChatbotLog.fromJson(Map<String, dynamic> json) {
    return ChatbotLog(
      id: json['_id'],
      inquiryId: json['inquiry_id'],
      customerQuery: json['customer_query'],
      botResponse: json['bot_response'],
      escalated: json['escalated'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
