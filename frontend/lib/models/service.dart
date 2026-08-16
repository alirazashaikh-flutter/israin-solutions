class Service {
  final String id;
  final String name;
  final String category;
  final String description;
  final double price;
  final String timeline;
  final List<String> useCases;
  final int requestCount;
  final DateTime createdAt;

  Service({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.timeline,
    this.useCases = const [],
    this.requestCount = 0,
    required this.createdAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['_id'],
      name: json['name'],
      category: json['category'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      timeline: json['timeline'],
      useCases: List<String>.from(json['useCases'] ?? []),
      requestCount: json['requestCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'timeline': timeline,
      'useCases': useCases,
      'requestCount': requestCount,
    };
  }
}
