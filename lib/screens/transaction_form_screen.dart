import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'receita';
  String _category = '';
  double _value = 0.0;
  DateTime _selectedDate = DateTime.now();
  final _descriptionController = TextEditingController();

  final _categories = {
    'receita': ['Salário', 'Freelance', 'Outros'],
    'despesa': ['Alimentação', 'Transporte', 'Contas', 'Lazer', 'Outros'],
  };

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) return;

      final data = {
        'tipo': _type,
        'valor': _value, // ✅ nunca null
        'categoria': _category,
        'data': Timestamp.fromDate(_selectedDate),
        'descricao': _descriptionController.text.trim(),
        'createdAt': Timestamp.now(),
        'userId': userId,
      };

      try {
        await FirebaseFirestore.instance.collection('transacoes').add(data);
        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        debugPrint('Erro ao salvar transação: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar transação.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatDate = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Nova Transação')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('Receita'),
                    selected: _type == 'receita',
                    onSelected: (_) => setState(() {
                      _type = 'receita';
                      _category = '';
                    }),
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text('Despesa'),
                    selected: _type == 'despesa',
                    onSelected: (_) => setState(() {
                      _type = 'despesa';
                      _category = '';
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Valor (R\$)'),
                validator: (value) {
                  final val = double.tryParse(value ?? '');
                  if (val == null || val <= 0) return 'Informe um valor válido';
                  return null;
                },
                onChanged: (val) => _value = double.tryParse(val) ?? 0.0,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category.isNotEmpty ? _category : null,
                items: _categories[_type]!
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                decoration: const InputDecoration(labelText: 'Categoria'),
                onChanged: (val) => setState(() => _category = val ?? ''),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Selecione uma categoria' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Data'),
                subtitle: Text(formatDate.format(_selectedDate)),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Observações (opcional)'),
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Salvar'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
