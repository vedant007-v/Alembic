import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddFarmExpenseScreen extends StatefulWidget {
  final String rationCardNo;
  const AddFarmExpenseScreen({super.key, required this.rationCardNo});

  @override
  State<AddFarmExpenseScreen> createState() => _AddFarmExpenseScreenState();
}

class _AddFarmExpenseScreenState extends State<AddFarmExpenseScreen> with TickerProviderStateMixin {
  final firestore = FirebaseFirestore.instance.collection('farm_expenses');
  final farmersCollection = FirebaseFirestore.instance.collection('farmer_details');

  // Add these variables
  List<String> farmerNames = [];
  String? selectedFarmerName;
  // Animation controller
   bool isLoadingFarmers = true; // Track loading state
  late AnimationController _controller;
  late Animation<double> _animation;

  // English field names mapping
  final Map<String, String> fieldKeys = {
    'પાકનો વાવેતર વિસ્તાર (વીઘા)': 'cultivation_area',
    'શું વાવણી પહેલા જમીન તૈયાર કરી હતી?': 'land_preparation_before_planting',
    'જમીન તૈયારી ખર્ચ': 'land_preparation_cost',
    'બિયારણ/છોડનો ખર્ચ': 'seed_cost',
    'પ્રત્યારોપણ ખર્ચ': 'transplant_cost',
    'ડી.એ.પી. (કિલોગ્રામમાં)': 'dap_quantity',
    'ડી.એ.પી. ખર્ચ': 'dap_cost',
    'યૂરિયા (કિલોગ્રામમાં)': 'urea_quantity',
    'યૂરિયા ખર્ચ': 'urea_cost',
    'SSP (કિલોગ્રામમાં)': 'ssp_quantity',
    'SSP ખર્ચ': 'ssp_cost',
    'NPK (કિલોગ્રામમાં)': 'npk_quantity',
    'NPK ખર્ચ': 'npk_cost',
    'જૈવિક ખાતર (કિલોગ્રામમાં)': 'bio_fertilizer_quantity',
    'જૈવિક ખાતર ખર્ચ': 'bio_fertilizer_cost',
    'નીંદણ દવા છાંટવા નો ખર્ચ': 'weedicides_cost',
    'રોગનું નામ': 'diseases',
    'જीવાત/કીડાનું નામ': 'pests',
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
    'Monsoon_other': 'monsoon_other',
    'Winter_other': 'winter_other',
    'Summer_other': 'summer_other',
    'રોગનું નામ_other': 'diseases_other',
    'જીવાત/કીડાનું નામ_other': 'pests_other',
    'Name of Edible/non edible crop_other': 'edible_other',
    'Name of Vegetable crop for all season_other': 'vegetable_other',
    'Name of Horticulture for all season_other': 'horticulture_other',
  };

  // Calculated fields mapping
  final Map<String, String> calculatedKeys = {
    'કુલ આવક': 'total_income',
    'કુલ ખર્ચ': 'total_expense',
    'નિકાળ આવક': 'net_income',
  };

  final Map<String, String> labelTypes = {
    'કુલ જ્મીન પોતાની મલિકીની (વીઘા)': 'number',
    'ભાડાપેદે  લીઘી લી  જમીન  (વીઘા)': 'number',
    'શું વાવણી પહેલા જમીન તૈયાર કરી હતી?': 'dropdown_yesno',
    'જમીન તૈયારી ખર્ચ': 'number',
    // 'શું તમે ખાતર/છાણ/અન્ય બાયો ખાતર વાપર્યું?': 'dropdown_yesno',
    // 'કુલ ટન (છાણ/બાયો ખાતર)': 'number',
    // 'કુલ છાણ/બાયો ખાતર ખર્ચ': 'number',
    'બિયારણ/છોડનો ખર્ચ': 'number',
    'વાવણી ખર્ચ': 'number',
    'નીંદણ દવા છાંટવા નો ખર્ચ': 'number',
    'રોગનું નામ': 'multiselect',
    'જીવાત/કીડાનું નામ': 'multiselect',
    'રોગ નિયંત્રણ  ખર્ચ': 'number',
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
    'Monsoon_other': 'text',
    'Winter_other': 'text',
    'Summer_other': 'text',
    'રોગનું નામ_other': 'text',
    'જીવાત/કીડાનું નામ_other': 'text',
    'Name of Edible/non edible crop_other': 'text',
    'Name of Vegetable crop for all season_other': 'text',
    'Name of Horticulture for all season_other': 'text',
  };

