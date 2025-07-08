import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Enhanced list animations with staggered effects and smooth transitions
class ListAnimations {
  /// Staggered animation for list items
  static Widget staggeredList({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    Duration delay = const Duration(milliseconds: 100),
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOutCubic,
    Axis scrollDirection = Axis.vertical,
    EdgeInsetsGeometry? padding,
    ScrollPhysics? physics,
  }) {
    return ListView.builder(
      itemCount: itemCount,
      scrollDirection: scrollDirection,
      padding: padding,
      physics: physics,
      itemBuilder: (context, index) {
        return StaggeredListItem(
          index: index,
          delay: delay,
          duration: duration,
          curve: curve,
          child: itemBuilder(context, index),
        );
      },
    );
  }

  /// Animated list item with slide and fade
  static Widget slideAndFadeItem({
    required Widget child,
    required int index,
    Duration delay = const Duration(milliseconds: 100),
    Duration duration = const Duration(milliseconds: 400),
    SlideDirection direction = SlideDirection.fromLeft,
  }) {
    return StaggeredListItem(
      index: index,
      delay: delay,
      duration: duration,
      slideDirection: direction,
      child: child,
    );
  }

  /// Animated grid with staggered effect
  static Widget staggeredGrid({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    required int crossAxisCount,
    Duration delay = const Duration(milliseconds: 50),
    Duration duration = const Duration(milliseconds: 300),
    double childAspectRatio = 1.0,
    double crossAxisSpacing = 8.0,
    double mainAxisSpacing = 8.0,
    EdgeInsetsGeometry? padding,
  }) {
    return GridView.builder(
      itemCount: itemCount,
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      itemBuilder: (context, index) {
        return StaggeredListItem(
          index: index,
          delay: delay,
          duration: duration,
          child: itemBuilder(context, index),
        );
      },
    );
  }

  /// Swipe to dismiss with animation
  static Widget swipeToDismiss({
    required Widget child,
    required VoidCallback onDismissed,
    String? confirmationText,
    Color? backgroundColor,
    IconData? icon,
    DismissDirection direction = DismissDirection.endToStart,
  }) {
    return SwipeToDeleteItem(
      onDismissed: onDismissed,
      confirmationText: confirmationText,
      backgroundColor: backgroundColor,
      icon: icon,
      direction: direction,
      child: child,
    );
  }
}

/// Staggered list item widget
class StaggeredListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final SlideDirection slideDirection;

  const StaggeredListItem({
    super.key,
    required this.child,
    required this.index,
    this.delay = const Duration(milliseconds: 100),
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOutCubic,
    this.slideDirection = SlideDirection.fromLeft,
  });

  @override
  State<StaggeredListItem> createState() => _StaggeredListItemState();
}

class _StaggeredListItemState extends State<StaggeredListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _slideAnimation = Tween<Offset>(
      begin: _getSlideOffset(),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    // Start animation with delay
    Future.delayed(
      Duration(milliseconds: widget.index * widget.delay.inMilliseconds),
      () {
        if (mounted) {
          _controller.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _getSlideOffset() {
    switch (widget.slideDirection) {
      case SlideDirection.fromLeft:
        return const Offset(-1.0, 0.0);
      case SlideDirection.fromRight:
        return const Offset(1.0, 0.0);
      case SlideDirection.fromTop:
        return const Offset(0.0, -1.0);
      case SlideDirection.fromBottom:
        return const Offset(0.0, 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

/// Swipe to delete item widget
class SwipeToDeleteItem extends StatefulWidget {
  final Widget child;
  final VoidCallback onDismissed;
  final String? confirmationText;
  final Color? backgroundColor;
  final IconData? icon;
  final DismissDirection direction;

  const SwipeToDeleteItem({
    super.key,
    required this.child,
    required this.onDismissed,
    this.confirmationText,
    this.backgroundColor,
    this.icon,
    this.direction = DismissDirection.endToStart,
  });

  @override
  State<SwipeToDeleteItem> createState() => _SwipeToDeleteItemState();
}

class _SwipeToDeleteItemState extends State<SwipeToDeleteItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Dismissible(
              key: UniqueKey(),
              direction: widget.direction,
              onDismissed: (direction) {
                _controller.forward().then((_) {
                  widget.onDismissed();
                });
              },
              confirmDismiss: widget.confirmationText != null
                  ? (direction) => _showConfirmationDialog()
                  : null,
              background: Container(
                color: widget.backgroundColor ?? Colors.red,
                alignment: widget.direction == DismissDirection.endToStart
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Icon(
                  widget.icon ?? Icons.delete,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _showConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(widget.confirmationText!),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Animated list view with pull-to-refresh
class AnimatedRefreshableList extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final Future<void> Function() onRefresh;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  const AnimatedRefreshableList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.onRefresh,
    this.padding,
    this.physics,
  });

  @override
  State<AnimatedRefreshableList> createState() => _AnimatedRefreshableListState();
}

class _AnimatedRefreshableListState extends State<AnimatedRefreshableList>
    with TickerProviderStateMixin {
  late AnimationController _refreshController;
  late Animation<double> _refreshAnimation;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _refreshAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _refreshController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _refreshController.forward();
        await widget.onRefresh();
        _refreshController.reverse();
      },
      child: AnimatedBuilder(
        animation: _refreshAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_refreshAnimation.value * 0.05),
            child: ListView.builder(
              itemCount: widget.itemCount,
              padding: widget.padding,
              physics: widget.physics,
              itemBuilder: (context, index) {
                return StaggeredListItem(
                  index: index,
                  delay: const Duration(milliseconds: 50),
                  child: widget.itemBuilder(context, index),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// Slide directions for list items
enum SlideDirection {
  fromLeft,
  fromRight,
  fromTop,
  fromBottom,
}

/// Expandable list item with animation
class ExpandableListItem extends StatefulWidget {
  final Widget header;
  final Widget content;
  final bool initiallyExpanded;
  final Duration duration;

  const ExpandableListItem({
    super.key,
    required this.header,
    required this.content,
    this.initiallyExpanded = false,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<ExpandableListItem> createState() => _ExpandableListItemState();
}

class _ExpandableListItemState extends State<ExpandableListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _iconRotationAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _iconRotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _toggleExpansion,
          child: Row(
            children: [
              Expanded(child: widget.header),
              AnimatedBuilder(
                animation: _iconRotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _iconRotationAnimation.value * 3.14159,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 24.sp,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        SizeTransition(
          sizeFactor: _expandAnimation,
          child: widget.content,
        ),
      ],
    );
  }
}
