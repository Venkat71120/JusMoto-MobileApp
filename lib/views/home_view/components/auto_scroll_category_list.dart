import 'package:car_service/models/category_model.dart';
import 'package:car_service/views/category_view/components/category_card.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class AutoScrollCategoryList extends StatefulWidget {
  final List<Category> categories;
  final Function(Category) onCategoryTap;
  
  const AutoScrollCategoryList({
    super.key,
    required this.categories,
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
    print('🔵 AutoScrollCategoryList: initState - ${widget.categories.length} categories');
    
    // Start auto-scroll after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🟢 PostFrameCallback executed');
      
      // Give extra time for layout to complete
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && _scrollController.hasClients) {
          print('🟡 Starting auto-scroll...');
          print('🟡 MaxScroll: ${_scrollController.position.maxScrollExtent}');
          _startAutoScroll();
        } else {
          print('🔴 Cannot start - mounted: $mounted, hasClients: ${_scrollController.hasClients}');
        }
      });
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    
    if (_isUserInteracting || !_scrollController.hasClients) {
      print('🔴 Not starting: interacting=$_isUserInteracting, hasClients=${_scrollController.hasClients}');
      return;
    }

    final maxScroll = _scrollController.position.maxScrollExtent;
    
    if (maxScroll <= 0) {
      print('🔴 MaxScroll is $maxScroll - nothing to scroll');
      return;
    }
    
    print('✅ Auto-scroll STARTED! MaxScroll: $maxScroll');
    
    // Continuous smooth scroll
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!_isUserInteracting && _scrollController.hasClients && mounted) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        
        if (maxScroll <= 0) {
          timer.cancel();
          return;
        }
        
        _currentPosition += 1.0; // Scroll speed (increase for faster)
        
        // Loop back to start when reaching end
        if (_currentPosition >= maxScroll) {
          _scrollController.jumpTo(0);
          _currentPosition = 0;
        } else {
          _scrollController.jumpTo(_currentPosition);
        }
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    setState(() {
      _isUserInteracting = true;
    });
    
    print('⏸️ Auto-scroll paused');
    
    // Resume auto-scroll after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isUserInteracting = false;
        });
        if (_scrollController.hasClients) {
          _currentPosition = _scrollController.offset;
        }
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
    return GestureDetector(
      onPanDown: (_) => _stopAutoScroll(),
      onTapDown: (_) => _stopAutoScroll(),
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Wrap(
          spacing: 12,
          children: widget.categories.map((cat) {
            return GestureDetector(
              onTap: () {
                widget.onCategoryTap(cat);
                _stopAutoScroll();
              },
              child: CategoryCard(category: cat),
            );
          }).toList(),
        ),
      ),
    );
  }
}