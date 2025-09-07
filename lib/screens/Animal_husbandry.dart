import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnimalHusbandryScreen extends StatefulWidget {
  final String rationCardNo;
  const AnimalHusbandryScreen({super.key, required this.rationCardNo});

  @override
  _AnimalHusbandryScreenState createState() => _AnimalHusbandryScreenState();
}

class _AnimalHusbandryScreenState extends State<AnimalHusbandryScreen> {
  final _formKey = GlobalKey<FormState>();

  final firestore = FirebaseFirestore.instance.collection('animal_husbandry');
  final List<String> viyahanAnimals = [
    'ગાયની વાછડી',
    'ગાયનો વાછડો',
    'ભેંસની પાડી',
    'ભેંસનો પાડો',
  ];
  

  final Map<String, List<String>> multiselectValues = {
    'વિયહાન થયું છે': [],
  };

  // Quantity controllers for each selected animal in multiselect
  final Map<String, TextEditingController> animalQuantityControllers = {};

  // You can add more lists for different labels if needed.
  List<String> getItemsForLabel(String label) {
    if (label == 'વિયહાન થયું છે') {
      return viyahanAnimals;
    }
    return []; // fallback if unknown label
  }

  Widget buildMultiselectField(String label) {
    final items = getItemsForLabel(label);
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
                    // Initialize controllers for newly selected animals
                    for (final animal in selected) {
                      animalQuantityControllers.putIfAbsent(
                        animal,
                        () => TextEditingController(),
                      );
                    }
                    // Remove controllers for unselected animals
                    animalQuantityControllers.removeWhere((k, v) => !selected.contains(k));

                    multiselectValues[label] = selected;
                  });
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedItems.isEmpty ? 'Select' : 'Selected: ${selectedItems.length}',
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
            if (selectedItems.isNotEmpty) ...[
              const SizedBox(height: 8),
              // For each selected animal, show a chip and a quantity field
              ...selectedItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Chip(
                        label: Text(item),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() {
                            multiselectValues[label]!.remove(item);
                            animalQuantityControllers.remove(item)?.dispose();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 110,
                      child: TextFormField(
                        controller: animalQuantityControllers[item],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'સંખ્યા',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        ),
                        validator: (value) {
                          if ((multiselectValues[label] ?? []).contains(item)) {
                            if (value == null || value.trim().isEmpty) return 'આવશ્યક';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }


  final Map<String, TextEditingController> controllers = {
    'ગાય (સંખ્યા)': TextEditingController(),
    'ગાયનો વાછડો ': TextEditingController(),
    'ગાયની વાછડી ': TextEditingController(),
    'ભેંસ': TextEditingController(),
    'ભેંસનો પાડો': TextEditingController(),
    'ભેંસની પાડી': TextEditingController(),
    'બકરી': TextEditingController(),
    'ઘેટાં': TextEditingController(),
    'અન્ય': TextEditingController(),
    'અન્યનું નામ': TextEditingController(),
    '(2022)પહેલાં દૂધ ઉત્પાદન (દરરોજ)': TextEditingController(),
    'પ્રોજેક્ટ પછી દૂધ ઉત્પાદન (દરરોજ)': TextEditingController(),
  };

  final Map<String, String?> dropdownValues = {
    'AI લાભ મળ્યો છે?': null,
    'વિયહાન થયું છે?': null,
    'મિનરલ મિશ્રણ વાપર્યું છે?': null,
    'ડિવોર્મિંગ ટેબલેટ વાપર્યું છે?': null,
    'અન્ય છે?': null,
  };
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('પશુપાલન માહિતી ઉમેરો' ,style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
         iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text Fields
              ...controllers.keys
                  .where((key) => key != 'અન્ય' && key != 'અન્યનું નામ')
                  .map(buildTextField)
                  .toList(),

              const SizedBox(height: 10),

              // Dropdowns
              ...dropdownValues.keys.map(buildDropdownYesNo).toList(),

              if (dropdownValues['અન્ય છે?'] == 'હા') ...[
                buildTextField('અન્ય'),
                buildTextField('અન્યનું નામ'),
              ],

              const SizedBox(height: 20),
               buildMultiselectField('વિયહાન થયું છે'),
               const SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  onPressed: () async {
  if (_formKey.currentState!.validate()) {
    Map<String, dynamic> data = {
      'rationCardNo' : widget.rationCardNo,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Add dropdown values
    dropdownValues.forEach((key, val) {
      data[key] = val ?? '';
    });

    // Add text field values
    controllers.forEach((key, controller) {
      data[key] = controller.text.trim();
    });

    // Add multi-select values with quantities as a map
    final List<String> selected = multiselectValues['વિયહાન થયું છે'] ?? [];
    final Map<String, dynamic> viyahanData = {};
    for (final animal in selected) {
      viyahanData[animal] = animalQuantityControllers[animal]?.text.trim() ?? '';
    }
    data['વિયહાન થયું છે'] = viyahanData;

    await firestore.add(data);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("માહિતી સફળતાપૂર્વક સાચવાઈ")),
    );

    // Clear all form fields
    controllers.forEach((key, controller) => controller.clear());
    animalQuantityControllers.forEach((key, controller) => controller.clear());
    setState(() {
      dropdownValues.updateAll((key, value) => null);
      multiselectValues.updateAll((key, value) => []);
    });
  }
},
                  style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'માહિતી ઉમેરો',
                  style: TextStyle(color: Colors.white),
                ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: controllers[label],
        keyboardType: label.contains('નામ') ? TextInputType.text : TextInputType.number,
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
        validator: (value) => value == null ? 'કૃપા કરીને પસંદ કરો' : null,
        items: ['હા', 'ના'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            dropdownValues[label] = newValue;
            // If Other == 'ના', clear hidden fields to avoid saving stale values
            if (label == 'અન્ય છે?' && newValue != 'હા') {
              controllers['અન્ય']?.clear();
              controllers['અન્યનું નામ']?.clear();
            }
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    // Dispose standard text controllers
    for (final c in controllers.values) {
      c.dispose();
    }
    // Dispose animal quantity controllers
    for (final c in animalQuantityControllers.values) {
      c.dispose();
    }
    super.dispose();
  }
}
class MultiSelectDialog extends StatefulWidget {
  final String title;
  final List<String> items;
  final List<String> initialSelected;

  const MultiSelectDialog({super.key, 
    required this.title,
    required this.items,
    required this.initialSelected,
  });

  @override
  _MultiSelectDialogState createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  late List<String> selected;

  @override
  void initState() {
    super.initState();
    selected = List.from(widget.initialSelected);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items.map((item) {
            final isSelected = selected.contains(item);
            return CheckboxListTile(
              value: isSelected,
              title: Text(item),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    selected.add(item);
                  } else {
                    selected.remove(item);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text('OK'),
          onPressed: () => Navigator.pop(context, selected),
        ),
      ],
    );
  }
}