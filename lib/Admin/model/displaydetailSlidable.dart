import 'package:flutter/material.dart';
import 'package:real_estate_app/Admin/model/acceptrejectcard.dart';
import 'package:real_estate_app/Admin/model/slidablecard.dart';
import 'package:real_estate_app/UI/color.dart';
import 'package:real_estate_app/UI/textstyle.dart';

class DisplayDetailsSlidable extends StatelessWidget {
  DisplayDetailsSlidable({
    Key? key,
    required this.emptyBodyText,
    required this.appBarTitle,
    required this.showAllItems,
    required this.items, // Generic data list
    required this.fieldLabels, // Labels for each field
    required this.fieldKeys, // Keys for each field in data
    required this.isLoading,
    required this.label,
    required this.role,
  }) : super(key: key);

  final String label;
  final String role;
  final String emptyBodyText;
  final String appBarTitle;
  final bool showAllItems;
  final List<Map<String, dynamic>> items;
  final List<String>
      fieldLabels; // Ex: ['First Name', 'Last Name', 'Phone', 'Email']
  final List<String> fieldKeys; // Ex: ['f_name', 'l_name', 'phone', 'email']
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    // For each item in the items list, check if the value of the key 'filterKey' is equal to 'filterValue'."
    final filteredItems = showAllItems
        ? items
        : items.where((item) => item['filterKey'] == 'filterValue').toList();

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: scaffoldColor),
        title: Center(
          child: Text(
            appBarTitle,
            style: tappbar_style,
          ),
        ),
        backgroundColor: buttonColor,
      ),
      backgroundColor: propertyBGColor,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : filteredItems.isEmpty
              ? Center(child: Text(emptyBodyText))
              : ListViewCardSlidable(
                  items: items,
                  role: role,
                  label: label,
                  filteredItems: filteredItems,
                  fieldLabels: fieldLabels,
                  fieldKeys: fieldKeys,
                ),
    );
  }
}
