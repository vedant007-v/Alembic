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

class AnimalHusbandryDataScreen extends StatefulWidget {
  @override
  _AnimalHusbandryDataScreenState createState() => _AnimalHusbandryDataScreenState();
}

class _AnimalHusbandryDataScreenState extends State<AnimalHusbandryDataScreen> {
  List<Map<String, dynamic>> _animalData = [];
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
      _filteredData = List.from(_animalData);
    } else {
      _filteredData = _animalData.where((entry) {
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
      ColumnDef('District', 'district', TextAlign.left),
      
      // Animal Husbandry Specific Fields
      ColumnDef('Milk Production Before (Daily)', 'milkProductionBefore', TextAlign.center),
      ColumnDef('Benefited from AI', 'benefitedFromAI', TextAlign.center),
      ColumnDef('Other Animals', 'otherAnimals', TextAlign.center),
      ColumnDef('Cows Count', 'cowsCount', TextAlign.center),
      ColumnDef('Heifer Count', 'heiferCount', TextAlign.center),
      ColumnDef('Bull Calf Count', 'bullCalfCount', TextAlign.center),
      ColumnDef('Sheep Count', 'sheepCount', TextAlign.center),
      ColumnDef('Used Deworming Tablet', 'usedDewormingTablet', TextAlign.center),
      ColumnDef('Milk Production After (Daily)', 'milkProductionAfter', TextAlign.center),
      ColumnDef('Goats Count', 'goatsCount', TextAlign.center),
      ColumnDef('Buffaloes Count', 'buffaloesCount', TextAlign.center),
      ColumnDef('Buffalo Heifer Count', 'buffaloHeiferCount', TextAlign.center),
      ColumnDef('Buffalo Bull Calf Count', 'buffaloBullCalfCount', TextAlign.center),
      ColumnDef('Used Mineral Mixture', 'usedMineralMixture', TextAlign.center),
      ColumnDef('Abortions Occurred', 'abortionsOccurred', TextAlign.left),
      ColumnDef('Insemination Happened', 'inseminationHappened', TextAlign.center),
      ColumnDef('Animal Timestamp', 'animalTimestamp', TextAlign.center),
      ColumnDef('Farmer Timestamp', 'farmerTimestamp', TextAlign.center),
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
    await _fetchAnimalData();
    setState(() => _isLoading = false);
  }

  Future<void> _fetchNextPage() async {
    if (!_hasMore || _isLoading) return;
    setState(() => _isLoading = true);
    await _fetchAnimalData();
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

  Future<void> _fetchAnimalData() async {
    try {
      // First fetch farmer details
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

      // Extract ration card numbers
      List<String> rationCardNos = [];
      for (var doc in farmerSnapshot.docs) {
        final farmerData = doc.data() as Map<String, dynamic>;
        final rationCard = farmerData['rationCard']?.toString() ?? '';
        if (rationCard.isNotEmpty) {
          rationCardNos.add(rationCard);
        }
      }

      // Fetch corresponding animal husbandry data
      final animalSnapshot = await FirebaseFirestore.instance
          .collection('animal_husbandry')
          .where('rationCardNo', whereIn: rationCardNos)
          .get();

      // Create mapping for quick lookup
      Map<String, Map<String, dynamic>> farmerMap = {};
      for (var doc in farmerSnapshot.docs) {
        final farmerData = doc.data() as Map<String, dynamic>;
        final rationCard = farmerData['rationCard']?.toString() ?? '';
        if (rationCard.isNotEmpty) {
          farmerMap[rationCard] = farmerData;
        }
      }

      // Merge data - create a row for each animal entry
      List<Map<String, dynamic>> pageData = [];
      for (var animalDoc in animalSnapshot.docs) {
        final animalData = animalDoc.data() as Map<String, dynamic>;
        final rationCard = animalData['rationCardNo']?.toString() ?? '';
        
        // Skip if no matching farmer document
        if (!farmerMap.containsKey(rationCard)) {
          continue;
        }
        
        final farmerData = farmerMap[rationCard]!;

        // Get milk production values
        final milkProductionAfterStr = animalData['પ્રોજેક્ટ પછી દૂધ ઉત્પાદન (દરરોજ)']?.toString() ?? '0';
        final milkProductionBeforeStr = animalData['પહેલાં દૂધ ઉત્પાદન (દરરોજ)']?.toString() ?? '0';
        
        // Convert to numbers for comparison
        final milkProductionAfter = double.tryParse(milkProductionAfterStr) ?? 0;
        final milkProductionBefore = double.tryParse(milkProductionBeforeStr) ?? 0;
        
        // Only include records where milk production after > milk production before
        if (milkProductionAfter <= milkProductionBefore) {
          continue;
        }

        pageData.add({
          'rationCardNo': rationCard,
          'farmerName': farmerData['farmerName'] ?? '',
          'village': farmerData['village'] ?? '',
          'block': farmerData['block'] ?? '',
          'mobile': farmerData['mobile'] ?? '',
          'district': farmerData['district'] ?? '',
          
          // Animal husbandry data mapping
          'milkProductionBefore': milkProductionBeforeStr,
          'benefitedFromAI': animalData['AI લાભ મળ્યો છે?'] ?? '',
          'otherAnimals': animalData['અન્ય'] ?? '',
          'cowsCount': animalData['ગાય (સંખ્યા)'] ?? '',
          'heiferCount': animalData['ગાયની વાછડી'] ?? '',
          'bullCalfCount': animalData['ગાયનો વાછડો'] ?? '',
          'sheepCount': animalData['ઘેટાં'] ?? '',
          'usedDewormingTablet': animalData['ડિવોર્મિંગ ટેબલેટ વાપર્યું છે?'] ?? '',
          'milkProductionAfter': milkProductionAfterStr,
          'goatsCount': animalData['બકરી'] ?? '',
          'buffaloesCount': animalData['ભેંસ'] ?? '',
          'buffaloHeiferCount': animalData['ભેંસની પાડી'] ?? '',
          'buffaloBullCalfCount': animalData['ભેંસનો પાડો'] ?? '',
          'usedMineralMixture': animalData['મિનરલ મિશ્રણ વાપર્યું છે?'] ?? '',
          'abortionsOccurred': _formatArray(animalData['વિયહાન થયું છે']),
          'inseminationHappened': animalData['વ્યાસન થયું છે?'] ?? '',
          'animalTimestamp': _formatTimestamp(animalData['timestamp']),
          'farmerTimestamp': _formatTimestamp(farmerData['timestamp']),
        });
      }

      setState(() {
        _animalData.addAll(pageData);
        _filterData();
      });
    } catch (e) {
      print("Error fetching animal husbandry data: $e");
      // Add debug information
      print("Current animalData length: ${_animalData.length}");
      print("Current filteredData length: ${_filteredData.length}");
    }
  }

  Future<void> _exportToExcel(BuildContext context) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Animal Husbandry Data'];

      sheet.appendRow(_columnDefs.map((col) => col.header).toList());

      for (var data in _animalData) {
        sheet.appendRow(_columnDefs.map((col) {
          final value = data[col.key] ?? '';
          return value.toString();
        }).toList());
      }

      final encodedBytes = excel.encode();
      final fileName = 'Animal_Husbandry_Data_${DateTime.now().millisecondsSinceEpoch}.xlsx';

      if (kIsWeb) {
        // Web export implementation would go here
      } else {
        await _requestStoragePermission();

        final dir = await getApplicationDocumentsDirectory();
        final filePath = p.join(dir.path, fileName);
        final file = File(filePath);
        await file.writeAsBytes(encodedBytes!);
        await Share.shareXFiles([XFile(file.path)], text: 'Animal Husbandry Data');
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
    if (_filteredData.isEmpty) {
      return Center(
        child: Text('No data available'),
      );
    }
    
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
            'No animal husbandry data found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Ensure animal husbandry data exists in the database and matches with farmer details',
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
        title: const Text('Animal Husbandry Data'),
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
            if (_isLoading && _animalData.isEmpty)
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