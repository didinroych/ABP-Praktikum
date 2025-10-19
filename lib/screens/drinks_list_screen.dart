import 'package:flutter/material.dart';
import '../models/drink.dart';
import '../services/drink_api_service.dart';
import 'drink_form_screen.dart';
import 'drink_detail_screen.dart';

class DrinksListScreen extends StatefulWidget {
  const DrinksListScreen({Key? key}) : super(key: key);

  @override
  State<DrinksListScreen> createState() => _DrinksListScreenState();
}

class _DrinksListScreenState extends State<DrinksListScreen> {
  final DrinkApiService _apiService = DrinkApiService();
  List<Drink> _drinks = [];
  List<Drink> _filteredDrinks = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = ['All', 'Coffee', 'Tea', 'Juice', 'Smoothie', 'Traditional'];

  @override
  void initState() {
    super.initState();
    _loadDrinks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDrinks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final drinks = await _apiService.getAllDrinks();
      setState(() {
        _drinks = drinks;
        _filteredDrinks = drinks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterDrinks(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDrinks = _drinks;
      } else {
        _filteredDrinks = _drinks.where((drink) {
          return drink.name.toLowerCase().contains(query.toLowerCase()) ||
              drink.description.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _deleteDrink(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Drink?'),
        content: Text('Are you sure you want to remove "$name" from the menu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.deleteDrink(id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name deleted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        _loadDrinks();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatCurrency(int price) {
    return 'Rp ${price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
    )}';
  }

  IconData _getDrinkIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('kopi') || lowerName.contains('coffee')) {
      return Icons.coffee;
    } else if (lowerName.contains('teh') || lowerName.contains('tea')) {
      return Icons.emoji_food_beverage;
    } else if (lowerName.contains('jus') || lowerName.contains('juice')) {
      return Icons.local_drink;
    } else if (lowerName.contains('smoothie')) {
      return Icons.icecream;
    } else if (lowerName.contains('air') || lowerName.contains('water')) {
      return Icons.water_drop;
    }
    return Icons.local_cafe;
  }

  Color _getDrinkColor(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('kopi') || lowerName.contains('coffee')) {
      return const Color(0xFF8B4513);
    } else if (lowerName.contains('teh') || lowerName.contains('tea')) {
      return const Color(0xFF90EE90);
    } else if (lowerName.contains('jus') || lowerName.contains('juice')) {
      return const Color(0xFFFF6B6B);
    } else if (lowerName.contains('smoothie')) {
      return const Color(0xFFFF69B4);
    } else if (lowerName.contains('matcha')) {
      return const Color(0xFF7CB342);
    }
    return const Color(0xFF4ECDC4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Drinks Menu',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_filteredDrinks.length} drinks available',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DrinkFormScreen(),
                              ),
                            );
                            if (result == true) _loadDrinks();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterDrinks,
                      decoration: InputDecoration(
                        hintText: 'Search drinks...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filterDrinks('');
                          },
                        )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFFC107),
                ),
              )
                  : _errorMessage != null
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Oops! Something went wrong',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loadDrinks,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text('Try Again', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              )
                  : _filteredDrinks.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_cafe, size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'No drinks found',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
                  : RefreshIndicator(
                color: const Color(0xFFFFC107),
                onRefresh: _loadDrinks,
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _filteredDrinks.length,
                  itemBuilder: (context, index) {
                    final drink = _filteredDrinks[index];
                    return _buildDrinkCard(drink);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrinkCard(Drink drink) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DrinkDetailScreen(drinkId: drink.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: _getDrinkColor(drink.name).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      _getDrinkIcon(drink.name),
                      size: 60,
                      color: _getDrinkColor(drink.name),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: PopupMenuButton(
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.more_vert, size: 20),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 12),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 12),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) async {
                        if (value == 'edit') {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DrinkFormScreen(drink: drink),
                            ),
                          );
                          if (result == true) _loadDrinks();
                        } else if (value == 'delete') {
                          _deleteDrink(drink.id, drink.name);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      drink.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _formatCurrency(drink.price),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFC107),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC107).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, size: 14, color: Color(0xFFFFC107)),
                              const SizedBox(width: 4),
                              Text(
                                drink.rating,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}