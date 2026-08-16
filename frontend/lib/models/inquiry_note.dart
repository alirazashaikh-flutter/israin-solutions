class InquiryNote {
  final String id;
  final String text;
  final String authorName;
  final DateTime createdAt;

  InquiryNote({
    required this.id,
    required this.text,
    required this.authorName,
    required this.createdAt,
  });

  factory InquiryNote.fromJson(Map<String, dynamic> json) {
    return InquiryNote(
      id: json['_id'] ?? '',
      text: json['text'] ?? '',
      authorName: json['author_name'] ?? 'Admin',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
