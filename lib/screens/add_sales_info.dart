import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddFarmExpenseScreen extends StatefulWidget {
  final String rationCardNo;
  const AddFarmExpenseScreen({super.key, required this.rationCardNo});

  @override
  State<AddFarmExpenseScreen> createState() => _AddFarmExpenseScreenState();
}

class _AddFarmExpenseScreenState extends State<AddFarmExpenseScreen> {
  final firestore = FirebaseFirestore.instance.collection('farm_expenses');

  // English field names mapping
  final Map<String, String> fieldKeys = {
    'પાકનો વાવેતર વિસ્તાર (વીઘા)': 'cultivation_area',
    'શું વાવણી પહેલા જમીન તૈયાર કરી હતી?': 'land_preparation_before_planting',
    'જમીન તૈયારી ખર્ચ': 'land_preparation_cost',
    'બિયારણ/છોડનો ખર્ચ': 'seed_cost',
    'શું તમે ખાતર/છાણ/અન્ય બાયો ખાતર વાપર્યું?': 'used_compost',
    'કુલ ટન (છાણ/બાયો ખાતર)': 'compost_quantity',
    'કુલ છાણ/બાયો ખાતર ખર્ચ': 'compost_cost',
    'પ્રત્યારોપણ ખર્ચ': 'transplant_cost',
    'ડી.એ.પી. (કિલોગ્રામમાં)': 'dap_quantity',
    'ડી.એ.પી. ખર્ચ': 'dap_cost',
    'યૂરિયા (કિલોગ્રામમાં)': 'urea_quantity',
    'યૂરિયા ખર્ચ': 'urea_cost',
    'નીંદણ દવા છાંટવા નો ખર્ચ': 'weedicides_cost',
    'રોગનું નામ': 'diseases',
    'જીવાત/કીડાનું નામ': 'pests',
    'રોગ નિયંત્રણ ખર્ચ': 'disease_control_cost',
    'કુલ પિયત સંખ્યા': 'irrigation_count',
    'કુલ પિયત ખર્ચ': 'irrigation_cost',
    'જંતુનાશક દવા ખર્ચ': 'pesticides_cost',
    'પાકની લણણી ખર્ચ': 'harvest_cost',
    'કુલ મજૂરી ખર્ચ': 'labor_cost',
    'અન્ય કોઈપણ ખર્ચ': 'other_cost',
    'શાકભાજી ની સંખ્યા': 'vegetable_count',
    'કુલ ઉત્પાદન (પ્રતિ મણ)': 'total_production',
    'વેચાણ ભાવ (પ્રતિ મણ)': 'selling_price',
    'ચારો જેવા અન્ય ઉત્પાદન': 'other_products',
    'અન્ય ઉત્પાદનની કુલ કિંમત': 'other_products_value',
  };

  // Calculated fields mapping
  final Map<String, String> calculatedKeys = {
    'કુલ આવક': 'total_income',
    'કુલ ખર્ચ': 'total_expense',
    'નિકાળ આવક': 'net_income',
  };

  final Map<String, String> labelTypes = {
    'પાકનો વાવેતર વિસ્તાર (વીઘા)': 'number',
    'શું વાવણી પહેલા જમીન તૈયાર કરી હતી?': 'dropdown_yesno',
    'જમીન તૈયારી ખર્ચ': 'number',
    'બિયારણ/છોડનો ખર્ચ': 'number',
    'શું તમે ખાતર/છાણ/અન્ય બાયો ખાતર વાપર્યું?': 'dropdown_yesno',
    'કુલ ટન (છાણ/બાયો ખાતર)': 'number',
    'કુલ છાણ/બાયો ખાતર ખર્ચ': 'number',
    'પ્રત્યારોપણ ખર્ચ': 'number',
    'ડી.એ.પી. (કિલોગ્રામમાં)': 'number',
    'ડી.એ.પી. ખર્ચ': 'number',
    'યૂરિયા (કિલોગ્રામમાં)': 'number',
    'યૂરિયા ખર્ચ': 'number',
    'નીંદણ દવા છાંટવા નો ખર્ચ': 'number',
    'રોગનું નામ': 'multiselect',
    'જીવાત/કીડાનું નામ': 'multiselect',
    'રોગ નિયંત્રણ ખર્ચ': 'number',
    'કુલ પિયત સંખ્યા': 'number',
    'કુલ પિયત ખર્ચ': 'number',
    'જંતુનાશક દવા ખર્ચ': 'number',
    'પાકની લણણી ખર્ચ': 'number',
    'કુલ મજૂરી ખર્ચ': 'number',
    'અન્ય કોઈપણ ખર્ચ': 'number',
    'શાકભાજી ની સંખ્યા': 'number',
    'કુલ ઉત્પાદન (પ્રતિ મણ)': 'number',
    'વેચાણ ભાવ (પ્રતિ મણ)': 'number',
    'ચારો જેવા અન્ય ઉત્પાદન': 'text',
    'અન્ય ઉત્પાદનની કુલ કિંમત': 'number',
  };

