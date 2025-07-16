import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // untuk DateFormat
import 'package:mykeu/add_income_screen.dart';
import 'add_expense_screen.dart';
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyKeu',
      home: _HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _HomeScreen extends StatefulWidget {
  const _HomeScreen({super.key});

  @override
  State<_HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<_HomeScreen> {
  int selectedTab = 0;
  num totalIncome = 0;
  num totalExpense = 0;
  DateTime selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  List<Map<String, dynamic>> expenseList = [];
  List<Map<String, dynamic>> incomeList = [];
  
  List<Map<String, dynamic>> getFilteredList(List<Map<String, dynamic>> list) {
    return list.where((item) {
      if (item['date'] == null) return false;
      final date = DateTime.tryParse(item['date']);
      return date != null &&
          date.month == selectedMonth.month &&
          date.year == selectedMonth.year;
  }).toList();
  }

  List<Map<String, dynamic>> get filteredIncomeList =>
    getFilteredList(incomeList);

  List<Map<String, dynamic>> get filteredExpenseList =>
    getFilteredList(expenseList);

  @override
  void initState() {
    super.initState();
    loadIncomeData();
    loadExpenseData();
  }

  void loadIncomeData() async {
  final prefs = await SharedPreferences.getInstance();
  final storedIncomeData = prefs.getString('incomeList');
  final storedIncomeTotal = prefs.getDouble('totalIncome') ?? 0;
  final storedExpenseData = prefs.getString('expenseList');
  final storedExpenseTotal = prefs.getDouble('totalExpense') ?? 0;

  List<Map<String, dynamic>> allIncome = storedIncomeData != null
      ? (jsonDecode(storedIncomeData) as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList()
      : [];
  List<Map<String, dynamic>> allExpense = storedExpenseData != null
      ? (jsonDecode(storedExpenseData) as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList()
      : [];
   
  setState(() {
    totalExpense = storedExpenseTotal;
    expenseList = allExpense;
    totalIncome = storedIncomeTotal;
    incomeList = allIncome;
  });
}



  void saveIncomeData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('incomeList', jsonEncode(incomeList));
    await prefs.setDouble('totalIncome', totalIncome.toDouble());

    // await prefs.setString('expenseList', jsonEncode(expenseList));
    // await prefs.setDouble('totalExpense', totalExpense.toDouble());
  }


  void loadExpenseData() async {
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('expenseList');
    final storedTotal = prefs.getDouble('totalExpense') ?? 0;
    List<Map<String, dynamic>> allExpense = storedData != null
      ? (jsonDecode(storedData) as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList()
      : [];
    setState(() {
      totalExpense = storedTotal;
      expenseList = allExpense;
    });
  }

  void saveExpenseData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('expenseList', jsonEncode(expenseList));
    await prefs.setDouble('totalExpense', totalExpense.toDouble());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: Column(
        children: [
          // Header Tabs
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MyKeu',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    // Pemasukan Tab
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => selectedTab = 0),
                        child: Column(
                          children: [
                            const SizedBox(height: 30),
                            Icon(Icons.archive,
                                size: 40,
                                color: selectedTab == 0
                                    ? Colors.deepPurple
                                    : Colors.grey),
                            const SizedBox(height: 10),
                            Text(
                              'Pemasukan',
                              style: TextStyle(
                                  color: selectedTab == 0
                                      ? Colors.black
                                      : Colors.grey,
                                  fontSize: 12),
                            ),
                            const SizedBox(height: 12),
                            if (selectedTab == 0)
                              Container(
                                height: 3,
                                width: 100,
                                decoration: BoxDecoration(
                                    color: Colors.deepPurple,
                                    borderRadius: BorderRadius.circular(18)),
                              ),
                          ],
                        ),
                      ),
                    ),
                    // Pengeluaran Tab
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => selectedTab = 1),
                        child: Column(
                          children: [
                            const SizedBox(height: 30),
                            Icon(Icons.unarchive,
                                size: 40,
                                color: selectedTab == 1
                                    ? Colors.deepPurple
                                    : Colors.grey),
                            const SizedBox(height: 10),
                            Text(
                              'Pengeluaran',
                              style: TextStyle(
                                  color: selectedTab == 1
                                      ? Colors.black
                                      : Colors.grey,
                                  fontSize: 12),
                            ),
                            const SizedBox(height: 12),
                            if (selectedTab == 1)
                              Container(
                                height: 3,
                                width: 100,
                                decoration: BoxDecoration(
                                    color: Colors.deepPurple,
                                    borderRadius: BorderRadius.circular(18)),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Dropdown Filter Bulan
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: DropdownButtonFormField<DateTime>(
              dropdownColor: Colors.white,
              value: selectedMonth,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: 'Pilih Bulan',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: List.generate(12, (index) {
                final now = DateTime.now();
                final month = DateTime(now.year, index + 1);
                return DropdownMenuItem(
                  value: month,
                  child: Text(DateFormat('MMMM yyyy').format(month)),
                );
              }),
              onChanged: (DateTime? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedMonth = newValue;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 20),


          // Ringkasan Total
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedTab == 0
                        ? 'Total Pemasukan Bulan Ini'
                        : 'Total Pengeluaran Bulan Ini',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedTab == 0
                      ? 'Rp. ${getFilteredList(incomeList).fold<num>(0, (sum, item) => sum + (item['amount'] ?? 0)).toStringAsFixed(0)}'
                      : 'Rp. ${getFilteredList(expenseList).fold<num>(0, (sum, item) => sum + (item['amount'] ?? 0)).toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.grey),
                  ),

                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // List Card
          if (selectedTab == 0)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: filteredIncomeList.length,
                itemBuilder: (context, index) {
                  final item = filteredIncomeList[index];
                  final date = item['date'] != null
                      ? DateFormat('dd MMM yyyy')
                          .format(DateTime.parse(item['date']))
                      : '';

                  return Card(
                    color: Colors.white,
                    margin: EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Keterangan, Jumlah, Tanggal
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['description'] ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Nominal: Rp${item['amount']}',
                                  style: TextStyle(
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4),
                                if (date.isNotEmpty)
                                  Text(
                                    'Tanggal: ${date}'
                                    ,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Tombol edit dan delete
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.deepPurple),
                                onPressed: () async {
                                  final editedResult = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AddIncomeScreen(initialData: item),
                                    ),
                                  );

                                  if (editedResult != null && editedResult is Map<String, dynamic>) {
                                    final id = editedResult['id'];
                                    final originalIndex = incomeList.indexWhere((e) => e['id'] == id);

                                    if (originalIndex != -1) {
                                      setState(() {
                                        incomeList[originalIndex] = editedResult;
                                        totalIncome = incomeList.fold(0, (sum, item) => sum + (item['amount'] ?? 0));
                                      });
                                      saveIncomeData();
                                    }
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text("Hapus Pemasukan"),
                                      content: Text("Yakin ingin menghapus pemasukan ini?"),
                                      backgroundColor: Colors.white,
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("Batal")),
                                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text("Hapus")),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    setState(() {
                                      totalIncome -= (getFilteredList(incomeList)[index]['amount'] ?? 0).toInt();
                                      incomeList.removeAt(index);
                                    });
                                    saveIncomeData();
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Expanded(
              child: expenseList.isEmpty
                  ? const Center(child: Text("Belum ada data pengeluaran"))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredExpenseList.length,
                      itemBuilder: (context, index) {
                        final item = filteredExpenseList[index];
                        final date = item['date'] != null
                            ? DateFormat('dd MMM yyyy')
                                .format(DateTime.parse(item['date']))
                            : '';

                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Keterangan, Jumlah, Tanggal
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['description'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Nominal: Rp${item['amount']}',
                                        style: const TextStyle(color: Colors.black87),
                                      ),
                                      const SizedBox(height: 4),
                                      if (date.isNotEmpty)
                                        Text(
                                          'Tanggal: $date',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                // Tombol hapus
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.deepPurple),
                                      onPressed: () async {
                                        final editedResult = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => AddExpenseScreen(initialData: item),
                                          ),
                                        );

                                       if (editedResult != null && editedResult is Map<String, dynamic>) {
                                          final id = editedResult['id'];
                                          final originalIndex = expenseList.indexWhere((e) => e['id'] == id);

                                          if (originalIndex != -1) {
                                            setState(() {
                                              expenseList[originalIndex] = editedResult;
                                              totalIncome = expenseList.fold(0, (sum, item) => sum + (item['amount'] ?? 0));
                                            });
                                            saveExpenseData();
                                          }
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text("Hapus Pengeluaran"),
                                            content: const Text("Yakin ingin menghapus pengeluaran ini?"),
                                            actions: [
                                              TextButton(
                                                  onPressed: () => Navigator.pop(ctx, false),
                                                  child: const Text("Batal")),
                                              TextButton(
                                                  onPressed: () => Navigator.pop(ctx, true),
                                                  child: const Text("Hapus")),
                                            ],
                                          ),
                                        );

                                        if (confirm == true) {
                                          setState(() {
                                            totalExpense -= (expenseList[index]['amount'] ?? 0).toInt();
                                            expenseList.removeAt(index);
                                          });
                                          saveIncomeData();
                                        }
                                      },
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          // Tombol Tambah
          Padding(
            padding: const EdgeInsets.only(right: 20, bottom: 20),
            child: Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => selectedTab == 0
                          ? const AddIncomeScreen()
                          : const AddExpenseScreen(),
                    ),
                  );

                  if (result != null && result is Map<String, dynamic>) {
                    setState(() {
                      if (selectedTab == 0) {
                        incomeList.add(result);
                        totalIncome += (result['amount'] ?? 0).toInt();
                        saveIncomeData();
                      } else {
                        expenseList.add(result);
                        totalExpense += (result['amount'] ?? 0).toInt();
                        saveExpenseData();
                      }
                    });
                  }
                },


                icon: const Icon(Icons.add),
                label: Text(
                  selectedTab == 0
                      ? 'Tambah Pemasukan'
                      : 'Tambah Pengeluaran',
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shadowColor: Colors.black26,
                  iconColor: Colors.white,
                  elevation: 6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
