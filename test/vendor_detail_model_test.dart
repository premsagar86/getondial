import 'package:flutter_test/flutter_test.dart';
import 'package:god_bps/core/models/vendor_detail_model.dart';

void main() {
  group('VendorDetailModel', () {
    test('defaults customer highlights to an empty list when not provided', () {
      final model = VendorDetailModel.fromJson({
        'id': '1',
        'name': 'Test Vendor',
        'logoUrl': 'https://example.com/logo.png',
        'bannerUrl': 'https://example.com/banner.png',
        'shortDescription': 'Short description',
        'fullDescription': 'Full description',
        'categories': <String>[],
        'location': 'Nairobi',
        'address': 'Nairobi',
        'phone': '+254700000000',
        'email': 'vendor@example.com',
        'website': 'https://example.com',
        'rating': 4.5,
        'reviewCount': 10,
        'productCount': 5,
        'verified': true,
        'establishedDate': '2020-01-01',
        'certifications': <String>[],
        'socialMedia': <String, String>{},
        'openingHours': 'Mon-Sat: 9:00 AM - 6:00 PM',
        'gallery': <String>[],
        'totalReviews': 10,
        'businessHours': <String, String>{},
        'amenities': <String>[],
        'products': <Map<String, dynamic>>[],
        'reviews': <Map<String, dynamic>>[],
        'establishedYear': 2020,
      });

      expect(model.customerHighlights, isEmpty);
    });
  });
}
