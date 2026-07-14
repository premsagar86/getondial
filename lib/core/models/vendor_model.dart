class VendorModel {
  final String id;
  final String name;
  final String logoUrl;
  final String bannerUrl;
  final String shortDescription;
  final String fullDescription;
  final List<String> categories;
  final String location;
  final String address;
  final String phone;
  final String email;
  final String website;
  final double rating;
  final int reviewCount;
  final int productCount;
  final bool verified;
  final DateTime establishedDate;
  final List<String> certifications;
  final Map<String, String> socialMedia;
  final String openingHours;
  
  VendorModel({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.bannerUrl,
    required this.shortDescription,
    required this.fullDescription,
    required this.categories,
    required this.location,
    required this.address,
    required this.phone,
    required this.email,
    required this.website,
    required this.rating,
    required this.reviewCount,
    required this.productCount,
    required this.verified,
    required this.establishedDate,
    required this.certifications,
    required this.socialMedia,
    required this.openingHours,
  });
  
  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id: json['id'] as String,
      name: json['name'] as String,
      logoUrl: json['logoUrl'] as String,
      bannerUrl: json['bannerUrl'] as String? ?? json['logoUrl'] as String,
      shortDescription: json['shortDescription'] as String,
      fullDescription: json['fullDescription'] as String? ?? json['shortDescription'] as String,
      categories: List<String>.from(json['categories'] as List),
      location: json['location'] as String,
      address: json['address'] as String? ?? json['location'] as String,
      phone: json['phone'] as String? ?? '+91 9876543210',
      email: json['email'] as String? ?? 'contact@vendor.com',
      website: json['website'] as String? ?? 'https://vendor.com',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      reviewCount: json['reviewCount'] as int? ?? 0,
      productCount: json['productCount'] as int? ?? 0,
      verified: json['verified'] as bool? ?? true,
      establishedDate: json['establishedDate'] != null 
          ? DateTime.parse(json['establishedDate'] as String)
          : DateTime(2020, 1, 1),
      certifications: List<String>.from(json['certifications'] as List? ?? []),
      socialMedia: Map<String, String>.from(json['socialMedia'] as Map? ?? {}),
      openingHours: json['openingHours'] as String? ?? 'Mon-Sat: 9:00 AM - 6:00 PM',
    );
  }
}

