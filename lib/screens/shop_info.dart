import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:open_filex/open_filex.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';

class MergedFarmerDataScreen extends StatefulWidget {
  @override
  _MergedFarmerDataScreenState createState() => _MergedFarmerDataScreenState();
}

class _MergedFarmerDataScreenState extends State<MergedFarmerDataScreen> {
  List<Map<String, dynamic>> _mergedData = [];
  List<Map<String, dynamic>> _filteredData = [];
  bool _isLoading = true;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  final int _pageSize = 10;
  final ScrollController _scrollController = ScrollController();
  final List<ColumnDef> _columnDefs = [];

  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  // List of mandatory fields that must be present in both documents
  final List<String> _mandatoryFarmerFields = [
    'rationCard',
    'farmerName',
  ];

  final List<String> _mandatoryExpenseFields = [
    'crop',
    'crop_type',
    'season',
  ];

  @override
  void initState() {
    super.initState();
    _initializeColumnDefs();
    _fetchFirstPage();
    _scrollController.addListener(_scrollListener);

    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(Duration(milliseconds: 300), () {
        setState(() {
          _searchQuery = _searchController.text.toLowerCase();
          _filterData();
        });
      });
    });
  }

  void _filterData() {
    if (_searchQuery.isEmpty) {
      _filteredData = List.from(_mergedData);
    } else {
      _filteredData = _mergedData.where((entry) {
        return entry.values.any((value) =>
            value.toString().toLowerCase().contains(_searchQuery));
      }).toList();
    }
  }

  void _initializeColumnDefs() {
    _columnDefs.addAll([
      ColumnDef('Ration Card No', 'rationCardNo', TextAlign.center),
      ColumnDef('Farmer Name', 'farmerName', TextAlign.left),
      ColumnDef('Village', 'village', TextAlign.left),
      ColumnDef('Block', 'block', TextAlign.left),
      ColumnDef('Mobile', 'mobile', TextAlign.center),
      ColumnDef('Land Size (Bigha)', 'landSize', TextAlign.center),
      ColumnDef('Field Name', 'fieldName', TextAlign.left),
      ColumnDef('District', 'district', TextAlign.left),
      ColumnDef('Survey Numbers', 'surveyNumbers', TextAlign.left),
      ColumnDef('Crop', 'crop', TextAlign.left),
      ColumnDef('Crop Type', 'cropType', TextAlign.left),
      ColumnDef('Season', 'season', TextAlign.left),
      ColumnDef('Cultivation Area', 'cultivationArea', TextAlign.center),
      ColumnDef('Total Production', 'totalProduction', TextAlign.center),
      ColumnDef('Selling Price', 'sellingPrice', TextAlign.center),
      ColumnDef('Total Income', 'totalIncome', TextAlign.center),
      ColumnDef('Total Expense', 'totalExpense', TextAlign.center),
      ColumnDef('Net Income', 'netIncome', TextAlign.center),
      ColumnDef('Seed Cost', 'seedCost', TextAlign.center),
      ColumnDef('Compost Cost', 'compostCost', TextAlign.center),
      ColumnDef('Compost Quantity', 'compostQuantity', TextAlign.center),
      ColumnDef('DAP Cost', 'dapCost', TextAlign.center),
      ColumnDef('DAP Quantity', 'dapQuantity', TextAlign.center),
      ColumnDef('Urea Cost', 'ureaCost', TextAlign.center),
      ColumnDef('Urea Quantity', 'ureaQuantity', TextAlign.center),
      ColumnDef('SSP Cost', 'sspCost', TextAlign.center),
      ColumnDef('SSP Quantity', 'sspQuantity', TextAlign.center),
      ColumnDef('NPK Cost', 'npkCost', TextAlign.center),
      ColumnDef('NPK Quantity', 'npkQuantity', TextAlign.center),
      ColumnDef('Bio Fertilizer Cost', 'bioFertilizerCost', TextAlign.center),
      ColumnDef('Bio Fertilizer Quantity', 'bioFertilizerQuantity', TextAlign.center),
      ColumnDef('Pesticides Cost', 'pesticidesCost', TextAlign.center),
      ColumnDef('Labor Cost', 'laborCost', TextAlign.center),
      ColumnDef('Land Preparation Cost', 'landPreparationCost', TextAlign.center),
      ColumnDef('Irrigation Cost', 'irrigationCost', TextAlign.center),
      ColumnDef('Irrigation Count', 'irrigationCount', TextAlign.center),
      ColumnDef('Harvest Cost', 'harvestCost', TextAlign.center),
      ColumnDef('Transplant Cost', 'transplantCost', TextAlign.center),
      ColumnDef('Disease Control Cost', 'diseaseControlCost', TextAlign.center),
      ColumnDef('Weedicides Cost', 'weedicidesCost', TextAlign.center),
      ColumnDef('Other Cost', 'otherCost', TextAlign.center),
      ColumnDef('Vegetable Count', 'vegetableCount', TextAlign.center),
      ColumnDef('Other Products', 'otherProducts', TextAlign.center),
      ColumnDef('Other Products Value', 'otherProductsValue', TextAlign.center),
      ColumnDef('Land Prep Before Planting', 'landPrepBefore', TextAlign.center),
      ColumnDef('Used Compost', 'usedCompost', TextAlign.center),
      ColumnDef('Diseases', 'diseases', TextAlign.left),
      ColumnDef('Pests', 'pests', TextAlign.left),
      ColumnDef('Fertilizers Used', 'fertilizersUsed', TextAlign.left),
      ColumnDef('Farmer Timestamp', 'farmerTimestamp', TextAlign.center),
      ColumnDef('Expense Timestamp', 'expenseTimestamp', TextAlign.center),
    ]);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _fetchNextPage();
    }
  }

  Future<void> _fetchFirstPage() async {
    setState(() => _isLoading = true);
    await _fetchMergedData();
    setState(() => _isLoading = false);
  }

  Future<void> _fetchNextPage() async {
    if (!_hasMore || _isLoading) return;
    setState(() => _isLoading = true);
    await _fetchMergedData();
    setState(() => _isLoading = false);
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    if (timestamp is Timestamp) {
      return DateFormat('dd MMM yyyy HH:mm').format(timestamp.toDate());
    }
    return timestamp.toString();
  }

  String _formatArray(dynamic value) {
    if (value == null) return '';
    if (value is List) {
      return value.join(', ');
    }
    return value.toString();
  }
