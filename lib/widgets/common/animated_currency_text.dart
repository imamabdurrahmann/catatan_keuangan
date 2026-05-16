import 'package:flutter/material.dart';
import 'package:catatan_keuangan/theme/app_colors.dart';
import 'package:catatan_keuangan/utils/formatters.dart';

// ==================== ANIMATED CURRENCY TEXT ====================
class AnimatedCurrencyText extends StatelessWidget {
  final double amount;
  final TextStyle? style;
  final String prefix;
  final bool showSign;
  final Color? positiveColor;
  final Color? negativeColor;
  final Duration duration;
  final Curve curve;

  const AnimatedCurrencyText({
    super.key,
    required this.amount,
    this.style,
    this.prefix = '',
    this.showSign = false,
    this.positiveColor,
    this.negativeColor,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = amount >= 0;
    final color = isPositive
        ? (positiveColor ?? AppColors.emerald)
        : (negativeColor ?? AppColors.coral);
    final sign = showSign ? (isPositive ? '+' : '-') : (amount < 0 ? '-' : '');

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: amount.abs()),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Text(
          '$sign$prefix${formatRupiah(value)}',
          style: (style ?? const TextStyle()).copyWith(color: color),
        );
      },
    );
  }
}

// ==================== ANIMATED CURRENCY TEXT WITH COUNTER ====================
/// Animated currency text that shows counter animation.
class AnimatedCurrencyCounter extends StatefulWidget {
  final double amount;
  final TextStyle? style;
  final String prefix;
  final bool showSign;
  final Color? positiveColor;
  final Color? negativeColor;
  final Duration duration;
  final bool enableAnimation;

  const AnimatedCurrencyCounter({
    super.key,
    required this.amount,
    this.style,
    this.prefix = '',
    this.showSign = false,
    this.positiveColor,
    this.negativeColor,
    this.duration = const Duration(milliseconds: 800),
    this.enableAnimation = true,
  });

  @override
  State<AnimatedCurrencyCounter> createState() => _AnimatedCurrencyCounterState();
}

class _AnimatedCurrencyCounterState extends State<AnimatedCurrencyCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousAmount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _setupAnimation();
  }

  @override
  void didUpdateWidget(AnimatedCurrencyCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount) {
      _previousAmount = oldWidget.amount;
      _setupAnimation();
      _controller.forward(from: 0);
    }
  }

  void _setupAnimation() {
    _animation = Tween<double>(
      begin: widget.enableAnimation ? _previousAmount : widget.amount,
      end: widget.amount,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = widget.amount >= 0;
    final color = isPositive
        ? (widget.positiveColor ?? AppColors.emerald)
        : (widget.negativeColor ?? AppColors.coral);
    final sign = widget.showSign
        ? (isPositive ? '+' : '-')
        : (widget.amount < 0 ? '-' : '');

    if (!widget.enableAnimation) {
      return Text(
        '$sign${widget.prefix}${formatRupiah(widget.amount.abs())}',
        style: (widget.style ?? const TextStyle()).copyWith(color: color),
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '$sign${widget.prefix}${formatRupiah(_animation.value.abs())}',
          style: (widget.style ?? const TextStyle()).copyWith(color: color),
        );
      },
    );
  }
}

// ==================== FADE SCALE CURRENCY TEXT ====================
/// Animated currency text with fade and scale effect.
class FadeScaleCurrencyText extends StatefulWidget {
  final double amount;
  final TextStyle? style;
  final String prefix;
  final bool showSign;
  final Color? positiveColor;
  final Color? negativeColor;
  final Duration duration;

  const FadeScaleCurrencyText({
    super.key,
    required this.amount,
    this.style,
    this.prefix = '',
    this.showSign = false,
    this.positiveColor,
    this.negativeColor,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<FadeScaleCurrencyText> createState() => _FadeScaleCurrencyTextState();
}

class _FadeScaleCurrencyTextState extends State<FadeScaleCurrencyText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  double _displayedAmount = 0;

  @override
  void initState() {
    super.initState();
    _displayedAmount = widget.amount;
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(FadeScaleCurrencyText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount) {
      _controller.forward(from: 0).then((_) {
        if (mounted) {
          setState(() {
            _displayedAmount = widget.amount;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = _displayedAmount >= 0;
    final color = isPositive
        ? (widget.positiveColor ?? AppColors.emerald)
        : (widget.negativeColor ?? AppColors.coral);
    final sign = widget.showSign
        ? (isPositive ? '+' : '-')
        : (_displayedAmount < 0 ? '-' : '');

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Text(
              '$sign${widget.prefix}${formatRupiah(_displayedAmount.abs())}',
              style: (widget.style ?? const TextStyle()).copyWith(color: color),
            ),
          ),
        );
      },
    );
  }
}
