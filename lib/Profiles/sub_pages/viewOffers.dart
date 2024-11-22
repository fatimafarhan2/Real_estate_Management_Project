import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:real_estate_app/UI/color.dart';
import 'package:real_estate_app/UI/textstyle.dart';


//implement if else bool vaibale to check when to select all agents or when to select agents associated with a specific user
class ViewOffers extends StatelessWidget {
 ViewOffers({super.key});
 final List<Map<String, String>> offers = [
    {
      'Property Name': 'Sage Villa',
      'Buyer Name': '[Name]',
      'Offer Creation Date': '2024-11-09',
      'Seller Name' : "[Name]",
    },
    {
      'Property Name': 'Sage Condo',
      'Buyer Name': '[Name]',
      'Offer Creation Date': '2021-11-09',
      'Seller Name' : "[Name]",
    },
    {
      'Property Name': 'Sage Apartments',
      'Buyer Name': '[Name]',
      'Offer Creation Date': '2024-11-19',
      'Seller Name' : "[Name]",
    },
    {
      'Property Name': 'Sage Villa',
      'Buyer Name': '[Name]',
      'Offer Creation Date': '2024-11-09',
      'Seller Name' : "[Name]",
    },
    {
      'Property Name': 'Sage Condo',
      'Buyer Name': '[Name]',
      'Offer Creation Date': '2021-11-09',
      'Seller Name' : "[Name]",
    },
    {
      'Property Name': 'Sage Apartments',
      'Buyer Name': '[Name]',
      'Offer Creation Date': '2024-11-19',
      'Seller Name' : "[Name]",
    },
   {
      'Property Name': 'Sage Villa',
      'Buyer Name': '[Name]',
      'Offer Creation Date': '2024-11-09',
      'Seller Name' : "[Name]",
    },
    {
      'Property Name': 'Sage Condo',
      'Buyer Name': '[Name]',
      'Offer Creation Date': '2021-11-09',
      'Seller Name' : "[Name]",
    },
    {
      'Property Name': 'Sage Apartments',
      'Buyer Name': '[Name]',
      'Offer Creation Date': '2024-11-19',
      'Seller Name' : "[Name]",
    },
    {
      'Property Name': 'Sage Villa',
      'Buyer Name': '[Name]',
      'Offer Creation Date': '2024-11-09',
      'Seller Name' : "[Name]",
    },
    {
      'Property Name': 'Sage Condo',
      'Buyer Name': '[Name]',
      'Offer Creation Date': '2021-11-09',
      'Seller Name' : "[Name]",
    },
    {
      'Property Name': 'Sage Apartments',
      'Buyer Name': '[Name]',
      'Offer Creation Date': '2024-11-19',
      'Seller Name' : "[Name]",
    }, 
  ];

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          title: const Text('View Offers', 
          style: tappbar_style,),
          backgroundColor: buttonColor,
        ),
        backgroundColor: propertyBGColor,

      body: offers.isEmpty
            ? const Center(child: const Text('No Offers Recieved...'))
            : ListView.builder(
              itemCount: offers.length,
              itemBuilder: (context, index){
                final offer = offers[index];
                return Padding(
                  padding:  const EdgeInsets.all(6.0),
                  child: Slidable(
                    key: ValueKey(index),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(), 
                    children: [
                      SlidableAction(onPressed: (context)
                      {
                        //will add db functiionality
                      },
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                      icon: Icons.view_carousel,
                      label: 'View Offer',
                      
                      )
                    ]),
                    child: Card(
                      elevation: 3,
                      child: ListTile(
                        title: Text('Poperty Name: ${offer['Property Name'] ?? ''}',
                        style: tAppointmentBody,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [ Text(
                              'Buyer Name: ${offer['Buyer Name'] ?? 'Anonymous'}',
                              style: tUserBody,
                            ),
                            Text(
                              'Seller Name: ${offer['Seller Name'] ?? ''}',
                              style: tUserBody,
                            ),
                            Text(
                              'Date: ${offer['Offer Creation Date'] ?? ''}',
                              style: tUserBody,
                            ),
                            ],
                        ),
                        leading: const Icon(Icons.dashboard_customize, color: Colors.green,),
                      ),
                    )
                    ),
                  );
              },
            )
            ,

    );
  }
}  