Future<void> _fetchMergedData() async {
  try {
    // Fetch paginated farmer details
    Query farmerQuery = FirebaseFirestore.instance
        .collection('farmer_details')
        .orderBy('timestamp', descending: true)
        .limit(_pageSize);

    if (_lastDocument != null) {
      farmerQuery = farmerQuery.startAfterDocument(_lastDocument!);
    }

    final farmerSnapshot = await farmerQuery.get();
    if (farmerSnapshot.docs.isEmpty) {
      setState(() => _hasMore = false);
      return;
    }

    _lastDocument = farmerSnapshot.docs.last;

    // Extract ration card numbers and farmer names
    List<String> rationCardNos = [];
    Map<String, String> farmerNameMap = {}; // Map ration card to farmer name
    
    for (var doc in farmerSnapshot.docs) {
      final farmerData = doc.data() as Map<String, dynamic>;
      final rationCard = farmerData['rationCard']?.toString() ?? '';
      final farmerName = farmerData['farmerName']?.toString() ?? '';
      
      if (rationCard.isNotEmpty) {
        rationCardNos.add(rationCard);
        farmerNameMap[rationCard] = farmerName;
      }
    }

    // Fetch corresponding crop details
    final cropSnapshot = await FirebaseFirestore.instance
        .collection('farm_expenses')
        .where('ration_card_no', whereIn: rationCardNos)
        .get();

    print("Found ${cropSnapshot.docs.length} expense records for ${rationCardNos.length} ration cards");

    // Create mapping for quick lookup with ration card matching only
    // We'll handle name matching separately with more flexibility
    Map<String, List<Map<String, dynamic>>> cropMap = {};
    for (var doc in cropSnapshot.docs) {
      final cropData = doc.data() as Map<String, dynamic>;
      final rationCard = cropData['ration_card_no']?.toString() ?? '';
      
      if (rationCard.isNotEmpty) {
        if (!cropMap.containsKey(rationCard)) {
          cropMap[rationCard] = [];
        }
        cropMap[rationCard]!.add(cropData);
      }
    }

    // Merge data
    List<Map<String, dynamic>> pageData = [];
    for (var farmerDoc in farmerSnapshot.docs) {
      final farmerData = farmerDoc.data() as Map<String, dynamic>;
      final rationCard = farmerData['rationCard']?.toString() ?? '';
      final farmerName = farmerData['farmerName']?.toString() ?? '';
      
      // Skip if no matching expense document with same ration card
      if (!cropMap.containsKey(rationCard)) {
        print("No expense records for farmer: $farmerName with ration card: $rationCard");
        continue;
      }
      
      // Find the best matching expense record
      Map<String, dynamic>? bestMatch;
      for (var cropData in cropMap[rationCard]!) {
        final expenseFarmerName = cropData['farmer_name']?.toString() ?? '';
        
        // Prioritize exact matches
        if (expenseFarmerName == farmerName) {
          bestMatch = cropData;
          break;
        }
        // If no exact match, use the first one (even if name is empty)
        else if (bestMatch == null) {
          bestMatch = cropData;
        }
      }
      
      if (bestMatch == null) continue;
      final cropData = bestMatch;

      // Validate mandatory fields in farmer details
      bool hasAllFarmerFields = _mandatoryFarmerFields.every(
        (field) => farmerData.containsKey(field) && farmerData[field] != null
      );
      
      // Validate mandatory fields in expense details
      bool hasAllExpenseFields = _mandatoryExpenseFields.every(
        (field) => cropData.containsKey(field) && cropData[field] != null
      );
      
      // Skip if any mandatory fields are missing
      if (!hasAllFarmerFields || !hasAllExpenseFields) {
        print("Missing mandatory fields for farmer: $farmerName");
        if (!hasAllFarmerFields) {
          print("Missing farmer fields: ${_mandatoryFarmerFields.where((field) => !farmerData.containsKey(field) || farmerData[field] == null).toList()}");
        }
        if (!hasAllExpenseFields) {
          print("Missing expense fields: ${_mandatoryExpenseFields.where((field) => !cropData.containsKey(field) || cropData[field] == null).toList()}");
        }
        continue;
      }

      // Calculate net income
      final totalIncome = (cropData['total_income'] as num?)?.toDouble() ?? 0;
      final totalExpense =
          (cropData['total_expense'] as num?)?.toDouble() ?? 0;
      final netIncome = totalIncome - totalExpense;

      // Format survey numbers
      final surveyNumbers = farmerData['surveyNumbers'] is List
          ? (farmerData['surveyNumbers'] as List).join(', ')
          : farmerData['surveyNumbers']?.toString() ?? '';

      // Format diseases and pests
      final diseases = _formatArray(cropData['diseases']);
      final pests = _formatArray(cropData['pests']);
      
      // Format fertilizers used
      final fertilizersUsed = _formatArray(cropData['fertilizers_used']);

      pageData.add({
        'rationCardNo': rationCard,
        'farmerName': farmerName,
        'village': farmerData['village'] ?? '',
        'block': farmerData['block'] ?? '',
        'mobile': farmerData['mobile'] ?? '',
        'landSize': farmerData['landSize']?.toString() ?? '',
        'fieldName': farmerData['fieldName'] ?? '',
        'district': farmerData['district'] ?? '',
        'surveyNumbers': surveyNumbers,
        'farmerTimestamp': _formatTimestamp(farmerData['timestamp']),

        // Crop details
        'crop': cropData['crop'] ?? '',
        'cropType': cropData['crop_type'] ?? '',
        'season': cropData['season'] ?? '',
        'cultivationArea': cropData['cultivation_area']?.toString() ?? '',
        'totalProduction': cropData['total_production']?.toString() ?? '',
        'sellingPrice': cropData['selling_price']?.toString() ?? '',
        'totalIncome': totalIncome.toStringAsFixed(2),
        'totalExpense': totalExpense.toStringAsFixed(2),
        'netIncome': netIncome.toStringAsFixed(2),
        'seedCost': cropData['seed_cost']?.toString() ?? '',
        'compostCost': cropData['compost_cost']?.toString() ?? '',
        'compostQuantity': cropData['compost_quantity']?.toString() ?? '',
        'dapCost': cropData['dap_cost']?.toString() ?? '',
        'dapQuantity': cropData['dap_quantity']?.toString() ?? '',
        'ureaCost': cropData['urea_cost']?.toString() ?? '',
        'ureaQuantity': cropData['urea_quantity']?.toString() ?? '',
        'sspCost': cropData['ssp_cost']?.toString() ?? '',
        'sspQuantity': cropData['ssp_quantity']?.toString() ?? '',
        'npkCost': cropData['npk_cost']?.toString() ?? '',
        'npkQuantity': cropData['npk_quantity']?.toString() ?? '',
        'bioFertilizerCost': cropData['bio_fertilizer_cost']?.toString() ?? '',
        'bioFertilizerQuantity': cropData['bio_fertilizer_quantity']?.toString() ?? '',
        'pesticidesCost': cropData['pesticides_cost']?.toString() ?? '',
        'laborCost': cropData['labor_cost']?.toString() ?? '',
        'landPreparationCost':
            cropData['land_preparation_cost']?.toString() ?? '',
        'irrigationCost': cropData['irrigation_cost']?.toString() ?? '',
        'irrigationCount': cropData['irrigation_count']?.toString() ?? '',
        'harvestCost': cropData['harvest_cost']?.toString() ?? '',
        'transplantCost': cropData['transplant_cost']?.toString() ?? '',
        'diseaseControlCost':
            cropData['disease_control_cost']?.toString() ?? '',
        'weedicidesCost': cropData['weedicides_cost']?.toString() ?? '',
        'otherCost': cropData['other_cost']?.toString() ?? '',
        'vegetableCount': cropData['vegetable_count']?.toString() ?? '',
        'otherProducts': cropData['other_products']?.toString() ?? '',
        'otherProductsValue':
            cropData['other_products_value']?.toString() ?? '',
        'landPrepBefore': cropData['land_preparation_before_planting'] ?? '',
        'usedCompost': cropData['used_compost'] ?? '',
        'diseases': diseases,
        'pests': pests,
        'fertilizersUsed': fertilizersUsed,
        'expenseTimestamp': _formatTimestamp(cropData['timestamp']),
      });
    }

    print("Successfully merged ${pageData.length} records");

    setState(() {
      _mergedData.addAll(pageData);
      _filterData();
    });
  } catch (e) {
    print("Error fetching data: $e");
  }
}

  Future<void> _exportToExcel(BuildContext context) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Farmer Data'];

      sheet.appendRow(_columnDefs.map((col) => col.header).toList());

      for (var data in _mergedData) {
        sheet.appendRow(_columnDefs.map((col) {
          final value = data[col.key] ?? '';
          if (col.key.endsWith('Cost') ||
              col.key.endsWith('Income') ||
              col.key.endsWith('Expense') ||
              col.key.endsWith('Price') ||
              col.key.endsWith('Value')) {
            return double.tryParse(value.toString()) ?? value;
          }
          return value.toString();
        }).toList());
      }

      final encodedBytes = excel.encode();
      final fileName = 'Farmers_Data_${DateTime.now().millisecondsSinceEpoch}.xlsx';

      if (kIsWeb) {
        // Web export implementation would go here
        // Typically involves creating a download link
      } else {
        await _requestStoragePermission();

        final dir = await getApplicationDocumentsDirectory();
        final filePath = p.join(dir.path, fileName);
        final file = File(filePath);
        await file.writeAsBytes(encodedBytes!);
        await Share.shareXFiles([XFile(file.path)], text: 'Farmers Data');
      }
    } catch (e) {
      print("Error exporting to Excel: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: ${e.toString()}')));
    }
  }

  Future<void> _requestStoragePermission() async {
    if (kIsWeb) return;

    final status = await Permission.storage.status;

    if (!status.isGranted) {
      final result = await Permission.storage.request();

      if (!result.isGranted) {
        print("Storage permission denied.");
        if (result.isPermanentlyDenied) {
          openAppSettings();
        }
      }
    }
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search any field...',
          prefixIcon: Icon(Icons.search),
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
          dataRowHeight: 60,
          headingRowColor: MaterialStateProperty.resolveWith(
            (states) => Colors.blueGrey[50],
          ),
          columns: _columnDefs.map((col) {
            return DataColumn(
              label: Container(
                constraints: BoxConstraints(minWidth: 120),
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
          rows: _filteredData.map((data) {
            return DataRow(
              color: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  return _filteredData.indexOf(data) % 2 == 0
                      ? Colors.grey[50]!
                      : Colors.white;
                },
              ),
              cells: _columnDefs.map((col) {
                final value = data[col.key]?.toString() ?? '';
                return DataCell(
                  Container(
                    constraints: BoxConstraints(minWidth: 120),
                    child: Text(
                      value,
                      style: TextStyle(fontSize: 11),
                      textAlign: col.alignment,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No farmers found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Ensure farmers have both details and expenses records with matching names',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchFirstPage,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmers Data'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportToExcel(context),
            tooltip: 'Export to Excel',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchFirstPage,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: isWideScreen ? 32 : 8),
        child: Column(
          children: [
            _buildSearchBar(),
            if (_isLoading && _mergedData.isEmpty)
              Expanded(child: Center(child: CircularProgressIndicator())),
            if (_filteredData.isEmpty && !_isLoading)
              Expanded(child: _buildEmptyState()),
            if (_filteredData.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.vertical,
                  child: _buildDataTable(),
                ),
              ),
            if (_isLoading && _filteredData.isNotEmpty)
              Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            if (!_hasMore && !_isLoading)
              Padding(
                padding: EdgeInsets.all(16.0),
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

class ColumnDef {
  final String header;
  final String key;
  final TextAlign alignment;

  ColumnDef(this.header, this.key, this.alignment);
}