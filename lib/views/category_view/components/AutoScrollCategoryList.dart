import 'package:car_service/models/category_model.dart' show Category;
import 'package:car_service/views/category_view/components/category_card.dart' show CategoryCard;
import 'package:flutter/material.dart';
import 'dart:async';

class AutoScrollCategoryList extends StatefulWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final Function(Category) onCategoryTap;
  
  const AutoScrollCategoryList({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    required this.onCategoryTap,
  });

  @override
  State<AutoScrollCategoryList> createState() => _AutoScrollCategoryListState();
}

class _AutoScrollCategoryListState extends State<AutoScrollCategoryList> {
  final ScrollController _scrollController = ScrollController();
  Timer? _autoScrollTimer;
  bool _isUserInteracting = false;
  double _currentPosition = 0;

  @override
  void initState() {
    super.initState();
    print('🔵 AutoScrollCategoryList: initState called');
    print('🔵 Categories count: ${widget.categories.length}');
    
    // Start auto-scroll after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🟢 PostFrameCallback: executed');
      print('🟢 ScrollController hasClients: ${_scrollController.hasClients}');
      
      if (_scrollController.hasClients) {
        print('🟢 MaxScrollExtent: ${_scrollController.position.maxScrollExtent}');
      }
      
      // Wait a bit longer to ensure the list is fully rendered
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          print('🟡 Delayed callback: executing startAutoScroll');
          _startAutoScroll();
        } else {
          print('🔴 Widget not mounted');
        }
      });
    });
  }

  void _startAutoScroll() {
    print('🚀 _startAutoScroll called');
    _autoScrollTimer?.cancel();
    
    // Don't start if user is interacting or controller not attached
    if (_isUserInteracting) {
      print('🔴 User is interacting, not starting');
      return;
    }
    
    if (!_scrollController.hasClients) {
      print('🔴 ScrollController has no clients');
      return;
    }

    final maxScroll = _scrollController.position.maxScrollExtent;
    print('✅ Starting auto-scroll! MaxScroll: $maxScroll');
    
    if (maxScroll <= 0) {
      print('🔴 MaxScroll is 0 or negative - nothing to scroll');
      return;
    }
    
    // Continuous smooth scroll
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (!_isUserInteracting && _scrollController.hasClients && mounted) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        
        if (maxScroll <= 0) {
          timer.cancel();
          return;
        }
        
        _currentPosition += 0.5; // Scroll speed
        
        // Loop back to start when reaching end
        if (_currentPosition >= maxScroll) {
          _scrollController.jumpTo(0);
          _currentPosition = 0;
          print('🔄 Looped back to start');
        } else {
          _scrollController.jumpTo(_currentPosition);
        }
      }
    });
    
    print('✅ Timer started successfully');
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    setState(() {
      _isUserInteracting = true;
    });
    
    print('⏸️ Auto-scroll stopped');
    
    // Resume auto-scroll after 3 seconds of no interaction
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isUserInteracting = false;
        });
        _currentPosition = _scrollController.offset;
        _startAutoScroll();
        print('▶️ Auto-scroll resumed');
      }
    });
  }

  @override
  void dispose() {
    print('🔴 Disposing AutoScrollCategoryList');
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🔨 Building AutoScrollCategoryList');
    
    return GestureDetector(
      onPanDown: (_) => _stopAutoScroll(),
      onTap: () => _stopAutoScroll(),
      child: SizedBox(
        height: 60,
        child: ListView.separated(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: widget.categories.length,
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final category = widget.categories[index];
            return GestureDetector(
              onTap: () {
                widget.onCategoryTap(category);
                _stopAutoScroll();
              },
              child: CategoryCard(
                category: category,
                isSelected: widget.selectedCategoryId == category.id,
              ),
            );
          },
        ),
      ),
    );
  }
}
// ```

// **Run this and check your debug console.** You should see output like:
// ```
// 🔵 AutoScrollCategoryList: initState called
// 🔵 Categories count: 5
// 🔨 Building AutoScrollCategoryList
// 🟢 PostFrameCallback: executed
// 🟢 ScrollController hasClients: true
// 🟢 MaxScrollExtent: 450.0
// 🟡 Delayed callback: executing startAutoScroll
// 🚀 _startAutoScroll called
// ✅ Starting auto-scroll! MaxScroll: 450.0
// ✅ Timer started successfully