// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:book_app/pages/forgot_pw_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> deleteAccount(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      String? password = await _showPasswordDialog(context);
      if (password != null) {
        AuthCredential credential = EmailAuthProvider.credential(email: user!.email!, password: password);
        await user.reauthenticateWithCredential(credential);

        // Kullanıcıyı sil
        await user.delete();
        await FirebaseFirestore.instance.collection("users").doc(user.uid).delete();
        print('Account deleted successfully.');
      } else {
        print('Password is null.');
      }
    } catch (e) {
      print('Failed to delete account: $e');
    }
  }

  Future<String?> _showPasswordDialog(BuildContext context) async {
    String? password;
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController passwordController = TextEditingController();
        return AlertDialog(
          title: Text("Parolayı Girin"),
          content: TextFormField(
            controller: passwordController,
            decoration: InputDecoration(labelText: "Parola"),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Lütfen parolayı girin';
              }
              return null;
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(passwordController.text);
              },
              child: const Text("Onayla"),
            ),
          ],
        );
      },
    ).then((value) {
      password = value;
    });
    return password;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Şifre Yenile'),
            leading: Icon(Icons.password),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordPage()));
            },
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: const Text('Hesabı sil'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Onayla"),
                    content: const Text("Hesabını silmek istediğinden emin misin?"),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () async {
                          await deleteAccount(context); 
                          Navigator.of(context).pop();
                        },
                        child: const Text("Sil"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("İptal"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