  final List<String> expenseFields = [
    'જમીન તૈયારી ખર્ચ',
    'બિયારણ/છોડનો ખર્ચ',
    'કુલ છાણ/બાયો ખાતર ખર્ચ',
    'પ્રત્યારોપણ ખર્ચ',
    'ડી.એ.પી. ખર્ચ',
    'યૂરિયા ખર્ચ',
    'SSP ખર્ચ',
    'NPK ખર્ચ',
    'જૈવિક ખાતર ખર્ચ',
    'નીંદણ દવા છાંટવા નો ખર્ચ',
    'રોગ नियंत्रण ખर्च',
    'કુલ પિયત ખર્ચ',
    'જંતુનાશક દવા ખર્ચ',
    'પાકની લણણી ખર્ચ',
    'કુલ મજૂરી ખર્ચ',
    'અન્ય કોઈપણ ખર્ચ',
  ];

  final List<String> diseases = [
    "Balya Tapka Rog",
    "Danani Moj",
    "Danano Gariyo",
    "Dagarna Zhaka Dana no Rog",
    "Dhlo Gariyo",
    "Doshi Rog",
    "Dhumra Rog",
    "Galatyo",
    "Jhal Rog",
    "Kadjano Sado",
    "Kala Dana",
    "Kalvan",
    "Kalo Sado",
    "Kand ane Luno Sado",
    "Kantalyo Rog",
    "Karmod",
    "Kajal Sado",
    "Kokadva",
    "Kunval Rog",
    "Lila Valno Rog",
    "Loo Sado Rog",
    "Paanna Badami Tapka",
    "Paanna Rog",
    "Paanna Tapka",
    "Pachhotalo Kuvaro",
    "Panno Jhal",
    "Pilo Pachrangayo",
    "Pocho Sado",
    "Safed Geru",
    "Tapka Rog",
    "Tapka Tadtadiya",
    "Talchhalo",
    "Taracharo",
    "Ukheda Rog",
    "Vangiyo Rog",
    "other"
  ];

  final List<String> pests = [
    "Dagarna Suiya",
    "Dagarno Dar",
    "Duma ni Iyal",
    "Gabhamarani Iyal",
    "Ghoda ni Iyal",
    "Gidar Jev",
    "Katra",
    "Khor Ukhanar Iyal",
    "Lakad Iyal",
    "Mealy Bug",
    "Ruan Kasiya",
    "Santhani Makhi",
    "Safed Makhi",
    "Shing Makhi",
    "Shinglawali Iyal",
    "Suiya",
    "other"
  ];

  final List<String> fertilizers = [
    'ડી.એ.પી',
    'યૂરિયા',
    'SSP',
    'NPK',
    'જૈવિક ખાતર'
  ];

  final Map<String, TextEditingController> controllers = {};
  final Map<String, String?> dropdownValues = {};
  final Map<String, List<String>> multiselectValues = {};

  String? selectedSeason;
  String? selectedSeedType;
  String? selectedSeed;
  List<String> selectedFertilizers = [];

  final Map<String, List<String>> seasonWiseEdible = {
    'Monsoon': [
      'Castor',
      'Cotton',
      'Fodder',
      'Great Millet',
      'Maize',
      'Moth Beans',
      'Paddy',
      'Seasme',
      'Soyabean',
      'Sweet Corn',
      'Other'
    ],
    'Winter': [
      'Wheat',
      'Maize',
      'Gram',
      'Mustard',
      'Fennel',
      'Fodder',
      'fennel',
      'Other'
    ],
    'Summer': [
      'Pearl Millet',
      'seasme',
      'Black Gram',
      'Green Gram',
      'Paddy',
      'Fodder',
      'Other'
    ],
  };

  final List<String> vegetables = [
    'Bitter Gourd',
    'Bottle Gourd',
    'Brinjal',
    'Cabbage',
    'Cauliflower',
    'Cluster Bean',
    'Cucumber',
    'Drumstick',
    'Fenugreek leaf',
    'Green Bean',
    'Green Chili',
    'Lady finger',
    'Luffa Gourd',
    'Pumpkin',
    'Radish',
    'Spinach leaf',
    'Spiny Gourd',
    'Sweet potato',
    'Tomato',
    'Turmeric',
    'Onion',
    'Other'
  ];

