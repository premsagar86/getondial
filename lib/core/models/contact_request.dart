class ContactRequest {
  final String name;
  final String email;
  final String phone;
  final String message;
  
  ContactRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.message,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'message': message,
    };
  }
}

class ContactResponse {
  final bool success;
  final String ticketId;
  final String message;
  
  ContactResponse({
    required this.success,
    required this.ticketId,
    required this.message,
  });
  
  factory ContactResponse.fromJson(Map<String, dynamic> json) {
    return ContactResponse(
      success: json['success'] as bool,
      ticketId: json['ticketId'] as String,
      message: json['message'] as String,
    );
  }
}

