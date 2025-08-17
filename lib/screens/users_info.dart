import 'package:apmc/screens/sales_info.dart';
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

class FarmerDetailsOnlyScreen extends StatefulWidget {
  @override
  State<FarmerDetailsOnlyScreen> createState() =>
      _FarmerDetailsOnlyScreenState();
}

class _FarmerDetailsOnlyScreenState extends State<FarmerDetailsOnlyScreen> {
  final int _limit = 20;
  List<Map<String, dynamic>> _farmerData = [];
  List<Map<String, dynamic>> _filteredData = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  final List<ColumnDef> _columnDefs = [
    ColumnDef('Ration Card', 'rationCard', TextAlign.center),
    ColumnDef('Farmer Name', 'farmerName', TextAlign.left),
    ColumnDef('Village', 'village', TextAlign.left),
    ColumnDef('Block', 'block', TextAlign.left),
    ColumnDef('Mobile', 'mobile', TextAlign.center),
    ColumnDef('Land Size', 'landSize', TextAlign.center),
    ColumnDef('Field Name', 'fieldName', TextAlign.left),
    ColumnDef('District', 'district', TextAlign.left),
    ColumnDef('Survey Numbers', 'surveyNumbers', TextAlign.left),
    ColumnDef('Timestamp', 'timestamp', TextAlign.center),
  ];

  @override
  void initState() {
    super.initState();
    _fetchFarmerData();
    _scrollController.addListener(_scrollListener);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        final query = _searchController.text.toLowerCase();
        if (query.isEmpty) {
          _filteredData = List.from(_farmerData);
        } else {
          _filteredData = _farmerData.where((entry) {
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
      _fetchFarmerData();
    }
  }

  Future<void> _fetchFarmerData() async {
    if (!_hasMore) return;

    setState(() => _isLoading = true);

    Query query = FirebaseFirestore.instance
        .collection('farmer_details')
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

    final newData = snapshot.docs.map((doc) {
      final docData = doc.data() as Map<String, dynamic>?;
      return {
        'docId': doc.id,
        'rationCard': docData != null ? docData['rationCard'] ?? '' : '',
        'farmerName': docData != null ? docData['farmerName'] ?? '' : '',
        'village': docData != null ? docData['village'] ?? '' : '',
        'block': docData != null ? docData['block'] ?? '' : '',
        'mobile': docData != null ? docData['mobile'] ?? '' : '',
        'landSize':
            docData != null ? docData['landSize']?.toString() ?? '' : '',
        'fieldName': docData != null ? docData['fieldName'] ?? '' : '',
        'district': docData != null ? docData['district'] ?? '' : '',
        'surveyNumbers': docData != null
            ? (docData['surveyNumbers'] is List)
                ? (docData['surveyNumbers'] as List).join(', ')
                : docData['surveyNumbers']?.toString() ?? ''
            : '',
        'timestamp':
            docData != null ? _formatTimestamp(docData['timestamp']) : '',
      };
    }).toList();

    setState(() {
      _farmerData.addAll(newData);
      _filteredData = List.from(_farmerData);
      _isLoading = false;
    });
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    if (timestamp is Timestamp) {
      return DateFormat('dd MMM yyyy HH:mm').format(timestamp.toDate());
    }
    return timestamp.toString();
  }

  void _showFarmerDetails(Map<String, dynamic> farmer) async {
    // Fetch full farmer details
    final doc = await FirebaseFirestore.instance
        .collection('farmer_details')
        .doc(farmer['docId'])
        .get();

    if (!doc.exists) return;

    final data = doc.data() as Map<String, dynamic>;
    final surveyNumbers = (data['surveyNumbers'] is List)
        ? (data['surveyNumbers'] as List).join(', ')
        : data['surveyNumbers']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Farmer Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Ration Card', data['rationCard'] ?? ''),
              _buildDetailRow('Farmer Name', data['farmerName'] ?? ''),
              _buildDetailRow('Village', data['village'] ?? ''),
              _buildDetailRow('Block', data['block'] ?? ''),
              _buildDetailRow('Mobile', data['mobile'] ?? ''),
              _buildDetailRow('Land Size', data['landSize']?.toString() ?? ''),
              _buildDetailRow('Field Name', data['fieldName'] ?? ''),
              _buildDetailRow('District', data['district'] ?? ''),
              _buildDetailRow('Survey Numbers', surveyNumbers),
              _buildDetailRow('Timestamp', _formatTimestamp(data['timestamp'])),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child:
                Text('$label:', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.grey[300],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 12,
          headingRowHeight: 50,
          dataRowHeight: 56,
          headingRowColor: MaterialStateProperty.resolveWith(
              (states) => Colors.blueGrey[50]),
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
              onSelectChanged: (_) => _showFarmerDetails(row),
              color: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  return _filteredData.indexOf(row) % 2 == 0
                      ? Colors.grey[50]!
                      : Colors.white;
                },
              ),
              cells: [
                DataCell(Text(row['rationCard'])),
                DataCell(Text(row['farmerName'])),
                DataCell(Text(row['village'])),
                DataCell(Text(row['block'])),
                DataCell(Text(row['mobile'])),
                DataCell(Text(row['landSize'])),
                DataCell(Text(row['fieldName'])),
                DataCell(Text(row['district'])),
                DataCell(Text(row['surveyNumbers'])),
                DataCell(Text(row['timestamp'])),
              ],
            );
          }).toList(),
        ),
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
    final isWideScreen = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      appBar: AppBar(
        title: Text("Farmer Details Only"),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () => ExportUtils.exportToExcel(
              context: context,
              data: _farmerData,
              columnDefs: _columnDefs,
              fileNamePrefix: 'Farmer_Details',
            ),
            tooltip: 'Export to Excel',
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: isWideScreen ? 24 : 8),
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: _isLoading && _farmerData.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : _filteredData.isEmpty
                      ? Center(child: Text('No farmer details found'))
                      : SingleChildScrollView(
                          controller: _scrollController,
                          scrollDirection: Axis.vertical,
                          child: _buildDataTable(),
                        ),
            ),
            if (_isLoading && _farmerData.isNotEmpty)
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
