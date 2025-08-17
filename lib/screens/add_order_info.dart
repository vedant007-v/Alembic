import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddInterventionScreen extends StatefulWidget {
  final String rationCardNo;
  const AddInterventionScreen({super.key, required this.rationCardNo});

  @override
  State<AddInterventionScreen> createState() => _AddInterventionScreenState();
}

class _AddInterventionScreenState extends State<AddInterventionScreen> {
  final _formKey = GlobalKey<FormState>();

  final firestore = FirebaseFirestore.instance.collection('interventions');

  final TextEditingController seedAreaController = TextEditingController();
  final TextEditingController biofertilizerQtyController = TextEditingController();
  final TextEditingController otherHelpAreaController = TextEditingController();
  final TextEditingController otherHelpnumaberController = TextEditingController();

  final Map<String, String> fieldKeyMap = {
  'મોસમ': 'season',
  'કેટલું બીજ આપ્યું': 'seed_given',
  'બીજ માટે વિઘા': 'seed_area',
  'હસ્તક્ષેપ': 'interventions',
  'કેટલું બિયારણ મળ્યું છે': 'biofertilizer_quantity',
  'અન્ય સહાય મળી છે': 'other_help_given',
  'અન્ય સહાય': 'other_help_items',
  'અન્ય સહાય માટે વિઘા': 'other_help_area',
  'સહાય મા કેટલું આપ્યું (કિ.ગ્રા/સંખ્યા)': 'other_help_quantity',
};


  final List<String> seasonOptions = ['Summer', 'Monsoon', 'Winter'];
 final List<String> interventions = [
  'Halder Seeds (kg)',
  'Dhan (kg)',
  'Castor (kg)',
  'Toovar Dal (kg)',
  'Sweet Corn (kg)',
  'Trichoderma',
  'Pseudomonas',
  'Sagarika (ml)',
  'Nano Urea Plus (ml)',
  'Cow Pea (Seed Count)',
  'Onion Seeds (kg)',
  'Organic Fertilizer',
  'Wheat',
  'Green Moong (kg)',
  'Sesame/Til (kg)',
  'Mycorrhiza Packet Count',
];
final List<String> otherHelp = [
  'Yellow Sticky Trap',
  'Pheromone Trap',
  'Hydrogel',
];


  String? selectedSeason;
  String? seedGiven; // Yes or No
  String? otherHelpGiven; // Yes or No

  Map<String, String?> dropdownValues = {};
  Map<String, List<String>> multiselectValues = {};

  @override
  void initState() {
    super.initState();
    dropdownValues['તમને બિયારન માલ્યુ છે'] = null;//કેટલું બીજ આપ્યું (કિ.ગ્રા/સંખ્યા)
    dropdownValues['અન્ય સહાય મળી છે?'] = null;
    multiselectValues['હસ્તક્ષેપ'] = [];
    multiselectValues['અન્ય સહાય'] = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('હસ્તક્ષેપ માહિતી ઉમેરો' ,style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'મોસમ પસંદ કરો',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                value: selectedSeason,
                items: seasonOptions.map((season) {
                  return DropdownMenuItem(
                    value: season,
                    child: Text(season),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSeason = value;
                  });
                },
              ),

              const SizedBox(height: 10),
              buildDropdownYesNo('કેટલું બીજ આપ્યું (કિ.ગ્રા/સંખ્યા)'),

              if (dropdownValues['કેટલું બીજ આપ્યું (કિ.ગ્રા/સંખ્યા)'] == 'Yes') ...[
                buildMultiselectField('હસ્તક્ષેપ', interventions),
                buildTextField('જો હા, કેટલુ વિઘા માટે', seedAreaController),
                buildTextField('કેટલું બીજ આપ્યું (કિ.ગ્રા/સંખ્યા)', biofertilizerQtyController),
              ],

              const SizedBox(height: 10),
              buildDropdownYesNo('અન્ય સહાય મળી છે?'),

              if (dropdownValues['અન્ય સહાય મળી છે?'] == 'Yes') ...[
                buildMultiselectField('અન્ય સહાય', otherHelp),
                buildTextField('જો હા, કેટલુ વિઘા', otherHelpAreaController),
                buildTextField('સહાય મા કેટલું આપ્યું (કિ.ગ્રા/સંખ્યા)',otherHelpnumaberController ),
              ],

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                 Map<String, dynamic> data = {
  fieldKeyMap['મોસમ']!: selectedSeason,
  fieldKeyMap['કેટલું બીજ આપ્યું']!: dropdownValues['કેટલું બીજ આપ્યું (કિ.ગ્રા/સંખ્યા)'],
  fieldKeyMap['અન્ય સહાય મળી છે']!: dropdownValues['અન્ય સહાય મળી છે?'],
  'ration_card_no': widget.rationCardNo,
  'timestamp': FieldValue.serverTimestamp(),
};

if (dropdownValues['કેટલું બીજ આપ્યું (કિ.ગ્રા/સંખ્યા)'] == 'Yes') {
  data[fieldKeyMap['બીજ માટે વિઘા']!] = seedAreaController.text;
  data[fieldKeyMap['હસ્તક્ષેપ']!] = multiselectValues['હસ્તક્ષેપ'];
  data[fieldKeyMap['કેટલું બિયારણ મળ્યું છે']!] = biofertilizerQtyController.text;
}

if (dropdownValues['અન્ય સહાય મળી છે?'] == 'Yes') {
  data[fieldKeyMap['અન્ય સહાય']!] = multiselectValues['અન્ય સહાય'];
  data[fieldKeyMap['અન્ય સહાય માટે વિઘા']!] = otherHelpAreaController.text;
  data[fieldKeyMap['સહાય મા કેટલું આપ્યું (કિ.ગ્રા/સંખ્યા)']!] = otherHelpnumaberController.text;
}


                  await firestore.add(data);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("માહિતી સફળતાપૂર્વક સાચવાઈ")),
                  );

                  setState(() {
                    selectedSeason = null;
                    dropdownValues.updateAll((key, value) => null);
                    multiselectValues.updateAll((key, value) => []);
                    seedAreaController.clear();
                    otherHelpAreaController.clear();
                    biofertilizerQtyController.clear();
                  });
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
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: controller,
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
            child: Text(value == 'Yes' ? 'Yes' : 'NO'),
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

  Widget buildMultiselectField(String label, List<String> items) {
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
                children: const [
                  Text('પસંદ કરો', style: TextStyle(fontSize: 16)),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
            if (selectedItems.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: selectedItems
                    .map((item) => Chip(
                          label: Text(item),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              multiselectValues[label]?.remove(item);
                            });
                          },
                        ))
                    .toList(),
              ),
            ],
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
    required this.title,
    required this.items,
    required this.initialSelected,
  });

  @override
  State<MultiSelectDialog> createState() => _MultiSelectDialogState();
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
            return CheckboxListTile(
              title: Text(item),
              value: selected.contains(item),
              onChanged: (bool? checked) {
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
          child: const Text('રદ કરો'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text('પસંદ કરો'),
          onPressed: () => Navigator.pop(context, selected),
        ),
      ],
    );
  }
}
