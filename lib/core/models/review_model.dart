class ReviewModel {
  final String id;
  final String customerName;
  final double rating;
  final String comment;
  final DateTime date;
  final String? avatar;
  
  ReviewModel({
    required this.id,
    required this.customerName,
    required this.rating,
    required this.comment,
    required this.date,
    this.avatar,
  });
  
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      customerName: json['customerName'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      date: DateTime.parse(json['date'] as String),
      avatar: json['avatar'] as String?,
    );
  }
}



