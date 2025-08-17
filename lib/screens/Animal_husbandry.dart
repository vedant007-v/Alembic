import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnimalHusbandryScreen extends StatefulWidget {
  const AnimalHusbandryScreen({super.key, required String rationCardNo});

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
    '(2022)પહેલાં દૂધ ઉત્પાદન (દરરોજ)': TextEditingController(),
    'પ્રોજેક્ટ પછી દૂધ ઉત્પાદન (દરરોજ)': TextEditingController(),
  };

  final Map<String, String?> dropdownValues = {
    'AI લાભ મળ્યો છે?': null,
    'વ્યાસન થયું છે?': null,
    'મિનરલ મિશ્રણ વાપર્યું છે?': null,
    'ડિવોર્મિંગ ટેબલેટ વાપર્યું છે?': null,
  };
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('પશુપાલન માહિતી ઉમેરો' ,style: TextStyle(color: Colors.white)),
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
              ...controllers.keys.map(buildTextField).toList(),

              const SizedBox(height: 10),

              // Dropdowns
              ...dropdownValues.keys.map(buildDropdownYesNo).toList(),

              const SizedBox(height: 20),
               buildMultiselectField('વિયહાન થયું છે'),
               const SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  onPressed: () async {
  if (_formKey.currentState!.validate()) {
    Map<String, dynamic> data = {
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

    // ✅ Add multi-select values
    data['વિયહાન થયું છે'] = multiselectValues['વિયહાન થયું છે'];

    await firestore.add(data);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("માહિતી સફળતાપૂર્વક સાચવાઈ")),
    );

    // Clear all form fields
    controllers.forEach((key, controller) => controller.clear());
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
        keyboardType: TextInputType.number,
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
          });
        },
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