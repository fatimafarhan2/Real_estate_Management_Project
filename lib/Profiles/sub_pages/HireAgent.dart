// ignore: file_names
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:real_estate_app/UI/color.dart';
import 'package:real_estate_app/UI/textstyle.dart';

class Hireagent extends StatelessWidget {
  const Hireagent({super.key});
final int numOfAgents = 15;//will be taken from database
final double ratingFromDb = 3.5;

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Hire An Agent',
        style: tappbar_style,
        ),
      ),

        body:  SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
                 children: [
          for(int i=0;i<numOfAgents;i++)
            Padding(padding: EdgeInsets.all(18.0),
            child: Container(
              width: 370,
              height: 90,
              decoration: BoxDecoration(
                color: boxcolor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: buttonColor,
                  width: 5,
                ),
              ),
              
              child: Column(
                
                children: [
                  Row(
                    
                    children: [
                      const Text('  [Name]:', 
                      style: tUserTitle,),
                      const SizedBox(width:10),
                      const Text('[PhoneNumber] ', 
                      style: TextStyle(color: Color.fromARGB(255, 227, 246, 208),fontSize: 19,
                      fontWeight: FontWeight.w600),
                      ),
                  
                      const SizedBox(width:23),
                  
                      ElevatedButton.icon(onPressed: (){},
                        label: const Text('View', style: tappbar_style,),
                        style: ElevatedButton.styleFrom(
                          iconColor: buttonColor,
                          backgroundColor: buttonColor,
                        ),
                                   ),
                               
                    ],
                  ),
                  
                        RatingBar(
                          initialRating: ratingFromDb, //will be updated thro database
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 30,
                          ignoreGestures: true,
                          updateOnDrag: true,
                          ratingWidget: RatingWidget(
                            full:  const Icon(
                                  Icons.star, // Full icon
                                  color: Color.fromARGB(255, 243, 201, 75),
                                ),
                           half: const Icon(
                                  Icons.star_half, // Half icon
                                      color: Color.fromARGB(255, 243, 201, 75),
                                    ),
                           empty: const Icon(
                                  Icons.star_border, // Empty icon
                                  color: Color.fromARGB(255, 71, 85, 50), // Different color for empty
                                ),
                           ),
                                maxRating: 5,
                                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),                        
                                  onRatingUpdate: (rating){
                                          
                                  }
                                  )
                ],  
              ),



            ), 
            
            ),
          

            


                 ],
          ),
        ),
    );
  }
}