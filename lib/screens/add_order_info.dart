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
  final TextEditingController otherHelpAreaController = TextEditingController();
  final TextEditingController otherInterventionNameController =
      TextEditingController();
  final TextEditingController otherHelpNameController = TextEditingController();
  final TextEditingController otherInterventionQtyController =
      TextEditingController();
  final TextEditingController otherHelpQtyController = TextEditingController();
  final TextEditingController otherInterventionCountController =
      TextEditingController();
  final TextEditingController otherHelpCountController =
      TextEditingController();
  List<TextEditingController> otherInterventionNameControllers = [];
  List<TextEditingController> otherInterventionQtyControllersList = [];
  List<TextEditingController> otherInterventionAreaControllers = [];
  List<TextEditingController> otherHelpNameControllers = [];
  List<TextEditingController> otherHelpQtyControllersList = [];
  List<TextEditingController> otherHelpAreaControllersList = [];

  final Map<String, TextEditingController> interventionQtyControllers = {};
  final Map<String, TextEditingController> otherHelpQtyControllers = {};
  final Map<String, TextEditingController> interventionAreaControllers = {};
  final Map<String, TextEditingController> otherHelpAreaControllers = {};

  final Map<String, String> fieldKeyMap = {
    'મોસમ': 'season',
    'બીજ આપ્યું': 'seed_given',
    'બીજ માટે વિઘા': 'seed_area',
    'હસ્તક્ષેપ': 'interventions',
    'અન્ય સહાય મળી છે': 'other_help_given',
    'અન્ય સહાય': 'other_help_items',
    'અન્ય સહાય માટે વિઘા': 'other_help_area',
  };

  final List<String> seasonOptions = ['Summer', 'Monsoon', 'Winter'];
  final List<String> interventions = [
    'Halder Seeds (kg)',
    'Paddy (kg)',
    'Castor (kg)',
    'Toovar Dal (kg)',
    'Sweet Corn (kg)',
    'Trichoderma',
    'Pseudomonas',
    'Sagarika (ml/kg)',
    'Nano Urea Plus (ml)',
    'Cow Pea (Seed Count)',
    'Onion Seeds (kg)',
    'Organic Fertilizer',
    'Wheat',
    'Green Moong (kg)',
    'Sesame/Til (kg)',
    'Mycorrhiza Packet Count',
    'Other',
  ];
  final List<String> otherHelp = [
    'Yellow Sticky Trap',
    'Pheromone Trap',
    'Hydrogel',
    'Other',
  ];

  String? selectedSeason;
  String? seedGiven; // Yes or No
  String? otherHelpGiven; // Yes or No

  Map<String, String?> dropdownValues = {};
  Map<String, List<String>> multiselectValues = {};

  @override
  void initState() {
    super.initState();
    dropdownValues['બીજ આપ્યું (કિ.ગ્રા/સંખ્યા)'] = null;
    dropdownValues['અન્ય સહાય મળી છે?'] = null;
    multiselectValues['હસ્તક્ષેપ'] = [];
    multiselectValues['અન્ય સહાય'] = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('હસ્તક્ષેપ માહિતી ઉમેરો',
            style: TextStyle(color: Colors.white)),
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
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
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
              buildDropdownYesNo('બીજ આપ્યું (કિ.ગ્રા/સંખ્યા)'),
              if (dropdownValues['બીજ આપ્યું (કિ.ગ્રા/સંખ્યા)'] == 'Yes') ...[
                buildMultiselectField('હસ્તક્ષેપ', interventions),
                if ((multiselectValues['હસ્તક્ષેપ'] ?? [])
                    .contains('Other')) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: TextField(
                      controller: otherInterventionCountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'How many Other interventions?',
                        labelStyle: const TextStyle(fontSize: 14),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onChanged: (v) {
                        final n = int.tryParse(v.trim()) ?? 0;
                        setState(() {
                          void _resize<T>(
                              List<T> list,
                              int n,
                              T Function() builder,
                              void Function(T)? disposer) {
                            if (list.length < n) {
                              while (list.length < n) list.add(builder());
                            } else if (list.length > n) {
                              while (list.length > n) {
                                final item = list.removeLast();
                                disposer?.call(item);
                              }
                            }
                          }

                          _resize<TextEditingController>(
                              otherInterventionNameControllers,
                              n,
                              () => TextEditingController(),
                              (c) => c.dispose());
                          _resize<TextEditingController>(
                              otherInterventionQtyControllersList,
                              n,
                              () => TextEditingController(),
                              (c) => c.dispose());
                          _resize<TextEditingController>(
                              otherInterventionAreaControllers,
                              n,
                              () => TextEditingController(),
                              (c) => c.dispose());
                        });
                      },
                    ),
                  ),
                  ...List.generate(otherInterventionNameControllers.length,
                      (i) {
                    return Column(
                      children: [
                        buildTextField('Other Intervention Name #${i + 1}',
                            otherInterventionNameControllers[i]),
                        buildNumberField(
                            'Other Intervention Quantity #${i + 1}',
                            otherInterventionQtyControllersList[i]),
                        buildNumberField(
                            'Other Intervention Area (વિઘા) #${i + 1}',
                            otherInterventionAreaControllers[i]),
                      ],
                    );
                  }),
                ],
                if ((multiselectValues['હસ્તક્ષેપ'] ?? []).isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...((multiselectValues['હસ્તક્ષેપ'] ?? [])
                      .where((e) => e != 'Other')).map((item) {
                    interventionQtyControllers.putIfAbsent(
                        item, () => TextEditingController());
                    interventionAreaControllers.putIfAbsent(
                        item, () => TextEditingController());
                    return Column(
                      children: [
                        buildNumberField('$item quantity',
                            interventionQtyControllers[item]!),
                        buildNumberField('$item area (વિઘા)',
                            interventionAreaControllers[item]!),
                      ],
                    );
                  }).toList(),
                ],
                buildNumberField(
                    'જો હા, કેટલુ વિઘા માટે (કુલ)', seedAreaController),
              ],
              const SizedBox(height: 10),
              buildDropdownYesNo('અન્ય સહાય મળી છે?'),
              if (dropdownValues['અન્ય સહાય મળી છે?'] == 'Yes') ...[
                buildMultiselectField('અન્ય સહાય', otherHelp),
                if ((multiselectValues['અન્ય સહાય'] ?? [])
                    .contains('Other')) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: TextField(
                      controller: otherHelpCountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'How many Other helps?',
                        labelStyle: const TextStyle(fontSize: 14),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onChanged: (v) {
                        final n = int.tryParse(v.trim()) ?? 0;
                        setState(() {
                          void _resize<T>(
                              List<T> list,
                              int n,
                              T Function() builder,
                              void Function(T)? disposer) {
                            if (list.length < n) {
                              while (list.length < n) list.add(builder());
                            } else if (list.length > n) {
                              while (list.length > n) {
                                final item = list.removeLast();
                                disposer?.call(item);
                              }
                            }
                          }

                          _resize<TextEditingController>(
                              otherHelpNameControllers,
                              n,
                              () => TextEditingController(),
                              (c) => c.dispose());
                          _resize<TextEditingController>(
                              otherHelpQtyControllersList,
                              n,
                              () => TextEditingController(),
                              (c) => c.dispose());
                          _resize<TextEditingController>(
                              otherHelpAreaControllersList,
                              n,
                              () => TextEditingController(),
                              (c) => c.dispose());
                        });
                      },
                    ),
                  ),
                  ...List.generate(otherHelpNameControllers.length, (i) {
                    return Column(
                      children: [
                        buildTextField('Other Help Name #${i + 1}',
                            otherHelpNameControllers[i]),
                        buildNumberField('Other Help Quantity #${i + 1}',
                            otherHelpQtyControllersList[i]),
                        buildNumberField('Other Help Area (વિઘા) #${i + 1}',
                            otherHelpAreaControllersList[i]),
                      ],
                    );
                  }),
                ],
                if ((multiselectValues['અન્ય સહાય'] ?? []).isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...((multiselectValues['અન્ય સહાય'] ?? [])
                      .where((e) => e != 'Other')).map((item) {
                    otherHelpQtyControllers.putIfAbsent(
                        item, () => TextEditingController());
                    otherHelpAreaControllers.putIfAbsent(
                        item, () => TextEditingController());
                    return Column(
                      children: [
                        buildNumberField(
                            '$item quantity', otherHelpQtyControllers[item]!),
                        buildNumberField('$item area (વિઘા)',
                            otherHelpAreaControllers[item]!),
                      ],
                    );
                  }).toList(),
                ],
                buildNumberField(
                    'જો હા, કેટલુ વિઘા (કુલ)', otherHelpAreaController),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (dropdownValues['બીજ આપ્યું (કિ.ગ્રા/સંખ્યા)'] == 'Yes' &&
                      (multiselectValues['હસ્તક્ષેપ'] ?? [])
                          .contains('Other')) {
                    final n = int.tryParse(
                            otherInterventionCountController.text.trim()) ??
                        0;
                    if (n <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Please enter how many Other interventions.')),
                      );
                      return;
                    }
                    for (var i = 0; i < n; i++) {
                      if (otherInterventionNameControllers[i]
                          .text
                          .trim()
                          .isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Please enter name for Other Intervention #${i + 1}.')),
                        );
                        return;
                      }
                      if (otherInterventionQtyControllersList[i]
                          .text
                          .trim()
                          .isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Please enter quantity for Other Intervention #${i + 1}.')),
                        );
                        return;
                      }
                      if (otherInterventionAreaControllers[i]
                          .text
                          .trim()
                          .isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Please enter area for Other Intervention #${i + 1}.')),
                        );
                        return;
                      }
                    }
                  }
                  if (dropdownValues['અન્ય સહાય મળી છે?'] == 'Yes' &&
                      (multiselectValues['અન્ય સહાય'] ?? [])
                          .contains('Other')) {
                    final n =
                        int.tryParse(otherHelpCountController.text.trim()) ?? 0;
                    if (n <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Please enter how many Other helps.')),
                      );
                      return;
                    }
                    for (var i = 0; i < n; i++) {
                      if (otherHelpNameControllers[i].text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Please enter name for Other Help #${i + 1}.')),
                        );
                        return;
                      }
                      if (otherHelpQtyControllersList[i].text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Please enter quantity for Other Help #${i + 1}.')),
                        );
                        return;
                      }
                      if (otherHelpAreaControllersList[i].text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Please enter area for Other Help #${i + 1}.')),
                        );
                        return;
                      }
                    }
                  }
                  for (final item in (multiselectValues['હસ્તક્ષેપ'] ?? [])) {
                    if (item == 'Other') {
                      // Already validated above for dynamic others
                    } else if ((interventionQtyControllers[item]
                            ?.text
                            .trim()
                            .isEmpty ??
                        true)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Please enter quantity for $item.')),
                      );
                      return;
                    } else if ((interventionAreaControllers[item]
                            ?.text
                            .trim()
                            .isEmpty ??
                        true)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter area for $item.')),
                      );
                      return;
                    }
                  }
                  for (final item in (multiselectValues['અન્ય સહાય'] ?? [])) {
                    if (item == 'Other') {
                      // Already validated above for dynamic others
                    } else if ((otherHelpQtyControllers[item]
                            ?.text
                            .trim()
                            .isEmpty ??
                        true)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Please enter quantity for $item.')),
                      );
                      return;
                    } else if ((otherHelpAreaControllers[item]
                            ?.text
                            .trim()
                            .isEmpty ??
                        true)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter area for $item.')),
                      );
                      return;
                    }
                  }
                  Map<String, dynamic> data = {
                    fieldKeyMap['મોસમ']!: selectedSeason,
                    fieldKeyMap['બીજ આપ્યું']!:
                        dropdownValues['બીજ આપ્યું (કિ.ગ્રા/સંખ્યા)'],
                    fieldKeyMap['અન્ય સહાય મળી છે']!:
                        dropdownValues['અન્ય સહાય મળી છે?'],
                    'ration_card_no': widget.rationCardNo,
                    'timestamp': FieldValue.serverTimestamp(),
                  };

                  if (dropdownValues['બીજ આપ્યું (કિ.ગ્રા/સંખ્યા)'] == 'Yes') {
                    data[fieldKeyMap['બીજ માટે વિઘા']!] =
                        seedAreaController.text;
                    final List<String> selInterventions =
                        List<String>.from(multiselectValues['હસ્તક્ષેપ'] ?? []);
                    final List<String> normInterventions = selInterventions
                        .map((e) => e == 'Other' ? null : e)
                        .whereType<String>()
                        .toList();
                    data[fieldKeyMap['હસ્તક્ષેપ']!] = [
                      ...normInterventions,
                      ...List.generate(
                          otherInterventionNameControllers.length,
                          (i) => otherInterventionNameControllers[i]
                              .text
                              .trim()).where((e) => e.isNotEmpty),
                    ];
                    final Map<String, String> interventionQuantities = {};
                    final Map<String, String> interventionAreas = {};
                    for (final item in selInterventions) {
                      if (item == 'Other') {
                        for (var i = 0;
                            i < otherInterventionNameControllers.length;
                            i++) {
                          final name =
                              otherInterventionNameControllers[i].text.trim();
                          if (name.isNotEmpty) {
                            interventionQuantities[name] =
                                otherInterventionQtyControllersList[i]
                                    .text
                                    .trim();
                            interventionAreas[name] =
                                otherInterventionAreaControllers[i].text.trim();
                          }
                        }
                      } else {
                        interventionQuantities[item] =
                            interventionQtyControllers[item]?.text.trim() ?? '';
                        interventionAreas[item] =
                            interventionAreaControllers[item]?.text.trim() ??
                                '';
                      }
                    }
                    data['intervention_quantities'] = interventionQuantities;
                    data['intervention_areas'] = interventionAreas;
                  }

                  if (dropdownValues['અન્ય સહાય મળી છે?'] == 'Yes') {
                    final List<String> selHelps =
                        List<String>.from(multiselectValues['અન્ય સહાય'] ?? []);
                    final List<String> normHelps = selHelps
                        .map((e) => e == 'Other' ? null : e)
                        .whereType<String>()
                        .toList();
                    data[fieldKeyMap['અન્ય સહાય']!] = [
                      ...normHelps,
                      ...List.generate(otherHelpNameControllers.length,
                              (i) => otherHelpNameControllers[i].text.trim())
                          .where((e) => e.isNotEmpty),
                    ];
                    data[fieldKeyMap['અન્ય સહાય માટે વિઘા']!] =
                        otherHelpAreaController.text;
                    final Map<String, String> otherHelpQuantities = {};
                    final Map<String, String> otherHelpAreas = {};
                    for (final item in selHelps) {
                      if (item == 'Other') {
                        for (var i = 0;
                            i < otherHelpNameControllers.length;
                            i++) {
                          final name = otherHelpNameControllers[i].text.trim();
                          if (name.isNotEmpty) {
                            otherHelpQuantities[name] =
                                otherHelpQtyControllersList[i].text.trim();
                            otherHelpAreas[name] =
                                otherHelpAreaControllersList[i].text.trim();
                          }
                        }
                      } else {
                        otherHelpQuantities[item] =
                            otherHelpQtyControllers[item]?.text.trim() ?? '';
                        otherHelpAreas[item] =
                            otherHelpAreaControllers[item]?.text.trim() ?? '';
                      }
                    }
                    data['other_help_quantities'] = otherHelpQuantities;
                    data['other_help_areas'] = otherHelpAreas;
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
                    otherInterventionNameController.clear();
                    otherHelpNameController.clear();
                    otherInterventionQtyController.clear();
                    otherHelpQtyController.clear();
                    otherInterventionCountController.clear();
                    otherHelpCountController.clear();
                    for (final c in interventionAreaControllers.values) {
                      c.dispose();
                    }
                    interventionAreaControllers.clear();
                    for (final c in interventionQtyControllers.values) {
                      c.dispose();
                    }
                    interventionQtyControllers.clear();
                    for (final c in otherHelpAreaControllers.values) {
                      c.dispose();
                    }
                    otherHelpAreaControllers.clear();
                    for (final c in otherHelpQtyControllers.values) {
                      c.dispose();
                    }
                    otherHelpQtyControllers.clear();
                    for (final c in otherInterventionNameControllers) {
                      c.dispose();
                    }
                    for (final c in otherInterventionQtyControllersList) {
                      c.dispose();
                    }
                    for (final c in otherInterventionAreaControllers) {
                      c.dispose();
                    }
                    otherInterventionNameControllers = [];
                    otherInterventionQtyControllersList = [];
                    otherInterventionAreaControllers = [];
                    for (final c in otherHelpNameControllers) {
                      c.dispose();
                    }
                    for (final c in otherHelpQtyControllersList) {
                      c.dispose();
                    }
                    for (final c in otherHelpAreaControllersList) {
                      c.dispose();
                    }
                    otherHelpNameControllers = [];
                    otherHelpQtyControllersList = [];
                    otherHelpAreaControllersList = [];
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
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

  Widget buildNumberField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: controller,
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
        items: ['Yes', 'No'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value == 'Yes' ? 'હા' : 'ના'),
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
                    if (label == 'હસ્તક્ષેપ') {
                      for (final item in selected.where((e) => e != 'Other')) {
                        interventionQtyControllers.putIfAbsent(
                            item, () => TextEditingController());
                        interventionAreaControllers.putIfAbsent(
                            item, () => TextEditingController());
                      }
                      final toRemove = interventionQtyControllers.keys
                          .where((k) => !selected.contains(k))
                          .toList();
                      for (final k in toRemove) {
                        interventionQtyControllers[k]?.dispose();
                        interventionQtyControllers.remove(k);
                      }
                      final toRemoveArea = interventionAreaControllers.keys
                          .where((k) => !selected.contains(k))
                          .toList();
                      for (final k in toRemoveArea) {
                        interventionAreaControllers[k]?.dispose();
                        interventionAreaControllers.remove(k);
                      }
                      if (!selected.contains('Other')) {
                        otherInterventionCountController.clear();
                        for (final c in otherInterventionNameControllers) {
                          c.dispose();
                        }
                        for (final c in otherInterventionQtyControllersList) {
                          c.dispose();
                        }
                        for (final c in otherInterventionAreaControllers) {
                          c.dispose();
                        }
                        otherInterventionNameControllers = [];
                        otherInterventionQtyControllersList = [];
                        otherInterventionAreaControllers = [];
                      }
                    } else if (label == 'અન્ય સહાય') {
                      for (final item in selected.where((e) => e != 'Other')) {
                        otherHelpQtyControllers.putIfAbsent(
                            item, () => TextEditingController());
                        otherHelpAreaControllers.putIfAbsent(
                            item, () => TextEditingController());
                      }
                      final toRemove = otherHelpQtyControllers.keys
                          .where((k) => !selected.contains(k))
                          .toList();
                      for (final k in toRemove) {
                        otherHelpQtyControllers[k]?.dispose();
                        otherHelpQtyControllers.remove(k);
                      }
                      final toRemoveArea = otherHelpAreaControllers.keys
                          .where((k) => !selected.contains(k))
                          .toList();
                      for (final k in toRemoveArea) {
                        otherHelpAreaControllers[k]?.dispose();
                        otherHelpAreaControllers.remove(k);
                      }
                      if (!selected.contains('Other')) {
                        otherHelpCountController.clear();
                        for (final c in otherHelpNameControllers) {
                          c.dispose();
                        }
                        for (final c in otherHelpQtyControllersList) {
                          c.dispose();
                        }
                        for (final c in otherHelpAreaControllersList) {
                          c.dispose();
                        }
                        otherHelpNameControllers = [];
                        otherHelpQtyControllersList = [];
                        otherHelpAreaControllersList = [];
                      }
                    }
                  });
                }
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                          label: Text(item == 'Other' ? 'અન્ય' : item),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              multiselectValues[label]?.remove(item);
                              if (label == 'હસ્તક્ષેપ') {
                                final c =
                                    interventionQtyControllers.remove(item);
                                c?.dispose();
                                final ca =
                                    interventionAreaControllers.remove(item);
                                ca?.dispose();
                              } else if (label == 'અન્ય સહાય') {
                                final c = otherHelpQtyControllers.remove(item);
                                c?.dispose();
                                final ca =
                                    otherHelpAreaControllers.remove(item);
                                ca?.dispose();
                              }
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

  @override
  void dispose() {
    seedAreaController.dispose();
    otherHelpAreaController.dispose();
    otherInterventionNameController.dispose();
    otherHelpNameController.dispose();
    otherInterventionQtyController.dispose();
    otherHelpQtyController.dispose();
    otherInterventionCountController.dispose();
    otherHelpCountController.dispose();

    for (final c in interventionQtyControllers.values) {
      c.dispose();
    }
    for (final c in interventionAreaControllers.values) {
      c.dispose();
    }
    for (final c in otherHelpQtyControllers.values) {
      c.dispose();
    }
    for (final c in otherHelpAreaControllers.values) {
      c.dispose();
    }
    for (final c in otherInterventionNameControllers) {
      c.dispose();
    }
    for (final c in otherInterventionQtyControllersList) {
      c.dispose();
    }
    for (final c in otherInterventionAreaControllers) {
      c.dispose();
    }
    for (final c in otherHelpNameControllers) {
      c.dispose();
    }
    for (final c in otherHelpQtyControllersList) {
      c.dispose();
    }
    for (final c in otherHelpAreaControllersList) {
      c.dispose();
    }

    super.dispose();
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
              title: Text(item == 'Other' ? 'અન્ય' : item),
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