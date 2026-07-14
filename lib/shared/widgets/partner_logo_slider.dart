import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PartnerLogoSlider extends StatelessWidget {
  final List<String> logoUrls;
  
  const PartnerLogoSlider({
    super.key,
    required this.logoUrls,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: AppTheme.lightGrey,
        border: const Border(
          top: BorderSide(color: AppTheme.lightGrey, width: 1),
          bottom: BorderSide(color: AppTheme.lightGrey, width: 1),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Featured Stores',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppTheme.brandBlack,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Trusted by local businesses and brands across India',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.greyText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              children: logoUrls.map((url) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Image.network(
                    url,
                    width: 140,
                    height: 60,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 140,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.lightGrey),
                        ),
                        child: const Center(
                          child: Icon(Icons.business, color: AppTheme.greyText),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

