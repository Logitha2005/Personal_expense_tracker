import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/expense.dart';
import '../utils/validators.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expense;

  const AddExpenseScreen({Key? key, this.expense}) : super(key: key);

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<String> _categories = [];
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();

    if (widget.expense != null) {
      _amountController.text = widget.expense!.amount.toString();
      _descriptionController.text = widget.expense!.description;
      _selectedCategory = widget.expense!.category;
      _selectedDate = widget.expense!.date;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showAlert(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _loadCategories() async {
    try {
      final result = await ApiService.getCategories();

      if (result['success']) {
        setState(() {
          _categories = List<String>.from(result['data']);
          _isLoadingCategories = false;
        });
      } else {
        _showAlert('Failed to load categories', false);
        setState(() {
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      _showAlert('Failed to load categories', false);
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      _showAlert('Please select a category', false);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text);
      final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);

      Map<String, dynamic> result;

      if (widget.expense != null) {
        result = await ApiService.updateExpense(
          widget.expense!.id,
          {
            'category': _selectedCategory,
            'amount': amount,
            'date': dateString,
            'description': _descriptionController.text.trim(),
          },
        );
      } else {
        result = await ApiService.addExpense(
          _selectedCategory!,
          amount,
          dateString,
          _descriptionController.text.trim(),
        );
      }

      if (result['success']) {
        _showAlert(
          widget.expense != null
              ? 'Expense updated successfully'
              : 'Expense added successfully',
          true,
        );
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        _showAlert(result['message'], false);
      }
    } catch (e) {
      _showAlert('An error occurred. Please try again.', false);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense != null ? 'Edit Expense' : 'Add Expense'),
      ),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                      validator: Validators.validateAmount,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('MMM dd, yyyy').format(_selectedDate),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        prefixIcon: Icon(Icons.notes),
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveExpense,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              widget.expense != null
                                  ? 'Update Expense'
                                  : 'Add Expense',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
