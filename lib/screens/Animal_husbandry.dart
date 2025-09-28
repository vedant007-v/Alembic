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

  // List for વિયાણ animals
  final List<String> viyahanAnimals = [
    'ગાયની વાછડી',
    'ગાયનો વાછડો',
    'ભેંસની પાડી',
    'ભેંસનો પાડો',
  ];

  // Track selected animals
  final Map<String, List<String>> multiselectValues = {
    'વિયાણ થયું છે': [],
  };
  final Map<String, TextEditingController> animalQuantityControllers = {};

  // Controllers
  final Map<String, TextEditingController> controllers = {
    'ગાય (સંખ્યા)': TextEditingController(),
    'ભેંસ (સંખ્યા)': TextEditingController(),
    'બકરી (સંખ્યા)': TextEditingController(),
    'ઘેટાં (સંખ્યા)': TextEditingController(),
    '(2022)પહેલાં દૂધ ઉત્પાદન (દરરોજ)': TextEditingController(),
    'પ્રોજેક્ટ પછી દૂધ ઉત્પાદન (દરરોજ)': TextEditingController(),
  };

  // Dropdowns
  final Map<String, String?> dropdownValues = {
    'AI લાભ મળ્યો છે?': null,
    'મિનરલ મિશ્રણ વાપર્યું છે?': null,
    'ડિવોર્મિંગ ટેબલેટ વાપર્યું છે?': null,
    'અન્ય બીજી કઈ સહાય મળી?': null,
    'વિયાણ થયું છે': null, // ✅ Yes/No dropdown
  };

  // Dynamic "અન્ય" fields
  int otherSupportCount = 0;
  List<TextEditingController> otherNameControllers = [];
  List<TextEditingController> otherQtyControllers = [];

  // ----------------- Multiselect Builder -----------------
  Widget buildMultiselectField(String label) {
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
                    items: viyahanAnimals,
                    initialSelected: selectedItems,
                  ),
                );
                if (selected != null) {
                  setState(() {
                    for (final animal in selected) {
                      animalQuantityControllers.putIfAbsent(
                        animal,
                        () => TextEditingController(),
                      );
                    }
                    animalQuantityControllers
                        .removeWhere((k, v) => !selected.contains(k));

                    multiselectValues[label] = selected;
                  });
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedItems.isEmpty
                        ? 'Select'
                        : 'Selected: ${selectedItems.length}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
            if (selectedItems.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...selectedItems.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Chip(
                            label: Text(item),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () {
                              setState(() {
                                multiselectValues[label]!.remove(item);
                                animalQuantityControllers
                                    .remove(item)
                                    ?.dispose();
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
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                            ),
                            validator: (value) {
                              if ((multiselectValues[label] ?? [])
                                  .contains(item)) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'આવશ્યક';
                                }
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

  // ----------------- Build -----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('પશુપાલન માહિતી ઉમેરો',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Text fields
              ...controllers.keys.map(buildTextField).toList(),

              const SizedBox(height: 10),

              // Dropdowns
              ...dropdownValues.keys.map(buildDropdownYesNo).toList(),

              // Show વિયાણ multiselect if Yes
              if (dropdownValues['વિયાણ થયું છે'] == 'હા') ...[
                const SizedBox(height: 20),
                buildMultiselectField('વિયાણ થયું છે'),
              ],

              // Show "અન્ય" fields if Yes
              if (dropdownValues['અન્ય બીજી કઈ સહાય મળી?'] == 'હા') ...[
                const SizedBox(height: 20),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'કેટલી સહાય?',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) {
                    final count = int.tryParse(val) ?? 0;
                    setState(() {
                      otherSupportCount = count;
                      otherNameControllers =
                          List.generate(count, (_) => TextEditingController());
                      otherQtyControllers =
                          List.generate(count, (_) => TextEditingController());
                    });
                  },
                ),
                const SizedBox(height: 10),
                ...List.generate(otherSupportCount, (index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: otherNameControllers[index],
                          decoration: InputDecoration(
                            labelText: 'સહાય ${index + 1} નામ',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: otherQtyControllers[index],
                          decoration: InputDecoration(
                            labelText: 'સહાય ${index + 1} સંખ્યા',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  );
                }),
              ],

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveForm,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: const Text('માહિતી ઉમેરો',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------- Helpers -----------------
  Widget buildTextField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: controllers[label],
        keyboardType:
            label.contains('નામ') ? TextInputType.text : TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
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
        items: ['હા', 'ના'].map((val) {
          return DropdownMenuItem(value: val, child: Text(val));
        }).toList(),
        onChanged: (val) {
          setState(() {
            dropdownValues[label] = val;
            if (label == 'અન્ય બીજી કઈ સહાય મળી?' && val != 'હા') {
              otherSupportCount = 0;
              otherNameControllers.clear();
              otherQtyControllers.clear();
            }
          });
        },
      ),
    );
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'rationCardNo': widget.rationCardNo,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Dropdowns
      dropdownValues.forEach((k, v) => data[k] = v ?? '');

      // Text fields
      controllers.forEach((k, c) => data[k] = c.text.trim());

      // વિયાણ
      if (dropdownValues['વિયાણ થયું છે'] == 'હા') {
        final selected = multiselectValues['વિયાણ થયું છે'] ?? [];
        final Map<String, dynamic> viyahanData = {};
        for (final animal in selected) {
          viyahanData[animal] =
              animalQuantityControllers[animal]?.text.trim() ?? '';
        }
        data['વિયાણ થયું છે'] = viyahanData;
      }

      // અન્ય સહાય
      if (dropdownValues['અન્ય બીજી કઈ સહાય મળી?'] == 'હા') {
        final List<Map<String, String>> otherSupports = [];
        for (int i = 0; i < otherSupportCount; i++) {
          otherSupports.add({
            'name': otherNameControllers[i].text.trim(),
            'qty': otherQtyControllers[i].text.trim(),
          });
        }
        data['અન્ય સહાય'] = otherSupports;
      }

      await firestore.add(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("માહિતી સફળતાપૂર્વક સાચવાઈ")),
      );
    }
  }

  @override
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
    for (final c in animalQuantityControllers.values) {
      c.dispose();
    }
    for (final c in otherNameControllers) {
      c.dispose();
    }
    for (final c in otherQtyControllers) {
      c.dispose();
    }
    super.dispose();
  }
}

// ----------------- MultiSelectDialog -----------------
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
        child: Column(
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
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, selected),
          child: const Text('OK'),
        ),
      ],
    );
  }
}