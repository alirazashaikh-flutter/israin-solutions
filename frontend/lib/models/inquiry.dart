class Inquiry {
  final String id;
  final String? customerId;
  final String? serviceId;
  final String name;
  final String email;
  final String? phone;
  final String serviceType;
  final String message;
  final String status;
  final DateTime createdAt;

  Inquiry({
    required this.id,
    this.customerId,
    this.serviceId,
    required this.name,
    required this.email,
    this.phone,
    required this.serviceType,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory Inquiry.fromJson(Map<String, dynamic> json) {
    return Inquiry(
      id: json['_id'],
      customerId: json['customer_id'] is Map ? json['customer_id']['_id'] : json['customer_id'],
      serviceId: json['service_id'] is Map ? json['service_id']['_id'] : json['service_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      serviceType: json['service_type'],
      message: json['message'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  String get statusLabel {
    switch (status) {
      case 'new':
        return 'New';
      case 'in_discussion':
        return 'In Discussion';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }
}
