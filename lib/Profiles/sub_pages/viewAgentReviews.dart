import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:real_estate_app/UI/color.dart';
import 'package:real_estate_app/UI/textstyle.dart';


//implement if else bool vaibale to check when to select all agents or when to select agents associated with a specific user

class ViewAgentReviews extends StatelessWidget {
 ViewAgentReviews({super.key});
 final List<Map<String, String>> comments = [
    {
      'author': 'John Doe',
      'content': 'This is a great post! Really enjoyed it.',
      'created_at': '2024-11-09'
    },
    {
      'author': 'Jane Smith',
      'content': 'Interesting perspective, thanks for sharing.',
      'created_at': '2024-11-08'
    },
    {
      'author': 'Alice Johnson',
      'content': 'I found this very helpful, looking forward to more updates.',
      'created_at': '2024-11-07'
    },
    {
      'author': 'Bob Brown',
      'content': 'I disagree with your point on...',
      'created_at': '2024-11-06'
    },
    {
      'author': 'John Doe',
      'content': 'This is a great post! Really enjoyed it.',
      'created_at': '2024-11-09'
    },
    {
      'author': 'Jane Smith',
      'content': 'Interesting perspective, thanks for sharing.',
      'created_at': '2024-11-08'
    },
    {
      'author': 'Alice Johnson',
      'content': 'I found this very helpful, looking forward to more updates.',
      'created_at': '2024-11-07'
    },
    {
      'author': 'Bob Brown',
      'content': 'I disagree with your point on...',
      'created_at': '2024-11-06'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          title: const Center(
            child:  Text('View Agent Reviews', 
            style: tappbar_style,),
          ),
          backgroundColor: buttonColor,
        ),
        backgroundColor: propertyBGColor,

      body: comments.isEmpty
            ? const Center(child: const Text('No comments on Property'))
            : ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index){
                final comment = comments[index];
                return Padding(
                  padding:  const EdgeInsets.all(6.0),
                  child: Slidable(
                    key: ValueKey(index),
                    
                    child: Card(
                      elevation: 3,
                      child: ListTile(
                        title: Text(comment['content']?? '',
                        style: tUserBody,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [ Text(
                              'By: ${comment['author'] ?? 'Anonymous'}',
                              style: tUserBody,
                            ),
                            Text(
                              'Date: ${comment['created_at'] ?? ''}',
                              style: tUserBody,
                            ),
                            ],
                        ),
                        leading: const Icon(Icons.rate_review, color: Colors.green,),
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