  final List<String> horticulture = [
    'Mango',
    'Guava',
    'Lemon',
    'Flowers',
    'Sapota',
    'Custard Apple',
    'Other'
  ];

 // --- Text field listener
  void _onTextChanged() {
    if (!mounted) return; // only update if widget is alive
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    // Animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Async fetch with mounted check
    _fetchFarmerNames();

    // Initialize controllers
    for (var label in labelTypes.keys) {
      if (labelTypes[label] == 'text' || labelTypes[label] == 'number') {
        final ctrl = TextEditingController();
        ctrl.addListener(_onTextChanged);
        controllers[label] = ctrl;
      } else if (labelTypes[label] == 'dropdown_yesno') {
        dropdownValues[label] = 'No';
      } else if (labelTypes[label] == 'multiselect') {
        multiselectValues[label] = [];
      }
    }
  }

bool _isControllerDisposed = false;

@override
void dispose() {
  for (var controller in controllers.values) {
    controller.removeListener(_onTextChanged); // ✅ remove safely
    controller.dispose();
  }
  controllers.clear();

  if (_controller != null && _controller.isAnimating) {
    _controller.stop();
  }
  if (!_isControllerDisposed) {
    _controller.dispose();
    _isControllerDisposed = true;
  }

  super.dispose();
}







    // Fetch farmer names based on ration card number
Future<void> _fetchFarmerNames() async {
  if (!mounted) return; // ✅ make sure widget is alive before starting
  setState(() => isLoadingFarmers = true);

  try {
    QuerySnapshot querySnapshot = await farmersCollection
        .where('rationCard', isEqualTo: widget.rationCardNo)
        .get();

    // Extract names
    final names = querySnapshot.docs
        .map((doc) => doc['farmerName']?.toString())
        .where((name) => name != null && name.isNotEmpty)
        .cast<String>()
        .toList();

    if (!mounted) return; // ✅ check again after async work
    setState(() {
      farmerNames = names;
      if (farmerNames.isNotEmpty) {
        selectedFarmerName = farmerNames.first;
      }
      isLoadingFarmers = false;
    });
  } catch (e) {
    print('Error fetching farmer names: $e');
    if (!mounted) return; // ✅ safe check
    setState(() => isLoadingFarmers = false);
  }
}


