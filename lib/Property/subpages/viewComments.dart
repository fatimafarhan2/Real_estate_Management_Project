import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:real_estate_app/UI/color.dart';
import 'package:real_estate_app/UI/textstyle.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//implement if else bool vaibale to check when to select all agents or when to select agents associated with a specific user

class Viewcomments extends StatefulWidget {
  // ignore: non_constant_identifier_names
  Viewcomments({super.key, required this.property_id});
  final int property_id;

  @override
  State<Viewcomments> createState() => _ViewcommentsState();
}

class _ViewcommentsState extends State<Viewcomments> {
  List<Map<String, dynamic>> comments = [];

  final SupabaseClient client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchAllComments() async {
    try {
      final response = await client
          .from('property_review')
          .select('*,client(username)')
          .eq('property_id', widget.property_id);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'View Comments',
          style: tappbar_style,
        ),
        backgroundColor: buttonColor,
      ),
      backgroundColor: propertyBGColor,
      body: comments.isEmpty
          ? const Center(child: Text('No comments on Property'))
          : ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                final username = comment['client']?['username'] ?? 'Anonymous';
                return Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Slidable(
                      key: ValueKey(index),
                      endActionPane:
                          ActionPane(motion: const ScrollMotion(), children: [
                        SlidableAction(
                          onPressed: (context) {
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
                          title: Text(
                            comment['comments'] ?? '',
                            style: tUserBody,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'By: $username',
                                style: tUserBody,
                              ),
                              Text(
                                'Date: ${comment['date'] ?? ''}',
                                style: tUserBody,
                              ),
                            ],
                          ),
                          leading: const Icon(
                            Icons.comment,
                            color: Colors.green,
                          ),
                        ),
                      )),
                );
              },
            ),
    );
  }
}
