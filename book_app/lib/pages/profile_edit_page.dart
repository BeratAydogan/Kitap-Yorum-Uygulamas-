// ignore_for_file: library_private_types_in_public_api, avoid_print, prefer_const_constructors

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late TextEditingController isimController;
  late TextEditingController soyisimController;
  late TextEditingController epostaController; 
  late String foto="";
 PlatformFile? pickedfile;
  UploadTask? uploadTask;

void removeProfilePhoto() async {
  final user = _firestore.collection("users").doc(FirebaseAuth.instance.currentUser!.uid);
  
  // Profil resmi alanını null olarak güncelle
  await user.update({
    'profil_foto': "",
  });

  setState(() {
    foto = ""; // Profil resmi değişkenini sıfırla
  });
}


 void _getUserData() async {
    final user = _firestore.collection("users").doc(FirebaseAuth.instance.currentUser!.uid);
    user.get().then((userData) {
      if (userData.exists) {
        setState(() {
          isimController.text = userData["isim"];
          soyisimController.text = userData["soyisim"];
          epostaController.text = userData["eposta"];
          foto=userData["profil_foto"];
        });
      }
    }).catchError((error) {
      print("Kullanıcı bilgileri getirilirken hata oluştu: $error");
    });
  }
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


Future<void> updateUser() async {
  final user = _firestore.collection("users").doc(FirebaseAuth.instance.currentUser!.uid);

  // Giriş yapılan alanları kontrol et
  if (isimController.text.trim().isEmpty ||
      soyisimController.text.trim().isEmpty ||
      epostaController.text.trim().isEmpty) {
    // Alanlar boşsa kullanıcıya uyarı ver
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Uyarı"),
          content: Text("Lütfen tüm alanları doldurunuz."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Tamam"),
            ),
          ],
        );
      },
    );
  } else {
    // Alanlar doluysa güncelleme işlemini gerçekleştir
    if (pickedfile == null) {
      await user.update({
        "isim": isimController.text.trim(),
        "soyisim": soyisimController.text.trim(),
        "eposta": epostaController.text.trim(),
      });
    } else {
      final path = 'files/${pickedfile!.name}';
      final file = File(pickedfile!.path!);

      final ref = FirebaseStorage.instance.ref().child(path);
      setState(() {
        uploadTask = ref.putFile(file);
      });

      final snapshot = await uploadTask!.whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();
      await user.update({
        "isim": isimController.text.trim(),
        "soyisim": soyisimController.text.trim(),
        "eposta": epostaController.text.trim(),
        'profil_foto': urlDownload.toString(),
      });
    }
  }
}


  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    setState(() {
      pickedfile = result.files.first;
    });
  }
 

  @override
  void initState() {
    super.initState();
    isimController = TextEditingController();
    soyisimController=TextEditingController();
    epostaController=TextEditingController();
   
    _getUserData();
  }


  

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Düzenleme Sayfası'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
             GestureDetector(
  onTap: () {
    selectFile();
  },
  child: Container(
    width: 100,
    height: 100,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.transparent,
    ),
    child: foto.isNotEmpty && pickedfile != null
      ? ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Image.file(
            File(pickedfile!.path!),
            width: 50,
            fit: BoxFit.contain,
          ),
        )
      : foto.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.network(
              foto,
              width: 50,
              fit: BoxFit.contain,
            ),
          )
        : Icon(
            Icons.camera_alt,
            size: 40,
            color: Colors.grey[700],
          ),
  ),
),ElevatedButton(
  onPressed: removeProfilePhoto,
  child: Text('Profil Resmini Kaldır'),
),
            TextFormField(
              controller: isimController,
              decoration: InputDecoration(labelText: 'İsim'),
              onEditingComplete: (){
                setState(() {
                  
                });
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: soyisimController,
              decoration: InputDecoration(labelText: 'Soyisim'),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: epostaController,
              readOnly: true,
              decoration: InputDecoration(labelText: 'E-posta'),
            ),
           
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                 updateUser();
               
              },
              child: Text('Bilgileri Güncelle'),
            ),
          ],
        ),
      ),
    );
  }

 
}