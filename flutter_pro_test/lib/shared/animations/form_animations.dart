import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Enhanced form input widgets with smooth animations and micro-interactions
class AnimatedFormField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool isPassword;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final int maxLines;
  final TextInputAction textInputAction;
  final void Function(String)? onSubmitted;
  final bool showFloatingLabel;
  final Duration animationDuration;

  const AnimatedFormField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.isPassword = false,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.showFloatingLabel = true,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<AnimatedFormField> createState() => _AnimatedFormFieldState();
}

class _AnimatedFormFieldState extends State<AnimatedFormField>
    with TickerProviderStateMixin {
  late AnimationController _focusController;
  late AnimationController _errorController;
  late AnimationController _successController;
  late Animation<double> _labelAnimation;
  late Animation<Color?> _borderColorAnimation;
  late Animation<double> _errorShakeAnimation;
  late Animation<double> _successScaleAnimation;

  final FocusNode _focusNode = FocusNode();
  bool _obscureText = false;
  bool _hasError = false;
  bool _isValid = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText || widget.isPassword;

    _focusController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _errorController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _successController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _labelAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _focusController, curve: Curves.easeInOut),
    );

    _borderColorAnimation = ColorTween(
      begin: Theme.of(context).colorScheme.outline,
      end: Theme.of(context).colorScheme.primary,
    ).animate(CurvedAnimation(parent: _focusController, curve: Curves.easeInOut));

    _errorShakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _errorController, curve: Curves.elasticOut),
    );

    _successScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );

    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
  }

  @override
  void dispose() {
    _focusController.dispose();
    _errorController.dispose();
    _successController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus || widget.controller.text.isNotEmpty) {
      _focusController.forward();
    } else {
      _focusController.reverse();
    }
  }

  void _onTextChange() {
    if (widget.validator != null) {
      final error = widget.validator!(widget.controller.text);
      setState(() {
        _hasError = error != null;
        _errorMessage = error;
        _isValid = error == null && widget.controller.text.isNotEmpty;
      });

      if (_hasError) {
        _errorController.forward().then((_) {
          _errorController.reset();
        });
        _successController.reset();
      } else if (_isValid) {
        _successController.forward();
        _errorController.reset();
      }
    }

    if (widget.onChanged != null) {
      widget.onChanged!(widget.controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([
        _labelAnimation,
        _borderColorAnimation,
        _errorShakeAnimation,
        _successScaleAnimation,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            _errorShakeAnimation.value * 10 * (1 - _errorShakeAnimation.value),
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Floating label
              if (widget.showFloatingLabel) _buildFloatingLabel(theme),
              
              // Text field
              _buildTextField(theme),
              
              // Error message with animation
              if (_hasError && _errorMessage != null)
                _buildErrorMessage(theme),
              
              // Success indicator
              if (_isValid) _buildSuccessIndicator(theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingLabel(ThemeData theme) {
    return AnimatedContainer(
      duration: widget.animationDuration,
      height: _labelAnimation.value > 0.5 ? 20.h : 0,
      child: AnimatedOpacity(
        duration: widget.animationDuration,
        opacity: _labelAnimation.value,
        child: Text(
          widget.label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: _hasError
                ? theme.colorScheme.error
                : _isValid
                    ? Colors.green
                    : theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(ThemeData theme) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      obscureText: _obscureText,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      style: TextStyle(
        fontSize: 16.sp,
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: TextStyle(
          fontSize: 16.sp,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        prefixIcon: widget.prefixIcon,
        suffixIcon: _buildSuffixIcon(theme),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: _borderColorAnimation.value ?? theme.colorScheme.outline,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: _hasError
                ? theme.colorScheme.error
                : _isValid
                    ? Colors.green
                    : theme.colorScheme.outline,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: _hasError
                ? theme.colorScheme.error
                : _isValid
                    ? Colors.green
                    : theme.colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 16.h,
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon(ThemeData theme) {
    if (widget.isPassword) {
      return IconButton(
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            key: ValueKey(_obscureText),
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    if (_isValid) {
      return Transform.scale(
        scale: _successScaleAnimation.value,
        child: Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 20.sp,
        ),
      );
    }

    if (_hasError) {
      return Icon(
        Icons.error,
        color: theme.colorScheme.error,
        size: 20.sp,
      );
    }

    return widget.suffixIcon;
  }

  Widget _buildErrorMessage(ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 20.h,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _hasError ? 1.0 : 0.0,
        child: Padding(
          padding: EdgeInsets.only(top: 4.h, left: 16.w),
          child: Text(
            _errorMessage!,
            style: TextStyle(
              fontSize: 12.sp,
              color: theme.colorScheme.error,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIndicator(ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 20.h,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _isValid ? 1.0 : 0.0,
        child: Padding(
          padding: EdgeInsets.only(top: 4.h, left: 16.w),
          child: Row(
            children: [
              Transform.scale(
                scale: _successScaleAnimation.value,
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 12.sp,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                'Valid',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated search field with suggestions
class AnimatedSearchField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final List<String> suggestions;
  final Widget Function(String)? suggestionBuilder;
  final Duration animationDuration;

  const AnimatedSearchField({
    super.key,
    required this.hint,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.suggestions = const [],
    this.suggestionBuilder,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<AnimatedSearchField> createState() => _AnimatedSearchFieldState();
}

class _AnimatedSearchFieldState extends State<AnimatedSearchField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  final FocusNode _focusNode = FocusNode();
  bool _showSuggestions = false;
  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && _filteredSuggestions.isNotEmpty) {
      setState(() => _showSuggestions = true);
      _controller.forward();
    } else {
      setState(() => _showSuggestions = false);
      _controller.reverse();
    }
  }

  void _onTextChange() {
    final query = widget.controller.text.toLowerCase();
    setState(() {
      _filteredSuggestions = widget.suggestions
          .where((suggestion) => suggestion.toLowerCase().contains(query))
          .take(5)
          .toList();
    });

    if (_filteredSuggestions.isNotEmpty && _focusNode.hasFocus) {
      setState(() => _showSuggestions = true);
      _controller.forward();
    } else {
      setState(() => _showSuggestions = false);
      _controller.reverse();
    }

    if (widget.onChanged != null) {
      widget.onChanged!(widget.controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          onFieldSubmitted: widget.onSubmitted,
          style: TextStyle(
            fontSize: 16.sp,
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              fontSize: 16.sp,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    onPressed: () {
                      widget.controller.clear();
                      _onTextChange();
                    },
                  )
                : null,
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
        ),
        
        // Animated suggestions dropdown
        AnimatedBuilder(
          animation: _expandAnimation,
          builder: (context, child) {
            return ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: _expandAnimation.value,
                child: _showSuggestions ? _buildSuggestions(theme) : null,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSuggestions(ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(top: 4.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: theme.colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _filteredSuggestions.length,
        itemBuilder: (context, index) {
          final suggestion = _filteredSuggestions[index];
          return InkWell(
            onTap: () {
              widget.controller.text = suggestion;
              _focusNode.unfocus();
              if (widget.onSubmitted != null) {
                widget.onSubmitted!(suggestion);
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: widget.suggestionBuilder?.call(suggestion) ??
                  Text(
                    suggestion,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
            ),
          );
        },
      ),
    );
  }
}