  List<String> getAvailableSeeds() {
    if (selectedSeedType == null) return [];
    if (selectedSeedType == 'Name of Edible/non edible crop') {
      return selectedSeason != null
          ? seasonWiseEdible[selectedSeason!] ?? []
          : [];
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
        onChanged: (value) {
          setState(() {}); // Update UI when value changes
        },
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
        onChanged: (value) {
          setState(() {}); // Update UI when value changes
        },
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

                    // Special handling for fertilizers
                    if (label == 'ખાતરનો પ્રકાર') {
                      selectedFertilizers = selected;
                    }
                  });
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedItems.isEmpty ? 'Select' : selectedItems.join(', '),
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
                children: selectedItems
                    .map((item) => Chip(
                          label: Text(item),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              multiselectValues[label]!.remove(item);

                              // Special handling for fertilizers
                              if (label == 'ખાતરનો પ્રકાર') {
                                selectedFertilizers.remove(item);
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
    final production = double.tryParse(
            controllers['કુલ ઉત્પાદન (પ્રતિ મણ)']?.text.trim() ?? '') ??
        0.0;
    final rate = double.tryParse(
            controllers['વેચાણ ભાવ (પ્રતિ મણ)']?.text.trim() ?? '') ??
        0.0;
    return production * rate;
  }

  double calculateNetIncome(double totalExpense, double totalIncome) {
    final otherProduct = double.tryParse(
            controllers['અન્ય ઉત્પાદનની કુલ કિંમત']?.text.trim() ?? '') ??
        0.0;
    return totalIncome + otherProduct - totalExpense;
  }

  // Widget to display calculated financial metrics
  Widget buildFinancialSummary() {
    final totalExpense = calculateTotalExpense();
    final totalIncome = calculateTotalIncome();
    final netIncome = calculateNetIncome(totalExpense, totalIncome);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'આર્થિક સારાંશ',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('કુલ આવક:', style: TextStyle(fontSize: 16)),
                Text('₹${totalIncome.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('કુલ ખર્ચ:', style: TextStyle(fontSize: 16)),
                Text('₹${totalExpense.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Divider(thickness: 1, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('નિકાળ આવક:',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('₹${netIncome.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: netIncome >= 0 ? Colors.green : Colors.red)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> availableSeeds = getAvailableSeeds();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ખેડૂતના પાકની વિગતો ઉમેરો',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
         leading: IconButton(
        icon: const Icon(Icons.arrow_back), // back arrow
      onPressed: () {
        // 👇 Your custom action here
        // Example: navigate to another screen or show a dialog
        Navigator.pop(context);
      },
    ),
      ),
      body: isLoadingFarmers
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Option 1: Lottie animation (requires lottie package)
                  // Lottie.asset(
                  //   'assets/animations/farming_animation.json',
                  //   width: 200,
                  //   height: 200,
                  //   fit: BoxFit.fill,
                  // ),
                  
                  // Option 2: Custom animated farmer illustration
                  ScaleTransition(
                    scale: _animation,
                    child: const Icon(
                      Icons.agriculture,
                      size: 80,
                      color: Colors.teal,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Pulsating text animation
                  FadeTransition(
                    opacity: _animation,
                    child: const Text(
                      'ખેડૂતની માહિતી લોડ કરી રહ્યા છીએ...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Animated progress indicator
                  SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (farmerNames.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'ખેડૂતનું નામ પસંદ કરો',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  value: selectedFarmerName,
                  items: farmerNames.map((String name) {
                    return DropdownMenuItem<String>(
                      value: name,
                      child: Text(name),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedFarmerName = newValue;
                    });
                  },
                ),
              ),
            if (farmerNames.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text('કોઈ ખેડૂત મળ્યો નથી',
                    style: TextStyle(color: Colors.red)),
              ),

            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'ઋતુ પસંદ કરો',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              value: selectedSeason,
              items: ['Monsoon', 'Winter', 'Summer', 'Other'].map((season) {
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

            if (selectedSeason == 'Other') buildTextField('Monsoon_other'),

            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'પાક પ્રકાર પસંદ કરો',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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

            if (selectedSeed == 'Other')
              buildTextField('${selectedSeedType}_other'),

            // Fertilizer multiselect
            buildMultiselectField('ખાતરનો પ્રકાર', fertilizers),

            // Conditionally show fertilizer fields based on selection
            if (selectedFertilizers.contains('ડી.એ.પી')) ...[
              buildNumberField('ડી.એ.પી. (કિલોગ્રામમાં)'),
              buildNumberField('ડી.એ.પી. ખર્ચ'),
            ],

            if (selectedFertilizers.contains('યૂરિયા')) ...[
              buildNumberField('યૂરિયા (કિલોગ્રામમાં)'),
              buildNumberField('યૂરિયા ખર્ચ'),
            ],

            if (selectedFertilizers.contains('SSP')) ...[
              buildNumberField('SSP (કિલોગ્રામમાં)'),
              buildNumberField('SSP ખર્ચ'),
            ],

            if (selectedFertilizers.contains('NPK')) ...[
              buildNumberField('NPK (કિલોગ્રામમાં)'),
              buildNumberField('NPK ખર્ચ'),
            ],

            if (selectedFertilizers.contains('જૈવિક ખાતર')) ...[
              buildNumberField('જૈવિક ખાતર (કિલોગ્રામમાં)'),
              buildNumberField('જૈવિક ખાતર ખર્ચ'),
            ],

            ...labelTypes.entries.map((entry) {
              final label = entry.key;
              final type = entry.value;

              // Skip fields that are already handled above
              if (label.startsWith('ડી.એ.પી') ||
                  label.startsWith('યૂરિયા') ||
                  label.startsWith('SSP') ||
                  label.startsWith('NPK') ||
                  label.startsWith('જૈવિક ખાતર') ||
                  label.endsWith('_other')) {
                return const SizedBox();
              }

              if (label == 'કુલ ટન (છાણ/બાયો ખાતર)' ||
                  label == 'કુલ છાણ/બાયો ખાતર ખર્ચ') {
                if (dropdownValues[
                        'શું તમે ખાતર/છાણ/અન્ય બાયો ખાતર વાપર્યું?'] !=
                    'Yes') {
                  return const SizedBox();
                }
              }
              if (label == 'જમીન તૈયારી ખર્ચ') {
                if (dropdownValues['શું વાવણી પહેલા જમીન તૈયાર કરી હતી?'] !=
                    'Yes') {
                  return const SizedBox();
                }
              }

              // Show vegetable_count only if vegetable crop is selected
              if (label == 'શાકભાજી ની સંખ્યા' &&
                  selectedSeedType != 'Name of Vegetable crop for all season') {
                return const SizedBox();
              }

              if (type == 'number') return buildNumberField(label);
              if (type == 'text') return buildTextField(label);
              if (type == 'dropdown_yesno') return buildDropdownYesNo(label);
              if (type == 'multiselect') {
                if (label == 'રોગનું નામ') {
                  return buildMultiselectField(label, diseases);
                } else if (label == 'જીવાત/કીડાનું નામ') {
                  return buildMultiselectField(label, pests);
                }
              }

              return const SizedBox();
            }),

            // Show other fields for multiselect if "other" is selected
            if (multiselectValues['રોગનું નામ']?.contains('other') ?? false)
              buildTextField('રોગનું નામ_other'),

            if (multiselectValues['જીવાત/કીડાનું નામ']?.contains('other') ??
                false)
              buildTextField('જીવાત/કીડાનું નામ_other'),

            // Display financial summary
            buildFinancialSummary(),

            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: () async {
                   if (selectedFarmerName == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("ખેડૂતનું નામ પસંદ કરો")),
                    );
                    return;
                  }
                  if (selectedSeason == null ||
                      selectedSeedType == null ||
                      selectedSeed == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("મોસમ, પાક પ્રકાર અને પાક પસંદ કરો")),
                    );
                    return;
                  }

                  Map<String, dynamic> data = {
                    'farmer_name': selectedFarmerName,
                    'ration_card_no': widget.rationCardNo,
                    'season': selectedSeason,
                    'crop_type': selectedSeedType,
                    'crop': selectedSeed,
                    'timestamp': FieldValue.serverTimestamp(),
                    'fertilizers_used': selectedFertilizers,
                  };

                  bool isValid = true;

                  // Process all fields
                  for (var label in labelTypes.keys) {
                    final type = labelTypes[label];
                    final englishKey = fieldKeys[label];

                    if (englishKey == null) continue;

                    // Skip conditional fields that shouldn't be shown
                    if ((label == 'કુલ ટન (છાણ/બાયો ખાતર)' ||
                            label == 'કુલ છાણ/બાયો ખાતર ખર્ચ') &&
                        dropdownValues[
                                'શું તમે ખાતર/છાણ/અન્ય બાયો ખાતર વાપર્યું?'] !=
                            'Yes') {
                      continue;
                    }
                    if (label == 'જમીન તૈયારી ખર્ચ' &&
                        dropdownValues['શું વાવણી પહેલા જમીન તૈયાર કરી હતી?'] !=
                            'Yes') {
                      continue;
                    }
                    if (label == 'શાકભાજી ની સંખ્યા' &&
                        selectedSeedType !=
                            'Name of Vegetable crop for all season') {
                      continue;
                    }

                    if (type == 'text' || type == 'number') {
                      String value = controllers[label]!.text.trim();
                      if (value.isEmpty && !label.endsWith('_other')) {
                        isValid = false;
                        break;
                      }
                      if (value.isNotEmpty) {
                        data[englishKey] = type == 'number'
                            ? double.tryParse(value) ?? 0.0
                            : value;
                      }
                    } else if (type == 'dropdown_yesno') {
                      data[englishKey] = dropdownValues[label];
                    } else if (type == 'multiselect') {
                      data[englishKey] = multiselectValues[label];
                    }
                  }

                  if (isValid) {
                    // Calculate and store financial metrics
                    final totalExpense = calculateTotalExpense();
                    final totalIncome = calculateTotalIncome();
                    final netIncome =
                        calculateNetIncome(totalExpense, totalIncome);

                    data[calculatedKeys['કુલ આવક']!] = totalIncome;
                    data[calculatedKeys['કુલ ખર્ચ']!] = totalExpense;
                    data[calculatedKeys['નિકાળ આવક']!] = netIncome;

                    String id =
                        DateTime.now().millisecondsSinceEpoch.toString();
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
                      selectedFertilizers = [];
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("માહિતી સફળતાપૂર્વક સાચવાઈ")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("બધી માહિતી ભરો")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Save",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
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
