import 'package:flutter/material.dart';
import 'package:real_estate_app/Admin/model/acceptrejectcard.dart';
import 'package:real_estate_app/UI/color.dart';
import 'package:real_estate_app/UI/textstyle.dart';

class DisplayDetails extends StatelessWidget {
  DisplayDetails({
    Key? key,
    required this.emptyBodyText,
    required this.appBarTitle,
    required this.showAllItems,
    required this.items, // Generic data list
    required this.fieldLabels, // Labels for each field
    required this.fieldKeys, // Keys for each field in data
    required this.isLoading,
  }) : super(key: key);

  final String emptyBodyText;
  final bool showAllItems;
  final List<Map<String, dynamic>> items;
  final List<String>
      fieldLabels; // Ex: ['First Name', 'Last Name', 'Phone', 'Email']
  final List<String> fieldKeys; // Ex: ['f_name', 'l_name', 'phone', 'email']

  final bool isLoading;

  final String appBarTitle;
  @override
  Widget build(BuildContext context) {
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
              : ListViewCard(
                  filteredItems: filteredItems,
                  fieldLabels: fieldLabels,
                  fieldKeys: fieldKeys,
                ),
    );
  }
}
