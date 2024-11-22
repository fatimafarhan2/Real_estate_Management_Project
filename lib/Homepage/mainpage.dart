import 'package:flutter/material.dart';
import 'package:real_estate_app/UI/color.dart';
import 'package:real_estate_app/UI/textstyle.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();
  final SupabaseClient client = Supabase.instance.client;

  // Variables to filter by
  String? selcity;
  String? selcategory;
  double minprice = 0.0;
  double maxprice = 500000000.0;
  double? selsize;
  String? selname;

  List<Map<String, dynamic>> filteredProperties = [];
  List<Map<String, dynamic>> allProperties = [];
  List<DropdownMenuItem<String>> allCategories = [];
  List<DropdownMenuItem<String>> allCities = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    // Fetch all properties, categories, and cities asynchronously
    List<Map<String, dynamic>> properties = await fetchAllProperties();
    List<Map<String, dynamic>> categories = await fetchAllCategories();
    List<String> cities = await fetchDistinctCities();

    setState(() {
      allProperties = properties;
      filteredProperties = allProperties;
      allCategories = categories
          .map((category) => DropdownMenuItem<String>(
                value: category['category_name'],
                child: Text(category['category_name']),
              ))
          .toList();

      allCities = cities
          .map((city) => DropdownMenuItem<String>(
                value: city,
                child: Text(city),
              ))
          .toList();
    });
  }

  Future<List<Map<String, dynamic>>> fetchAllProperties() async {
    try {
      final response = await client.from('properties').select('*');
      if (response.isEmpty) {
        print('No data returned from the database');
        return [];
      }
      print('Data fetched successfully: $response');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Unexpected error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllCategories() async {
    try {
      final response =
          await client.from('property_category').select('category_name');
      if (response.isEmpty) {
        print('No data returned from the database');
        return [];
      }
      print('Categories fetched successfully: $response');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Unexpected error: $e');
      return [];
    }
  }

  Future<List<String>> fetchDistinctCities() async {
    try {
      final response = await client.rpc('get_distinctcities');
      // print(response);
      if (response.isEmpty) {
        print('No distinct cities found.');
        return [];
      }
      List<String> cities = List<String>.from(response);

      print(cities);
      print('Distinct cities fetched successfully: $cities');
      return cities;
    } catch (e) {
      print('Unexpected error: $e');
      return [];
    }
  }

  void filterProperties() async {
    try {
      // Parsing the input values safely
      minprice = minPriceController.text.isNotEmpty
          ? double.parse(minPriceController.text)
          : 0.0;
      maxprice = maxPriceController.text.isNotEmpty
          ? double.parse(maxPriceController.text)
          : 500000000.0;
      selsize = sizeController.text.isNotEmpty
          ? double.parse(sizeController.text)
          : null;
      selname = nameController.text.isNotEmpty ? nameController.text : null;

      // Fetching filtered properties using the Supabase RPC function
      final response = await client.rpc('get_filtered_properties', params: {
        'selcategoryid': selCategoryid,
        'selcity': selcity,
        'maxprice': maxprice,
        'minprice': minprice,
        'selsize': selsize,
        'selname': selname
      });

      if (response != null && response.isNotEmpty) {
        setState(() {
          filteredProperties = List<Map<String, dynamic>>.from(response);
        });
      } else {
        setState(() {
          filteredProperties = [];
        });
      }
    } catch (e) {
      print('Error filtering properties: $e');
    }
  }

  int? selCategoryid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Text(
          'Real Estate Management',
          style: tappbar_style,
        )),
      ),
      backgroundColor: scaffoldColor,
      drawer: Drawer(
          child: ListView(
        padding: const EdgeInsets.all(0.0),
        children: [
          DrawerHeader(
            child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 166, 175, 81),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                height: 20,
                width: 200,
                child: const Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Center(
                    child: Text(
                      'Filter Properties',
                      style: tDrawerHeading,
                    ),
                  ),
                )),
          ),

          const Padding(
            padding: EdgeInsets.all(15.0),
            child: Text('Select Property Category', style: tDrawerBody),
          ),

          ListTile(
            title: DropdownButtonFormField<String>(
              value: selcategory,
              hint: Text('Select Category'),
              onChanged: (value) {
                // Update the selected category within setState
                setState(() {
                  selcategory = value;
                  print("Selected category: $selcategory");
                });

                // Perform the async RPC call to get category ID outside setState
                () async {
                  try {
                    selCategoryid = await client.rpc('get_category_id',
                        params: {'selcategory': selcategory});
                    print("Selected category ID: $selCategoryid");
                  } catch (error) {
                    print("Failed to fetch category ID: $error");
                  }
                }();
              },
              items: allCategories,
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          //Range Slider
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text('Select Price Range', style: tDrawerBody),
          ),
          ListTile(
            title: TextField(
              controller: minPriceController,
              decoration: InputDecoration(
                  labelText: 'Minimum Price',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  )),
            ),
          ),

          ListTile(
            title: TextField(
              controller: maxPriceController,
              decoration: InputDecoration(
                  labelText: 'Maximum Price',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  )),
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text('Select City', style: tDrawerBody),
          ),
          //CITY SELECTED

          ListTile(
            title: DropdownButtonFormField<String>(
              value: selcity,
              hint: const Text('Select City'),
              onChanged: (value) {
                setState(() {
                  selcity = value;
                });
              },
              items:
                  allCities, // This should directly reference the 'allCategories' list
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              dropdownColor: drawerBoxColor,
            ),
          ),
          //Size Filter

          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text('Select Minimum Area', style: tDrawerBody),
          ),
          //CITY SELECTED
          ListTile(
            title: TextField(
              controller: sizeController,
              decoration: InputDecoration(
                  labelText: 'Area',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  )),
            ),
          ),

          Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: drawerBoxColor,
                ),
                onPressed: () {
                  filterProperties();
                  Navigator.of(context).pop();
                },
                child: const Text('Apply Filters', style: tDrawerButton),
              ))
        ],
      )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                hintText: 'Search Property by name...',
                prefixIcon: const Icon(Icons.search),
                prefixIconColor: Colors.lightGreen,
              ),
              onChanged: (value) {
                filterProperties();
              },
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: filteredProperties.length,
                  itemBuilder: (context, index) {
                    var property = filteredProperties[index];
                    return Card(
                      color: drawerBoxColor,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(17.0),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: Image.asset(
                                  'images/property1.jpeg',
                                  width: 500,
                                  height: 200,
                                )),
                          ),
                          ListTile(
                            title: Text(
                              property['title'],
                              style: tAppointmentBody,
                            ),
                            subtitle: Text(
                              'Category: ${property['category_id']}, \nCity: ${property['city']}',
                              style: tUserBody,
                            ),
                            trailing: Text(
                              '\$${property['price']}',
                              style: tUserBody,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