  final List<String> expenseFields = [
    'જમીન તૈયારી ખર્ચ',
    'બિયારણ/છોડનો ખર્ચ',
    'કુલ છાણ/બાયો ખાતર ખર્ચ',
    'પ્રત્યારોપણ ખર્ચ',
    'ડી.એ.પી. ખર્ચ',
    'યૂરિયા ખર્ચ',
    'નીંદણ દવા છાંટવા નો ખર્ચ',
    'રોગ નિયંત્રણ ખર્ચ',
    'કુલ પિયત ખર્ચ',
    'જંતુનાશક દવા ખર્ચ',
    'પાકની લણણી ખર્ચ',
    'કુલ મજૂરી ખર્ચ',
    'અન્ય કોઈપણ ખર્ચ',
  ];

  final List<String> diseases = [
    "Taracharo", "Chharo", "Kunval Rog", "Lila Valno Rog", "Tapka Tadtadiya", 
    "Jhal Rog", "Ukheda Rog", "Loo Sado Rog", "Tapka Rog", "Balya Tapka Rog",
    "Talchhalo", "Pachhotalo Kuvaro", "Paanna Badami Tapka", "Danano Gariyo", 
    "Kantalyo Rog", "Kala Dana", "Dagarna Zhaka Dana no Rog", "Galatyo", "Karmod", 
    "Doshi Rog", "Kokadva", "Dhlo Gariyo", "Paanna Rog", "Kalvan", "Kajal Sado", 
    "Safed Geru", "Panno Jhal", "Kalo Sado", "Danani Moj", "Dhumra Rog", "Pocho Sado", 
    "Kadvano Sado", "Paanna Tapka", "Kand ane Luno Sado", "Pilo Pachrangayo", "Vangiyo Rog"
  ];

  final List<String> pests = [
    "Santhani Makhi", "Duma ni Iyal", "Gabhamarani Iyal", "Safed Makhi", "Ghoda ni Iyal", 
    "Lakad Iyal", "Gidar Jev", "Mealy Bug", "Katra", "Dagarna Suiya", "Dagarno Dar", 
    "Shinglawali Iyal", "Ruan Kasiya", "Khor Ukhanar Iyal", "Suiya", "Shing Makhi"
  ];

  final Map<String, TextEditingController> controllers = {};
  final Map<String, String?> dropdownValues = {};
  final Map<String, List<String>> multiselectValues = {};

  String? selectedSeason;
  String? selectedSeedType;
  String? selectedSeed;

  final Map<String, List<String>> seasonWiseEdible = {
    'Monsoon': ['Castor', 'Cotton', 'Fodder', 'Great Millet', 'Maize', 'Moth Beans', 'Paddy', 'Seasme', 'Soyabean', 'Sweet Corn', 'Other'],
    'Winter': ['Wheat', 'Maize', 'Gram', 'Mustard', 'Fennel', 'Fodder', 'Other'],
    'Summer': ['Pearl Millet', 'seasme', 'Black Gram', 'Green Gram', 'Paddy', 'Fodder', 'Other'],
  };

  final List<String> vegetables = ['Bitter Gourd', 'Bottle Gourd', 'Brinjal', 'Cabbage', 'Cauliflower', 'Cluster Bean', 'Cucumber', 'Drumstick', 'Fenugreek leaf', 'Green Bean', 'Green Chili', 'Lady finger', 'Luffa Gourd', 'Pumpkin', 'Radish', 'Spinach leaf', 'Spiny Gourd', 'Sweet potato', 'Tomato', 'Turmeric', 'Onion', 'Other'];

