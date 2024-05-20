// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AddPublisherPage extends StatefulWidget {
  const AddPublisherPage({super.key});

  @override
  State<AddPublisherPage> createState() => _AddPublisherPageState();
}

class _AddPublisherPageState extends State<AddPublisherPage> {
 PlatformFile? pickedfile;
  UploadTask? uploadTask;
  final _yayineviAd = TextEditingController();
  final _site = TextEditingController();
  final _numara = TextEditingController();
  final _mail = TextEditingController();
  final _adres = TextEditingController();
  final CollectionReference yayinevi = FirebaseFirestore.instance.collection('Yayinevi');

  Future yayineviEkle()async{
    final path = 'files/${pickedfile!.name}';
    final file = File(pickedfile!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    setState(() {
      uploadTask = ref.putFile(file);
    });
   

    final snapshot = await uploadTask!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    
    yayinevi.add({
      'yayinevi_ad':_yayineviAd.text.trim(),
      'site':_site.text.trim(),
      'numara':_numara.text.trim(),
      'mail':_mail.text.trim(),
      'adres':_adres.text.trim(),
      'resim':urlDownload.toString(),
  });
  }


  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    setState(() {
      pickedfile = result.files.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: TextField(
                            controller: _yayineviAd,
                            decoration: InputDecoration(
                              hintText: 'Yayınevi Adı',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 25,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: TextField(
                            controller: _mail,
                            decoration: InputDecoration(
                              hintText: 'Eposta',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 25,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: TextField(
                            controller: _site,
                            decoration: InputDecoration(
                              hintText: 'Site',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 25,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: TextField(
                            controller: _numara,
                            decoration: InputDecoration(
                              hintText: 'Numara',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 25,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: TextField(
                            controller: _adres,
                            decoration: InputDecoration(
                              hintText: 'Adres',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                if (pickedfile != null)
                  
                       Container(
                        height: 200,
                    color: Colors.orange[100],
                    child: Center(
                      child: Image.file(File(pickedfile!.path!),width: double.infinity,fit: BoxFit.cover,),
                    ),
                  ),
                ElevatedButton(onPressed: selectFile, child: Text('Resim Seç')),
                SizedBox(height: 20,),
                
                
                ElevatedButton(onPressed: yayineviEkle, child: Text('Kaydet')),
                buildProgress(),
                
              ],
            ),
          ),
        ),
      ),
    );
  }


Widget buildProgress()=>StreamBuilder<TaskSnapshot>(
  stream: uploadTask?.snapshotEvents, 
  builder: ((context, snapshot) {
    if(snapshot.hasData){
      final data = snapshot.data!;
      double progress = data.bytesTransferred/data.totalBytes;
      return SizedBox(
        height: 50,
        child: Stack(
          fit: StackFit.expand,
          children: [
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey,
              color:Colors.green
            ),
          Center(
            child: Text('${(100*progress).roundToDouble()}',style: const TextStyle(color: Colors.white),),
          )
          ],
        ),
      );
    }else{
      return SizedBox(height: 50,);
    }
  }));

}