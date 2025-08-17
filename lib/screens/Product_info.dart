import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
//import 'dart:html' as html;
import 'dart:async';
import 'package:apmc/screens/sales_info.dart'; // for ColumnDef

class PositiveNetIncomeScreen extends StatefulWidget {
  @override
  _PositiveNetIncomeScreenState createState() =>
      _PositiveNetIncomeScreenState();
}

class _PositiveNetIncomeScreenState extends State<PositiveNetIncomeScreen> {
  final int _limit = 20;
  List<Map<String, dynamic>> _data = [];
  List<Map<String, dynamic>> _filteredData = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  final List<ColumnDef> _columnDefs = [
    ColumnDef('Ration Card', 'rationCardNo', TextAlign.center),
    ColumnDef('Farmer Name', 'farmerName', TextAlign.center),
    ColumnDef('Village', 'village', TextAlign.center),
    ColumnDef('Block', 'block', TextAlign.center),
    ColumnDef('Mobile', 'mobile', TextAlign.center),
    ColumnDef('Land Size', 'landSize', TextAlign.center),
    ColumnDef('Field Name', 'fieldName', TextAlign.center),
    ColumnDef('District', 'district', TextAlign.center),
    ColumnDef('Survey Numbers', 'surveyNumbers', TextAlign.center),
    ColumnDef('Farmer Timestamp', 'farmerTimestamp', TextAlign.center),
    ColumnDef('Total Income', 'totalIncome', TextAlign.center),
    ColumnDef('Total Expense', 'totalExpense', TextAlign.center),
    ColumnDef('Net Income', 'netIncome', TextAlign.center),
    ColumnDef('Timestamp', 'timestamp', TextAlign.center),
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
    _scrollController.addListener(_scrollListener);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        final query = _searchController.text.toLowerCase();
        if (query.isEmpty) {
          _filteredData = List.from(_data);
        } else {
          _filteredData = _data.where((entry) {
            return entry.values
                .any((value) => value.toString().toLowerCase().contains(query));
          }).toList();
        }
      });
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoading &&
        _hasMore) {
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    if (!_hasMore) return;

    setState(() => _isLoading = true);

    Query query = FirebaseFirestore.instance
        .collection('farm_expenses')
        .orderBy('timestamp', descending: true)
        .limit(_limit);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      _lastDocument = snapshot.docs.last;
    } else {
      _hasMore = false;
    }

    final List<Map<String, dynamic>> newData = [];

    for (final doc in snapshot.docs) {
      final d = doc.data() as Map<String, dynamic>;
      final ti = (d['total_income'] as num?)?.toDouble() ?? 0.0;
      final te = (d['total_expense'] as num?)?.toDouble() ?? 0.0;
      final net = ti - te;

      if (net > 0) {
        final rationCard = d['ration_card_no'] ?? '';

        // Fetch farmer details
        final farmerSnapshot = await FirebaseFirestore.instance
            .collection('farmer_details')
            .where('rationCard', isEqualTo: rationCard)
            .limit(1)
            .get();

        final farmerData = farmerSnapshot.docs.isNotEmpty
            ? farmerSnapshot.docs.first.data()
            : {};

        newData.add({
          'expenseId': doc.id,
          'rationCardNo': rationCard,
          'totalIncome': ti,
          'totalExpense': te,
          'netIncome': net,
          'timestamp': _formatTimestamp(d['timestamp']),
          'farmerName': farmerData['farmerName'] ?? '',
          'village': farmerData['village'] ?? '',
          'block': farmerData['block'] ?? '',
          'mobile': farmerData['mobile'] ?? '',
          'landSize': farmerData['landSize']?.toString() ?? '',
          'fieldName': farmerData['fieldName'] ?? '',
          'district': farmerData['district'] ?? '',
          'surveyNumbers': (farmerData['surveyNumbers'] is List)
              ? (farmerData['surveyNumbers'] as List).join(', ')
              : farmerData['surveyNumbers']?.toString() ?? '',
          'farmerTimestamp': _formatTimestamp(farmerData['timestamp']),
        });
      }
    }

    setState(() {
      _data.addAll(newData);
      _filteredData = List.from(_data);
      _isLoading = false;
    });
  }

  String _formatTimestamp(dynamic t) {
    if (t is Timestamp) {
      return DateFormat('dd MMM yyyy HH:mm').format(t.toDate());
    }
    return t?.toString() ?? '';
  }

  void _showExpenseDetails(Map<String, dynamic> expense) {
    // You can optionally reuse or expand this if needed
  }

  Widget _buildDataTable() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.grey[300]),
      child: DataTable(
        columnSpacing: 16,
        headingRowHeight: 50,
        dataRowHeight: 56,
        headingRowColor:
            MaterialStateProperty.resolveWith((states) => Colors.blueGrey[50]),
        columns: _columnDefs.map((col) {
          return DataColumn(
            label: Container(
              constraints: BoxConstraints(minWidth: 100),
              child: Text(
                col.header,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.blueGrey[800],
                ),
                textAlign: col.alignment,
              ),
            ),
          );
        }).toList(),
        rows: _filteredData.map((row) {
          return DataRow(
            onSelectChanged: (_) => _showExpenseDetails(row),
            color: MaterialStateProperty.resolveWith<Color>((states) {
              return _filteredData.indexOf(row) % 2 == 0
                  ? Colors.grey[50]!
                  : Colors.white;
            }),
            cells: _columnDefs.map((col) {
              final value = row[col.key];
              return DataCell(
                Text(
                  (value is double)
                      ? value.toStringAsFixed(2)
                      : value?.toString() ?? '',
                  style: col.key == 'netIncome'
                      ? TextStyle(
                          color: (row['netIncome'] ?? 0) >= 0
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold)
                      : null,
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search any field...',
          prefixIcon: Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Positive Net Income'),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () => ExportUtils.exportToExcel(
              context: context,
              data: _data,
              columnDefs: _columnDefs,
              fileNamePrefix: 'Positive_Net_Income',
            ),
            tooltip: 'Export to Excel',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _data.isEmpty && _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredData.isEmpty
                    ? Center(child: Text('No records found'))
                    : SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: _buildDataTable(),
                        ),
                      ),
          ),
          if (_isLoading && _data.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          if (!_hasMore && !_isLoading)
            Padding(
              padding: EdgeInsets.all(16),
              child: Text('No more data available'),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
