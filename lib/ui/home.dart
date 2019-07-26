import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:date_format/date_format.dart';


class Home extends StatelessWidget {

  final googleSignIn = GoogleSignIn();
  final auth = FirebaseAuth.instance;

  Future<Null> _logar() async {

    GoogleSignInAccount user = googleSignIn.currentUser;

    if (user == null) {
      user = await googleSignIn.signInSilently();
    }

    if (user == null) {
      user = await googleSignIn.signIn();
    }

    if (await auth.currentUser() == null) {
      GoogleSignInAuthentication credentials = await googleSignIn.currentUser.authentication;
      await auth.signInWithCredential(GoogleAuthProvider.getCredential(
          idToken: credentials.idToken,
          accessToken: credentials.accessToken
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Copiar / Colar"),
        actions: <Widget>[
          IconButton(
            onPressed: _logar,
            icon: Icon(Icons.input, color: Colors.white),
          )
        ],
      ),
      body: StreamBuilder(
        builder: (context, snapshot) {
          switch(snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            default:
              var copiados = snapshot.data.documents.reversed.toList();
              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, position) {
                  return montarListTile(context, copiados[position]);
                }
              );
          }
        },
        stream: Firestore.instance.collection("copiados").orderBy("data").snapshots(),
      )
    );
  }

  Dismissible montarListTile(BuildContext context, DocumentSnapshot item) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.redAccent,
        child: Align(
          alignment: Alignment(-0.9, 0),
          child: Icon(Icons.delete_forever, color: Colors.white)
        )
      ),
      onDismissed: (dir) async {
        await Firestore.instance.runTransaction((Transaction transcation) async {
          await transcation.delete(item.reference);
        });
      },
      child: ListTile(
        leading: IconButton(
          icon: Icon(Icons.content_copy, color: Colors.black),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: item.data["valor"]));
            Scaffold.of(context).showSnackBar(SnackBar(
                content: Text("Copiado para a área de transferência :)")
            ));
          }
        ),
        title: Text(item.data["valor"]),
        subtitle: Text(formatDate(item.data["data"].toDate(), [dd, '/', mm, '/', yyyy, ' ', HH, ':', nn])),
      )
    );
  }

}
