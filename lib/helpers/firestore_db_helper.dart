import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreDBHelper {
  FirestoreDBHelper._();

  static final FirestoreDBHelper firestoreDBHelper = FirestoreDBHelper._();

  static final FirebaseFirestore db = FirebaseFirestore.instance;

  insert({required Map<String, dynamic> data}) async {
    DocumentSnapshot<Map<String, dynamic>> counter =
    await db.collection("counter").doc("authors_counter").get();

    int id = counter['id'];
    int length = counter['length'];

    await db.collection("authors").doc("${++id}").set(data);

    await db.collection("counter").doc("authors_counter").update({"id": id});

    await db
        .collection("counter")
        .doc("authors_counter")
        .update({"length": ++length});

    // await db.collection("students").doc("1").set(data);
    // await db.collection("students").add(data);
  }

  delete({required String id}) async {
    await db.collection("authors").doc(id).delete();

    DocumentSnapshot<Map<String, dynamic>> counter =
    await db.collection("counter").doc("authors_counter").get();

    int length = counter['length'];

    await db.collection("counter").doc("authors_counter").update({"length":--length});
  }


  update(
      {required String id,
        required String author_name,
        required String book_name,}) async {
    await db
        .collection("authors")
        .doc(id)
        .update({"author_name": author_name, "book_name": book_name,});
  }
}