import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';

class AddShopInfoScreen extends StatefulWidget {
  @override
  _AddShopInfoScreenState createState() => _AddShopInfoScreenState();
}

class _AddShopInfoScreenState extends State<AddShopInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _farmerNameController = TextEditingController();
  final TextEditingController _fieldNameController = TextEditingController();
  final TextEditingController _landSizeController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _rationCardController = TextEditingController();

  List<TextEditingController> _surveyNumberControllers = [TextEditingController()];

  String? selectedDistrict;
  String? selectedBlock;
  String? selectedVillage;

  final firestore = FirebaseFirestore.instance.collection('farmer_details');

  final List<String> districts = ['Vadodara', 'Panchmahal'];
  final List<String> blocks = ['Padra', 'Waghodiya', 'Halol'];
  final List<String> villages = [
    'Jarod', 'Kamrol', 'Haripura', 'Lilora', 'Asoj', 'Abhrampura', 'Paldi',
    'Panchdevla', 'Panelav', 'Ambatalav', 'Tajpura', 'Shivjipura', 'Vaseti',
    'Dariyapura', 'Ujeti', 'Alansi', 'Kumpaliya', 'Khodiyarpura', 'Parekhpura',
    'Gopipura', 'Noorpura', 'Ghodi', 'Bhikhapura', 'Karkhadi', 'Majatan', 'Chokari'
  ];

  void _addSurveyField() {
    setState(() => _surveyNumberControllers.add(TextEditingController()));
  }

  void _removeSurveyField(int index) {
    setState(() => _surveyNumberControllers.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ખેડૂતની માહિતી', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ખેડૂતની માહિતી ઉમેરો',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal)),
                const SizedBox(height: 16),

                // Farmer Name
                TextFormField(
                  controller: _farmerNameController,
                  decoration: _inputDecoration('ખેડૂતનું નામ'),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Field Name
                TextFormField(
                  controller: _fieldNameController,
                  decoration: _inputDecoration('ફળિયાનું નામ'),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // District
                DropdownButtonFormField<String>(
                  value: selectedDistrict,
                  decoration: _inputDecoration('જિલ્લો'),
                  onChanged: (val) => setState(() => selectedDistrict = val),
                  validator: (value) => value == null ? 'Required' : null,
                  items: districts.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                ),
                const SizedBox(height: 16),

                // Block
                DropdownButtonFormField<String>(
                  value: selectedBlock,
                  decoration: _inputDecoration('તાલુકો'),
                  onChanged: (val) => setState(() => selectedBlock = val),
                  validator: (value) => value == null ? 'Required' : null,
                  items: blocks.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                ),
                const SizedBox(height: 16),

                // Village
                DropdownSearch<String>(
                  items: villages,
                  selectedItem: selectedVillage,
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: _inputDecoration('ગામનું નામ'),
                  ),
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    constraints: const BoxConstraints(maxHeight: 300),
                  ),
                  onChanged: (val) => setState(() => selectedVillage = val),
                  validator: (value) => value == null ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Mobile
                TextFormField(
                  controller: _mobileController,
                  decoration: _inputDecoration('મોબાઈલ નંબર'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (!RegExp(r'^\d{10}$').hasMatch(value)) return 'Enter valid 10-digit number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Land Size
                TextFormField(
                  controller: _landSizeController,
                  decoration: _inputDecoration('કુટુંબની કુલ જમીન (વીઘા)'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Survey Numbers
                Column(
                  children: List.generate(_surveyNumberControllers.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _surveyNumberControllers[index],
                              decoration: _inputDecoration('ખેતર (સર્વે) નંબર: ${index + 1}'),
                              validator: (value) =>
                                  value == null || value.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_surveyNumberControllers.length > 1)
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () => _removeSurveyField(index),
                            ),
                        ],
                      ),
                    );
                  }),
                ),

                TextButton.icon(
                  onPressed: _addSurveyField,
                  icon: const Icon(Icons.add, color: Colors.teal),
                  label: const Text('અધિક સર્વે નં ઉમેરો', style: TextStyle(color: Colors.teal)),
                ),
                const SizedBox(height: 16),

                // Ration Card
                TextFormField(
                  controller: _rationCardController,
                  decoration: _inputDecoration('રેશન કાર્ડ નંબર'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (value.length < 12 || value.length > 18) {
                      return '12 થી 18 અક્ષરો હોવા જોઈએ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Submit
                Center(
                  child: OutlinedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final id = DateTime.now().millisecondsSinceEpoch.toString();

                        final surveyNumbers = _surveyNumberControllers
                            .map((c) => c.text.trim())
                            .where((text) => text.isNotEmpty)
                            .toList();

                        firestore.doc(id).set({
                          'farmerName': _farmerNameController.text.trim(),
                          'fieldName': _fieldNameController.text.trim(),
                          'mobile': _mobileController.text.trim(),
                          'landSize': _landSizeController.text.trim(),
                          'rationCard': _rationCardController.text.trim(),
                          'district': selectedDistrict,
                          'block': selectedBlock,
                          'village': selectedVillage,
                          'surveyNumbers': surveyNumbers,
                          'timestamp': FieldValue.serverTimestamp(),
                        }).then((_) {
                          _formKey.currentState?.reset();
                          _surveyNumberControllers = [TextEditingController()];
                          setState(() {
                            selectedBlock = null;
                            selectedDistrict = null;
                            selectedVillage = null;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('માહિતી સફળતાપૂર્વક સેવ થઈ ગઈ')),
                          );
                        });
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    ),
                    child: const Text('Save', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
    );
  }
}
