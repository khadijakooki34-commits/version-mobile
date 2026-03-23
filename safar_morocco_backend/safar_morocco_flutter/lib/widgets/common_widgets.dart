import 'package:flutter/material.dart';
import '../utils/index.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final double size;

  const LoadingWidget({
    super.key,
    this.message,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppTheme.spacingM),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

class AppErrorWidget extends StatelessWidget {
  final String? error;
  final VoidCallback? onRetry;
  final String retryLabel;

  const AppErrorWidget({
    super.key,
    this.error,
    this.onRetry,
    this.retryLabel = 'Réessayer',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: AppTheme.iconXL,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              error ?? 'An unknown error occurred. Please try again.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingL),
            if (onRetry != null)
              ElevatedButton(
                onPressed: onRetry,
                child: Text(retryLabel),
              ),
          ],
        ),
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppTheme.iconXL,
              color: AppTheme.textHint,
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppTheme.spacingS),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: AppTheme.spacingL),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final int? minLines;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final int? maxLength;
  final bool showCounter;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.minLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.maxLength,
    this.showCounter = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: _obscureText,
      maxLines: _obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      validator: widget.validator,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        suffixIcon: _getSuffixIcon(),
        counterText: widget.showCounter ? null : '',
      ),
    );
  }

  Widget? _getSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(widget.suffixIcon),
        onPressed: widget.onSuffixIconTap,
      );
    }
    return null;
  }
}

class RatingBar extends StatefulWidget {
  final double rating;
  final ValueChanged<double> onRatingChanged;
  final int itemCount;
  final double itemSize;
  final bool readOnly;

  const RatingBar({
    super.key,
    this.rating = 0,
    required this.onRatingChanged,
    this.itemCount = 5,
    this.itemSize = 32,
    this.readOnly = false,
  });

  @override
  State<RatingBar> createState() => _RatingBarState();
}

class _RatingBarState extends State<RatingBar> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.rating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        widget.itemCount,
        (index) => GestureDetector(
          onTap: widget.readOnly
              ? null
              : () {
                  setState(() {
                    _rating = (index + 1).toDouble();
                  });
                  widget.onRatingChanged(_rating);
                },
          child: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            size: widget.itemSize,
            color: AppTheme.accentColor,
          ),
        ),
      ),
    );
  }
}
