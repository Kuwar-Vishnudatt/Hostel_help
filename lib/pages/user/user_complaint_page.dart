// ignore_for_file: library_private_types_in_public_api, unused_local_variable

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserComplaintsPage extends StatefulWidget {
  const UserComplaintsPage({Key? key});

  @override
  _UserComplaintsPageState createState() => _UserComplaintsPageState();
}

class _UserComplaintsPageState extends State<UserComplaintsPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  void _markAsAddressed(DocumentSnapshot complaint) async {
    await _firestore
        .collection('complaints')
        .doc(complaint.id)
        .update({'addressed': true});
  }

  void _deleteComplaint(DocumentSnapshot complaint) async {
    await _firestore.collection('complaints').doc(complaint.id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Complaints'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('complaints')
            .where('userId', isEqualTo: _auth.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot complaint = snapshot.data!.docs[index];
              bool addressed = (complaint.data() as Map<String, dynamic>)
                      .containsKey('addressed')
                  ? complaint['addressed']
                  : false;

              bool seen =
                  (complaint.data() as Map<String, dynamic>).containsKey('seen')
                      ? complaint['seen']
                      : false;

              return ListTile(
                title: Text('Complaint: ${complaint['complaint']}'),
                subtitle: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      const TextSpan(text: 'Seen by Faculty: '),
                      TextSpan(
                        text: '${complaint['seen'] ? 'Yes' : 'No'}\n',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                complaint['seen'] ? Colors.green : Colors.red),
                      ),
                    ],
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: addressed,
                      onChanged: (bool? newValue) {
                        if (newValue != null) {
                          _markAsAddressed(complaint);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _deleteComplaint(complaint);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
