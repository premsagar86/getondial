import 'vendor_model.dart';
import 'product_model.dart';
import 'review_model.dart';

class VendorDetailModel extends VendorModel {
  final List<String> gallery;
  final int totalReviews;
  final Map<String, String> businessHours;
  final List<String> amenities;
  final List<String> customerHighlights;
  final List<ProductModel> products;
  final List<ReviewModel> reviews;
  final int establishedYear;
  
  VendorDetailModel({
    required super.id,
    required super.name,
    required super.logoUrl,
    required super.bannerUrl,
    required super.shortDescription,
    required super.fullDescription,
    required super.categories,
    required super.location,
    required super.address,
    required super.phone,
    required super.email,
    required super.website,
    required super.rating,
    required super.reviewCount,
    required super.productCount,
    required super.verified,
    required super.establishedDate,
    required super.certifications,
    required super.socialMedia,
    required super.openingHours,
    required this.gallery,
    required this.totalReviews,
    required this.businessHours,
    required this.amenities,
    required this.customerHighlights,
    required this.products,
    required this.reviews,
    required this.establishedYear,
  });
  
  factory VendorDetailModel.fromJson(Map<String, dynamic> json) {
    return VendorDetailModel(
      id: json['id'] as String,
      name: json['name'] as String,
      bannerUrl: json['bannerUrl'] as String? ?? json['logoUrl'] as String,
      logoUrl: json['logoUrl'] as String,
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
      gallery: List<String>.from(json['gallery'] as List? ?? []),
      totalReviews: json['totalReviews'] as int? ?? 0,
      businessHours: Map<String, String>.from(json['businessHours'] as Map? ?? {}),
      amenities: List<String>.from(json['amenities'] as List? ?? []),
      customerHighlights: List<String>.from(json['customerHighlights'] as List? ?? []),
      products: (json['products'] as List? ?? [])
          .map((p) => ProductModel.fromJson(p as Map<String, dynamic>))
          .toList(),
      reviews: (json['reviews'] as List? ?? [])
          .map((r) => ReviewModel.fromJson(r as Map<String, dynamic>))
          .toList(),
      establishedYear: json['establishedYear'] as int,
    );
  }
}

