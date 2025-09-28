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
      ColumnDef('Own Land Size (Bigha)', 'landSize', TextAlign.center),
      ColumnDef('rentedLandSize (Bigha)', 'rentedLandSize', TextAlign.center),
      ColumnDef('Field Name', 'fieldName', TextAlign.left),
      ColumnDef('District', 'district', TextAlign.left),
      ColumnDef('Survey Numbers', 'surveyNumbers', TextAlign.left),
      
      // Crop details
      ColumnDef('Crop', 'crop', TextAlign.left),
      ColumnDef('Crop Type', 'cropType', TextAlign.left),
      ColumnDef('Season', 'season', TextAlign.left),
      ColumnDef('Crop Cultivation Area', 'Crop cultivation area', TextAlign.left),
      
      // Land preparation
      ColumnDef('Land Preparation Before Planting', 'landPrepBefore', TextAlign.center),
      ColumnDef('Land Preparation Cost', 'landPreparationCost', TextAlign.center),
      
      // Seeds and planting
      ColumnDef('Seed Cost', 'seedCost', TextAlign.center),
      ColumnDef('Transplant Cost', 'transplantCost', TextAlign.center),
      
      // Fertilizers
      ColumnDef('DAP Quantity', 'dapQuantity', TextAlign.center),
      ColumnDef('DAP Cost', 'dapCost', TextAlign.center),
      ColumnDef('Urea Quantity', 'ureaQuantity', TextAlign.center),
      ColumnDef('Urea Cost', 'ureaCost', TextAlign.center),
      ColumnDef('SSP Quantity', 'sspQuantity', TextAlign.center),
      ColumnDef('SSP Cost', 'sspCost', TextAlign.center),
      ColumnDef('NPK Quantity', 'npkQuantity', TextAlign.center),
      ColumnDef('NPK Cost', 'npkCost', TextAlign.center),
      ColumnDef('Bio Fertilizer Quantity', 'bioFertilizerQuantity', TextAlign.center),
      ColumnDef('Bio Fertilizer Cost', 'bioFertilizerCost', TextAlign.center),
      
      // Weed and pest control
      ColumnDef('Weedicides Cost', 'weedicidesCost', TextAlign.center),
      ColumnDef('Diseases', 'diseases', TextAlign.left),
      ColumnDef('Pests', 'pests', TextAlign.left),
      ColumnDef('Disease Control Cost', 'diseaseControlCost', TextAlign.center),
      ColumnDef('Pesticides Cost', 'pesticidesCost', TextAlign.center),
      
      // Irrigation
      ColumnDef('Irrigation Count', 'irrigationCount', TextAlign.center),
      ColumnDef('Irrigation Cost', 'irrigationCost', TextAlign.center),
      
      // Harvest and labor
      ColumnDef('Harvest Cost', 'harvestCost', TextAlign.center),
      ColumnDef('Labor Cost', 'laborCost', TextAlign.center),
      ColumnDef('Other Cost', 'otherCost', TextAlign.center),
      
      // Production and income
      ColumnDef('Total Production', 'totalProduction', TextAlign.center),
      ColumnDef('Selling Price', 'sellingPrice', TextAlign.center),
      ColumnDef('Total Income', 'totalIncome', TextAlign.center),
      ColumnDef('Total Expense', 'totalExpense', TextAlign.center),
      ColumnDef('Net Income', 'netIncome', TextAlign.center),
      
      // Other products
      ColumnDef('Other Products', 'otherProducts', TextAlign.center),
      ColumnDef('Other Products Value', 'otherProductsValue', TextAlign.center),
      
      // Additional fields from fieldKeys
      // ColumnDef('Monsoon Other', 'monsoonOther', TextAlign.left),
      // ColumnDef('Winter Other', 'winterOther', TextAlign.left),
      // ColumnDef('Summer Other', 'summerOther', TextAlign.left),
      ColumnDef('Diseases Other', 'diseasesOther', TextAlign.left),
      ColumnDef('Pests Other', 'pestsOther', TextAlign.left),
      ColumnDef('Edible Other', 'edibleOther', TextAlign.left),
      ColumnDef('Vegetable Other', 'vegetableOther', TextAlign.left),
      ColumnDef('Horticulture Other', 'horticultureOther', TextAlign.left),
      
      // Timestamps
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
        
        // Create an entry for EACH expense record with this ration card
        for (var cropData in cropMap[rationCard]!) {
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
          'rentedLandSize': farmerData['rentedLandSize']?.toString() ?? '',
          'fieldName': farmerData['fieldName'] ?? '',
          'district': farmerData['district'] ?? '',
          'surveyNumbers': surveyNumbers,
          'farmerTimestamp': _formatTimestamp(farmerData['timestamp']),

          // Crop details
          'crop': cropData['crop'] ?? '',
          'cropType': cropData['crop_type'] ?? '',
          'season': cropData['season'] ?? '',
          'Crop cultivation area': cropData['Crop cultivation area'] ?? '',
          
          // Land preparation
          'landPrepBefore': cropData['land_preparation_before_planting'] ?? '',
          'landPreparationCost': cropData['land_preparation_cost']?.toString() ?? '',
          
          // Seeds and planting
          'seedCost': cropData['seed_cost']?.toString() ?? '',
          'transplantCost': cropData['transplant_cost']?.toString() ?? '',
          
          // Fertilizers
          'dapQuantity': cropData['dap_quantity']?.toString() ?? '',
          'dapCost': cropData['dap_cost']?.toString() ?? '',
          'ureaQuantity': cropData['urea_quantity']?.toString() ?? '',
          'ureaCost': cropData['urea_cost']?.toString() ?? '',
          'sspQuantity': cropData['ssp_quantity']?.toString() ?? '',
          'sspCost': cropData['ssp_cost']?.toString() ?? '',
          'npkQuantity': cropData['npk_quantity']?.toString() ?? '',
          'npkCost': cropData['npk_cost']?.toString() ?? '',
          'bioFertilizerQuantity': cropData['bio_fertilizer_quantity']?.toString() ?? '',
          'bioFertilizerCost': cropData['bio_fertilizer_cost']?.toString() ?? '',
          
          // Weed and pest control
          'weedicidesCost': cropData['weedicides_cost']?.toString() ?? '',
          'diseases': diseases,
          'pests': pests,
          'diseaseControlCost': cropData['disease_control_cost']?.toString() ?? '',
          'pesticidesCost': cropData['pesticides_cost']?.toString() ?? '',
          
          // Irrigation
          'irrigationCount': cropData['irrigation_count']?.toString() ?? '',
          'irrigationCost': cropData['irrigation_cost']?.toString() ?? '',
          
          // Harvest and labor
          'harvestCost': cropData['harvest_cost']?.toString() ?? '',
          'laborCost': cropData['labor_cost']?.toString() ?? '',
          'otherCost': cropData['other_cost']?.toString() ?? '',
          
          // Production and income
          'totalProduction': cropData['total_production']?.toString() ?? '',
          'sellingPrice': cropData['selling_price']?.toString() ?? '',
          'totalIncome': totalIncome.toStringAsFixed(2),
          'totalExpense': totalExpense.toStringAsFixed(2),
          'netIncome': netIncome.toStringAsFixed(2),
          
          // Other products
          'otherProducts': cropData['other_products']?.toString() ?? '',
          'otherProductsValue': cropData['other_products_value']?.toString() ?? '',
          
          // Additional fields from fieldKeys
          // 'monsoonOther': cropData['monsoon_other'] ?? '',
          // 'winterOther': cropData['winter_other'] ?? '',
          // 'summerOther': cropData['summer_other'] ?? '',
          'diseasesOther': cropData['diseases_other'] ?? '',
          'pestsOther': cropData['pests_other'] ?? '',
          'edibleOther': cropData['edible_other'] ?? '',
          'vegetableOther': cropData['vegetable_other'] ?? '',
          'horticultureOther': cropData['horticulture_other'] ?? '',
          
          'expenseTimestamp': _formatTimestamp(cropData['timestamp']),
        });
        }
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

  // New function to fetch ALL data for Excel export
  Future<List<Map<String, dynamic>>> _fetchAllDataForExcel() async {
    List<Map<String, dynamic>> allData = [];
    
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Preparing data for export...'),
              ],
            ),
          );
        },
      );

      // Fetch all farmer details
      final farmerSnapshot = await FirebaseFirestore.instance
          .collection('farmer_details')
          .get();

      // Create a map of ration card to farmer data
      Map<String, Map<String, dynamic>> farmerMap = {};
      for (var doc in farmerSnapshot.docs) {
        final farmerData = doc.data() as Map<String, dynamic>;
        final rationCard = farmerData['rationCard']?.toString() ?? '';
        if (rationCard.isNotEmpty) {
          farmerMap[rationCard] = farmerData;
        }
      }

      // Fetch all expense records
      final cropSnapshot = await FirebaseFirestore.instance
          .collection('farm_expenses')
          .get();

      // Process each expense record
      for (var cropDoc in cropSnapshot.docs) {
        final cropData = cropDoc.data() as Map<String, dynamic>;
        final rationCard = cropData['ration_card_no']?.toString() ?? '';
        
        if (rationCard.isNotEmpty && farmerMap.containsKey(rationCard)) {
          final farmerData = farmerMap[rationCard]!;
          
          // Calculate net income
          final totalIncome = (cropData['total_income'] as num?)?.toDouble() ?? 0;
          final totalExpense = (cropData['total_expense'] as num?)?.toDouble() ?? 0;
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

          allData.add({
            'rationCardNo': rationCard,
            'farmerName': farmerData['farmerName'] ?? '',
            'village': farmerData['village'] ?? '',
            'block': farmerData['block'] ?? '',
            'mobile': farmerData['mobile'] ?? '',
            'landSize': farmerData['landSize']?.toString() ?? '',
            'rentedLandSize': farmerData['rentedLandSize']?.toString() ?? '',
            'fieldName': farmerData['fieldName'] ?? '',
            'district': farmerData['district'] ?? '',
            'surveyNumbers': surveyNumbers,
            'farmerTimestamp': _formatTimestamp(farmerData['timestamp']),

            // Crop details
            'crop': cropData['crop'] ?? '',
            'cropType': cropData['crop_type'] ?? '',
            'season': cropData['season'] ?? '',
            'Crop cultivation area': cropData['Crop cultivation area'] ?? '',
            
            // Land preparation
            'landPrepBefore': cropData['land_preparation_before_planting'] ?? '',
            'landPreparationCost': cropData['land_preparation_cost']?.toString() ?? '',
            
            // Seeds and planting
            'seedCost': cropData['seed_cost']?.toString() ?? '',
            'transplantCost': cropData['transplant_cost']?.toString() ?? '',
            
            // Fertilizers
            'dapQuantity': cropData['dap_quantity']?.toString() ?? '',
            'dapCost': cropData['dap_cost']?.toString() ?? '',
            'ureaQuantity': cropData['urea_quantity']?.toString() ?? '',
            'ureaCost': cropData['urea_cost']?.toString() ?? '',
            'sspQuantity': cropData['ssp_quantity']?.toString() ?? '',
            'sspCost': cropData['ssp_cost']?.toString() ?? '',
            'npkQuantity': cropData['npk_quantity']?.toString() ?? '',
            'npkCost': cropData['npk_cost']?.toString() ?? '',
            'bioFertilizerQuantity': cropData['bio_fertilizer_quantity']?.toString() ?? '',
            'bioFertilizerCost': cropData['bio_fertilizer_cost']?.toString() ?? '',
            
            // Weed and pest control
            'weedicidesCost': cropData['weedicides_cost']?.toString() ?? '',
            'diseases': diseases,
            'pests': pests,
            'diseaseControlCost': cropData['disease_control_cost']?.toString() ?? '',
            'pesticidesCost': cropData['pesticides_cost']?.toString() ?? '',
            
            // Irrigation
            'irrigationCount': cropData['irrigation_count']?.toString() ?? '',
            'irrigationCost': cropData['irrigation_cost']?.toString() ?? '',
            
            // Harvest and labor
            'harvestCost': cropData['harvest_cost']?.toString() ?? '',
            'laborCost': cropData['labor_cost']?.toString() ?? '',
            'otherCost': cropData['other_cost']?.toString() ?? '',
            
            // Production and income
            'totalProduction': cropData['total_production']?.toString() ?? '',
            'sellingPrice': cropData['selling_price']?.toString() ?? '',
            'totalIncome': totalIncome.toStringAsFixed(2),
            'totalExpense': totalExpense.toStringAsFixed(2),
            'netIncome': netIncome.toStringAsFixed(2),
            
            // Other products
            'otherProducts': cropData['other_products']?.toString() ?? '',
            'otherProductsValue': cropData['other_products_value']?.toString() ?? '',
            
            // Additional fields from fieldKeys
            // 'monsoonOther': cropData['monsoon_other'] ?? '',
            // 'winterOther': cropData['winter_other'] ?? '',
            // 'summerOther': cropData['summer_other'] ?? '',
            'diseasesOther': cropData['diseases_other'] ?? '',
            'pestsOther': cropData['pests_other'] ?? '',
            'edibleOther': cropData['edible_other'] ?? '',
            'vegetableOther': cropData['vegetable_other'] ?? '',
            'horticultureOther': cropData['horticulture_other'] ?? '',
            
            'expenseTimestamp': _formatTimestamp(cropData['timestamp']),
          });
        }
      }

      // Close the loading dialog
      Navigator.of(context).pop();
      return allData;
    } catch (e) {
      // Close the loading dialog on error
      Navigator.of(context).pop();
      print("Error fetching all data for Excel: $e");
      throw e;
    }
  }

Future<void> _exportToExcel(BuildContext context) async {
    try {
      // Fetch ALL data for Excel export
      final allData = await _fetchAllDataForExcel();
      
      final excel = Excel.createExcel();
      final sheet = excel['Farmer Data'];

      // Add headers
      sheet.appendRow(_columnDefs.map((col) => col.header).toList());

      // Add data rows
      for (var data in allData) {
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
      )
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