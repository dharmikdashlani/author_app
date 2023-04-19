import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

import '../../helpers/firestore_db_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<FormState> insertKey = GlobalKey<FormState>();
  GlobalKey<FormState> updateKey = GlobalKey<FormState>();

  TextEditingController authorController = TextEditingController();
  TextEditingController bookController = TextEditingController();

  String? author_name;
  String? author_book;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Authors Details",
          style: GoogleFonts.poppins(
            textStyle: TextStyle(),
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return buildAlertDialog(context);
            },
          );
        },
        child: Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("authors").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "${snapshot.error}",
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(),
                ),
              ),
            );
          } else if (snapshot.hasData) {
            QuerySnapshot<Map<String, dynamic>> data =
                snapshot.data as QuerySnapshot<Map<String, dynamic>>;
            List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs =
                data.docs;

            return ListView.builder(
                padding: EdgeInsets.all(10),
                physics: BouncingScrollPhysics(),
                itemCount: allDocs.length,
                itemBuilder: (context, i) {
                  return Card(
                    elevation: 4,
                    child: ListTile(
                      leading: Text("${i + 1}"),
                      title: Text(
                        "Author : ${allDocs[i].data()['author_name']}",
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(),
                        ),
                      ),
                      subtitle: Text(
                        "Book : ${allDocs[i].data()['book_name']}",
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () async {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return buildUpdateDialog(context,
                                      id: allDocs[i].id);
                                },
                              );
                            },
                            icon: Icon(Icons.mode_edit_outlined),
                            color: Colors.blue,
                          ),
                          IconButton(
                            onPressed: () async {
                              await FirestoreDBHelper.firestoreDBHelper
                                  .delete(id: "${allDocs[i].id}");
                            },
                            icon: Icon(Icons.remove_circle_outline_outlined),
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  );
                });
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  AlertDialog buildAlertDialog(BuildContext context) {
    return AlertDialog(
      title: Text('Add Author Details',style:GoogleFonts.poppins(
        textStyle: TextStyle(),
      ),),
      content: Form(
        key: insertKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              style: GoogleFonts.poppins(
                textStyle: TextStyle(),
              ),
              controller: authorController,
              validator: (val) {
                if (val!.isEmpty) {
                  return "Enter name...";
                }
                return null;
              },
              onSaved: (val) {
                author_name = val;
              },
              decoration: InputDecoration(
                labelText: "Author Name",
                labelStyle: GoogleFonts.poppins(
                  textStyle: TextStyle(),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            Divider(),
            TextFormField(
              style: GoogleFonts.poppins(
            textStyle: TextStyle(),
            ),
              controller: bookController,
              validator: (val) {
                if (val!.isEmpty) {
                  return "Enter book name...";
                }
                return null;
              },
              onSaved: (val) {
                author_book = val;
              },
              decoration: InputDecoration(
                labelText: "Book Name",
                labelStyle: GoogleFonts.poppins(
    textStyle: TextStyle(),
    ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () {
            setState(() {
              authorController.clear();
              bookController.clear();

              author_name = null;
              author_book = null;
            });

            Navigator.pop(context);
          },
          child: Text("Cancel",style: GoogleFonts.poppins(
            textStyle: TextStyle(),
          ),),
        ),
        SizedBox(
          width: 5,
        ),
        ElevatedButton(
          onPressed: () async {
            if (insertKey.currentState!.validate()) {
              insertKey.currentState!.save();

              Map<String, dynamic> data = {
                "author_name": author_name,
                "book_name": author_book,
              };

              Navigator.pop(context);

              await FirestoreDBHelper.firestoreDBHelper.insert(data: data);
            }

            setState(() {
              authorController.clear();
              bookController.clear();

              author_name = null;
              author_book = null;
            });
          },
          child: Text("Add",style: GoogleFonts.poppins(
            textStyle: TextStyle(),
          ),),
        ),
      ],
    );
  }

  AlertDialog buildUpdateDialog(BuildContext context, {required String id}) {
    return AlertDialog(
      title: Text('Update Author Details',style: GoogleFonts.poppins(
        textStyle: TextStyle(),
      ),),
      content: Form(
        key: updateKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: authorController,
              validator: (val) {
                if (val!.isEmpty) {
                  return "Enter name...";
                }
                return null;
              },
              onSaved: (val) {
                author_name = val;
              },
              style: GoogleFonts.poppins(
                textStyle: TextStyle(),
              ),
              decoration: InputDecoration(
                labelText: "Author Name",
                labelStyle: GoogleFonts.poppins(
                  textStyle: TextStyle(),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            Divider(),
            TextFormField(
              controller: bookController,
              validator: (val) {
                if (val!.isEmpty) {
                  return "Enter book name...";
                }
                return null;
              },
              onSaved: (val) {
                author_book = val;
              },
              style: GoogleFonts.poppins(
                textStyle: TextStyle(),
              ),
              decoration: InputDecoration(
                labelStyle: GoogleFonts.poppins(
                  textStyle: TextStyle(),
                ),
                labelText: "Book Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () {
            setState(() {
              authorController.clear();
              bookController.clear();

              author_name = null;
              author_book = null;
            });

            Navigator.pop(context);
          },
          child: Text("Cancel",style: GoogleFonts.poppins(
            textStyle: TextStyle(),
          ),),
        ),
        SizedBox(
          width: 5,
        ),
        ElevatedButton(
          onPressed: () async {
            if (updateKey.currentState!.validate()) {
              updateKey.currentState!.save();

              Map<String, dynamic> data = {
                "author_name": author_name,
                "book_name": author_book,
              };

              Navigator.pop(context);

              await FirestoreDBHelper.firestoreDBHelper.update(
                  id: id,
                  author_name: '$author_name',
                  book_name: '$author_book');
            }

            setState(() {
              authorController.clear();
              bookController.clear();

              author_name = null;
              author_book = null;
            });
          },
          child: Text("Update",style: GoogleFonts.poppins(
            textStyle: TextStyle(),
          ),),
        ),
      ],
    );
  }
}
