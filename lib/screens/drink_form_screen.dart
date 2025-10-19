import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/drink.dart';
import '../services/drink_api_service.dart';

class DrinkFormScreen extends StatefulWidget {
  final Drink? drink;

  const DrinkFormScreen({Key? key, this.drink}) : super(key: key);

  @override
  State<DrinkFormScreen> createState() => _DrinkFormScreenState();
}

class _DrinkFormScreenState extends State<DrinkFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _ratingController = TextEditingController();
  final DrinkApiService _apiService = DrinkApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.drink != null) {
      _nameController.text = widget.drink!.name;
      _descriptionController.text = widget.drink!.description;
      _priceController.text = widget.drink!.price.toString();
      _ratingController.text = widget.drink!.rating;
    } else {
      _ratingController.text = '1.0';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  Future<void> _saveDrink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final drink = Drink(
        id: widget.drink?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: int.parse(_priceController.text),
        rating: _ratingController.text,
        createdAt: widget.drink?.createdAt ?? '',
        updatedAt: widget.drink?.updatedAt ?? '',
      );

      if (widget.drink == null) {
        await _apiService.createDrink(drink);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Drink created successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } else {
        await _apiService.updateDrink(widget.drink!.id, drink);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Drink updated successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.drink != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
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
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      isEdit ? 'Edit Drink' : 'Add New Drink',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFC107)),
              )
                  : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Drink Name
                      const Text(
                        'Drink Name',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'e.g., Es Kopi Susu',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon: const Icon(Icons.local_drink, color: Color(0xFFFFC107)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(20),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter drink name';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Description
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            hintText: 'Describe your drink...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon: const Icon(Icons.description, color: Color(0xFFFFC107)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(20),
                          ),
                          maxLines: 4,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter description';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Price and Rating Row
                      Row(
                        children: [
                          // Price
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Price (Rp)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: TextFormField(
                                    controller: _priceController,
                                    decoration: InputDecoration(
                                      hintText: '15,000',
                                      hintStyle: TextStyle(color: Colors.grey[400]),
                                      prefixIcon: const Icon(Icons.attach_money, color: Color(0xFFFFC107)),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.all(20),
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Required';
                                      }
                                      final price = int.tryParse(value);
                                      if (price == null || price < 0) {
                                        return 'Invalid price';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Rating
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Rating',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: TextFormField(
                                    controller: _ratingController,
                                    decoration: InputDecoration(
                                      hintText: '4.5',
                                      hintStyle: TextStyle(color: Colors.grey[400]),
                                      prefixIcon: const Icon(Icons.star, color: Color(0xFFFFC107)),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.all(20),
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Required';
                                      }
                                      final rating = double.tryParse(value);
                                      if (rating == null || rating < 1.0 || rating > 5.0) {
                                        return '1.0-5.0';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Submit Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveDrink,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC107),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          isEdit ? 'Update Drink' : 'Add Drink',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      if (isEdit) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Created: ${widget.drink!.createdAt}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}