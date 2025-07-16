import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddIncomeScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const AddIncomeScreen({super.key, this.initialData});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final uuid = Uuid(); 
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();

    // Jika ada data yang dikirim (mode edit), isi form dengan data tersebut
    if (widget.initialData != null) {
      final data = widget.initialData!;
      amountController.text = data['amount']?.toString() ?? '';
      descriptionController.text = data['description'] ?? '';
      if (data['date'] != null) {
        selectedDate = DateTime.tryParse(data['date']);
      }
    }
  }

  String get formattedDate {
    if (selectedDate == null) return 'Pilih Tanggal';
    return DateFormat('dd MMMM yyyy').format(selectedDate!);
  }

  Future<void> pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? today,
      firstDate: DateTime(today.year - 5),
      lastDate: DateTime(today.year + 5),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void saveIncome() {
    final amountText = amountController.text.trim();
    final description = descriptionController.text.trim();

    if (amountText.isEmpty || description.isEmpty || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mohon lengkapi semua data')),
      );
      return;
    }

    final incomeData = {
      'id': widget.initialData?['id'] ?? uuid.v4(),
      'amount': int.tryParse(amountText) ?? 0,
      'description': description,
      'date': selectedDate!.toIso8601String(),
    };

    Navigator.pop(context, incomeData);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialData != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Pemasukan' : 'Tambah Pemasukan', 
          style: TextStyle(
            color: Colors.white,
            fontSize: 18
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah (Rp)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Keterangan',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            InkWell(
              onTap: pickDate,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.date_range, color: Colors.deepPurple),
                    SizedBox(width: 12),
                    Text(
                      formattedDate,
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveIncome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  isEditing ? 'Simpan Perubahan' : 'Tambah Pemasukan',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