  final List<String> horticulture = ['Mango', 'Guava', 'Lemon', 'Flowers', 'Sapota', 'Custard Apple', 'Other'];

  @override
  void initState() {
    super.initState();
    for (var label in labelTypes.keys) {
      if (labelTypes[label] == 'text' || labelTypes[label] == 'number') {
        controllers[label] = TextEditingController();
      } 
      else if (labelTypes[label] == 'dropdown_yesno') {
        dropdownValues[label] = 'No'; // Default to No
      }
      else if (labelTypes[label] == 'multiselect') {
        multiselectValues[label] = [];
      }
    }
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  List<String> getAvailableSeeds() {
    if (selectedSeedType == null) return [];
    if (selectedSeedType == 'Name of Edible/non edible crop') {
      return selectedSeason != null ? seasonWiseEdible[selectedSeason!] ?? [] : [];
    } else if (selectedSeedType == 'Name of Vegetable crop for all season') {
      return vegetables;
    } else if (selectedSeedType == 'Name of Horticulture for all season') {
      return horticulture;
    } else {
      return [];
    }
  }

  Widget buildNumberField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controllers[label],
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget buildTextField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controllers[label],
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget buildDropdownYesNo(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        value: dropdownValues[label],
        items: ['Yes', 'No'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            dropdownValues[label] = newValue;
          });
        },
      ),
    );
  }

  Widget buildMultiselectField(String label) {
    final items = label == 'રોગનું નામ' ? diseases : pests;
    final selectedItems = multiselectValues[label] ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () async {
                final selected = await showDialog<List<String>>(
                  context: context,
                  builder: (context) => MultiSelectDialog(
                    title: label,
                    items: items,
                    initialSelected: selectedItems,
                  ),
                );
                if (selected != null) {
                  setState(() {
                    multiselectValues[label] = selected;
                  });
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text( 'Select' ,
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
            if (selectedItems.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: selectedItems.map((item) => Chip(
                  label: Text(item),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() {
                      multiselectValues[label]!.remove(item);
                    });
                  },
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  double calculateTotalExpense() {
    double total = 0.0;
    for (var field in expenseFields) {
      if (controllers.containsKey(field)) {
        final value = controllers[field]!.text.trim();
        if (value.isNotEmpty) {
          total += double.tryParse(value) ?? 0.0;
        }
      }
    }
    return total;
  }

  double calculateTotalIncome() {
    final production = double.tryParse(controllers['કુલ ઉત્પાદન (પ્રતિ મણ)']!.text.trim()) ?? 0.0;
    final rate = double.tryParse(controllers['વેચાણ ભાવ (પ્રતિ મણ)']!.text.trim()) ?? 0.0;
    return production * rate;
  }

  double calculateNetIncome(double totalExpense, double totalIncome) {
    final otherProduct = double.tryParse(controllers['અન્ય ઉત્પાદનની કુલ કિંમત']!.text.trim()) ?? 0.0;
    return totalIncome + otherProduct - totalExpense;
  }

  @override
  Widget build(BuildContext context) {
    List<String> availableSeeds = getAvailableSeeds();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ખેડૂતના પાકની વિગતો ઉમેરો', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'ઋતુ પસંદ કરો',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              value: selectedSeason,
              items: ['Monsoon', 'Winter', 'Summer'].map((season) {
                return DropdownMenuItem(value: season, child: Text(season));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSeason = value;
                  selectedSeed = null;
                });
              },
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'પાક પ્રકાર પસંદ કરો',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              value: selectedSeedType,
              items: [
                'Name of Edible/non edible crop',
                'Name of Vegetable crop for all season',
                'Name of Horticulture for all season'
              ].map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSeedType = value;
                  selectedSeed = null;
                });
              },
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'પાક પસંદ કરો',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              value: selectedSeed,
              items: availableSeeds.map((seed) {
                return DropdownMenuItem(value: seed, child: Text(seed));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSeed = value;
                });
              },
            ),
            const SizedBox(height: 10),

            ...labelTypes.entries.map((entry) {
              final label = entry.key;
              final type = entry.value;

              if (label == 'કુલ ટન (છાણ/બાયો ખાતર)' || 
                  label == 'કુલ છાણ/બાયો ખાતર ખર્ચ') {
                if (dropdownValues['શું તમે ખાતર/છાણ/અન્ય બાયો ખાતર વાપર્યું?'] != 'Yes') {
                  return const SizedBox();
                }
              }
              if (label == 'જમીન તૈયારી ખર્ચ') {
                if (dropdownValues['શું વાવણી પહેલા જમીન તૈયાર કરી હતી?'] != 'Yes') {
                  return const SizedBox();
                }
              }

              if (type == 'number') return buildNumberField(label);
              if (type == 'text') return buildTextField(label);
              if (type == 'dropdown_yesno') return buildDropdownYesNo(label);
              if (type == 'multiselect') return buildMultiselectField(label);
              
              return const SizedBox();
            }),

            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (selectedSeason == null || selectedSeedType == null || selectedSeed == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("મોસમ, પાક પ્રકાર અને પાક પસંદ કરો")),
                    );
                    return;
                  }

                  Map<String, dynamic> data = {
                    'ration_card_no': widget.rationCardNo,
                    'season': selectedSeason,
                    'crop_type': selectedSeedType,
                    'crop': selectedSeed,
                    'timestamp': FieldValue.serverTimestamp(),
                  };

                  bool isValid = true;
                  
                  // Process all fields
                  for (var label in labelTypes.keys) {
                    final type = labelTypes[label];
                    
                    // Skip conditional fields that shouldn't be shown
                    if ((label == 'કુલ ટન (છાણ/બાયો ખાતર)' || 
                         label == 'કુલ છાણ/બાયો ખાતર ખર્ચ') && 
                        dropdownValues['શું તમે ખાતર/છાણ/અન્ય બાયો ખાતર વાપર્યું?'] != 'Yes') {
                      continue;
                    }
                    if (label == 'જમીન તૈયારી ખર્ચ' && 
                        dropdownValues['શું વાવણી પહેલા જમીન તૈયાર કરી હતી?'] != 'Yes') {
                      continue;
                    }
                    
                    final englishKey = fieldKeys[label]!;
                    
                    if (type == 'text' || type == 'number') {
                      String value = controllers[label]!.text.trim();
                      if (value.isEmpty) {
                        isValid = false;
                        break;
                      }
                      data[englishKey] = double.tryParse(value) ?? 0.0;
                    } 
                    else if (type == 'dropdown_yesno') {
                      data[englishKey] = dropdownValues[label];
                    } 
                    else if (type == 'multiselect') {
                      data[englishKey] = multiselectValues[label];
                    }
                  }

                  if (isValid) {
                    // Calculate and store financial metrics
                    final totalExpense = calculateTotalExpense();
                    final totalIncome = calculateTotalIncome();
                    final netIncome = calculateNetIncome(totalExpense, totalIncome);
                    
                    data[calculatedKeys['કુલ આવક']!] = totalIncome;
                    data[calculatedKeys['કુલ ખર્ચ']!] = totalExpense;
                    data[calculatedKeys['નિકાળ આવક']!] = netIncome;

                    String id = DateTime.now().millisecondsSinceEpoch.toString();
                    await firestore.doc(id).set(data);

                    // Reset form
                    for (var controller in controllers.values) {
                      controller.clear();
                    }
                    for (var key in dropdownValues.keys) {
                      dropdownValues[key] = 'No';
                    }
                    for (var key in multiselectValues.keys) {
                      multiselectValues[key] = [];
                    }

                    setState(() {
                      selectedSeason = null;
                      selectedSeed = null;
                      selectedSeedType = null;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("માહિતી સફળતાપૂર્વક સાચવાઈ")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("બધી માહિતી ભરો")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Save", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MultiSelectDialog extends StatefulWidget {
  final String title;
  final List<String> items;
  final List<String> initialSelected;

  const MultiSelectDialog({
    super.key,
    required this.title,
    required this.items,
    required this.initialSelected,
  });

  @override
  State<MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  List<String> selectedItems = [];

  @override
  void initState() {
    super.initState();
    selectedItems = List.from(widget.initialSelected);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            final item = widget.items[index];
            return CheckboxListTile(
              title: Text(item),
              value: selectedItems.contains(item),
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    selectedItems.add(item);
                  } else {
                    selectedItems.remove(item);
                  }
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, selectedItems),
          child: const Text('OK'),
        ),
      ],
    );
  }
}