import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:real_estate_app/UI/color.dart';
import 'package:real_estate_app/UI/textstyle.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//implement if else bool vaibale to check when to select all agents or when to select agents associated with a specific user

class ViewAgentReviews extends StatefulWidget {
 const ViewAgentReviews( {super.key, required this.agentid});
final String agentid;
  @override
  State<ViewAgentReviews> createState() => _ViewAgentReviewsState();
}

class _ViewAgentReviewsState extends State<ViewAgentReviews> {
 List<Map<String, dynamic>> comments = [];

  final SupabaseClient client = Supabase.instance.client;
  
  Future<List<Map<String, dynamic>>> fetchAllComments() async {
    try {
      final response = await client.from('agent_review').select('*').eq('agent_id',widget.agentid);
      if (response.isEmpty) {
        print('No data returned from the database');
        return [];
      }
      print('Comments Data fetched successfully: $response');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Unexpected error: $e');
      return [];
    }
  }



   Future<void> fetchComments() async {
    List<Map<String, dynamic>> fetchedComments = await fetchAllComments();
    setState(() {
      comments = fetchedComments;
    });
  }



 
  @override
  void initState() {
    super.initState();
    fetchComments();
    print(comments);
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          title: const Text('View Comments', 
          style: tappbar_style,),
          backgroundColor: buttonColor,
        ),
        backgroundColor: propertyBGColor,

      body: comments.isEmpty
            ? const Center(child: Text('No comments on Property'))
            : ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index){
                final comment = comments[index];
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
                      icon: Icons.info,
                      label: 'info',
                      
                      )
                    ]),
                    child: Card(
                      elevation: 3,
                      child: ListTile(
                        title: Text(comment['comments']?? '',
                        style: tUserBody,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [ Text(
                              'By: ${comment['author'] ?? 'Anonymous'}',
                              style: tUserBody,
                            ),
                            Text(
                              'Date: ${comment['date'] ?? ''}',
                              style: tUserBody,
                            ),
                            ],
                        ),
                        leading: const Icon(Icons.comment, color: Colors.green,),
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