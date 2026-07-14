// Custom Text Field - Matching original project
import 'package:flutter/material.dart';
import '../../core/util/dimensions.dart';
import '../../core/util/styles.dart';

class CustomTextField extends StatefulWidget {
  final String? titleText;
  final String hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final TextInputType inputType;
  final bool isPassword;
  final bool isEnabled;
  final int maxLines;
  final TextCapitalization capitalization;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool showTitle;
  final bool readOnly;
  final Function(String)? onChanged;
  final Function()? onTap;
  final Function()? onSuffixTap;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    this.titleText,
    required this.hintText,
    this.controller,
    this.focusNode,
    this.nextFocus,
    this.inputType = TextInputType.text,
    this.isPassword = false,
    this.isEnabled = true,
    this.maxLines = 1,
    this.capitalization = TextCapitalization.none,
    this.prefixIcon,
    this.suffixIcon,
    this.showTitle = false,
    this.readOnly = false,
    this.onChanged,
    this.onTap,
    this.onSuffixTap,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showTitle && widget.titleText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
            child: Text(
              widget.titleText!,
              style: robotoMedium,
            ),
          ),
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: widget.inputType,
          textCapitalization: widget.capitalization,
          maxLines: widget.maxLines,
          enabled: widget.isEnabled,
          readOnly: widget.readOnly,
          obscureText: widget.isPassword && _obscureText,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          onFieldSubmitted: (text) {
            if (widget.nextFocus != null) {
              FocusScope.of(context).requestFocus(widget.nextFocus);
            }
          },
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon)
                : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : widget.suffixIcon != null
                    ? IconButton(
                        icon: Icon(widget.suffixIcon),
                        onPressed: widget.onSuffixTap,
                      )
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
