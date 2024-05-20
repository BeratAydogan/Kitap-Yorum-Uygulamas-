// ignore_for_file: prefer_const_constructors, unnecessary_import

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  PlatformFile? pickedfile;
  UploadTask? uploadTask;
  final _kitapAd = TextEditingController();
  final _sayfasayisi = TextEditingController();
  final _dil = TextEditingController();
  final _ozet = TextEditingController();
  final _btarihi = TextEditingController();
  final _kategoriID = TextEditingController();
  final _yazarID = TextEditingController();
  final _yayineviID = TextEditingController();

  final CollectionReference kitap =
      FirebaseFirestore.instance.collection('Kitaplar');
  final Query<Map<String, dynamic>> yazar = FirebaseFirestore.instance.collection('Yazar').orderBy('yazar_ad');
  final Query<Map<String, dynamic>> kategori = FirebaseFirestore.instance.collection('Kategori').orderBy('kategori_ad');
  final Query<Map<String, dynamic>> yayinevi = FirebaseFirestore.instance.collection('Yayinevi').orderBy('yayinevi_ad');


  Future kitapEkle() async {
    final path = 'files/${pickedfile!.name}';
    final file = File(pickedfile!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    setState(() {
      uploadTask = ref.putFile(file);
    });

    final snapshot = await uploadTask!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();

    kitap.add({
      'kitap_ad': _kitapAd.text.trim(),
      'sayfa_sayisi': _sayfasayisi.text.trim(),
      'dil': _dil.text.trim(),
      'ozet': _ozet.text.trim(),
      'btarihi': _btarihi.text.trim(),
      'kategoriID': _kategoriID.text.trim(),
      'yazarID': _yazarID.text.trim(),
      'yayineviID': _yayineviID.text.trim(),
      'resim': urlDownload.toString(),
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
                        controller: _kitapAd,
                        decoration: InputDecoration(
                          hintText: 'Kitap Adı',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                StreamBuilder(
                  stream: yazar.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List yazarList = snapshot.data!.docs;
                      return Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(12)),
                        child: TextField(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => SizedBox(
                                height:
                                    300,
                                child: ListView.builder(
                                  itemCount: yazarList.length,
                                  itemBuilder: (context, index) {
                                    DocumentSnapshot document =
                                        yazarList[index];
                                    Map<String, dynamic> data =
                                        document.data() as Map<String, dynamic>;

                                    return ListTile(
                                      title: Text(data['yazar_ad']),
                                      onTap: () {
                                        setState(() {
                                          _yazarID.text = document.id
                                              .toString();
                                        });
                                        Navigator.of(context).pop();
                                      },
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                          controller: _yazarID,
                          decoration: InputDecoration(
                            hintText: 'Yazar ID',
                            border: InputBorder.none,
                          ),
                        ),
                      );
                    } else {
                      return Text('veri yok');
                    }
                  },
                ),
                 StreamBuilder(
                  stream: kategori.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List kategoriList = snapshot.data!.docs;
                      return Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(12)),
                        child: TextField(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => SizedBox(
                                height:
                                    300,
                                child: ListView.builder(
                                  itemCount: kategoriList.length,
                                  itemBuilder: (context, index) {
                                    DocumentSnapshot document =
                                        kategoriList[index];
                                    Map<String, dynamic> data =
                                        document.data() as Map<String, dynamic>;

                                    return ListTile(
                                      title: Text(data['kategori_ad']),
                                      onTap: () {
                                        setState(() {
                                          _kategoriID.text = document.id
                                              .toString();
                                        });
                                        Navigator.of(context).pop();
                                      },
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                          controller: _kategoriID,
                          decoration: InputDecoration(
                            hintText: 'Kategori ID',
                            border: InputBorder.none,
                          ),
                        ),
                      );
                    } else {
                      return Text('veri yok');
                    }
                  },
                ),
                StreamBuilder(
                  stream: yayinevi.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List yayineviList = snapshot.data!.docs;
                      return Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(12)),
                        child: TextField(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => SizedBox(
                                height:
                                    300,
                                child: ListView.builder(
                                  itemCount: yayineviList.length,
                                  itemBuilder: (context, index) {
                                    DocumentSnapshot document =
                                        yayineviList[index];
                                    Map<String, dynamic> data =
                                        document.data() as Map<String, dynamic>;

                                    return ListTile(
                                      title: Text(data['yayinevi_ad']),
                                      onTap: () {
                                        setState(() {
                                          _yayineviID.text = document.id
                                              .toString();
                                        });
                                        Navigator.of(context).pop();
                                      },
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                          controller: _yayineviID,
                          decoration: InputDecoration(
                            hintText: 'Yayınevi ID',
                            border: InputBorder.none,
                          ),
                        ),
                      );
                    } else {
                      return Text('veri yok');
                    }
                  },
                ),
               
               
                SizedBox(
                  height: 25,
                ),
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
                        controller: _ozet,
                        decoration: InputDecoration(
                          hintText: 'Özeti',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
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
                        controller: _sayfasayisi,
                        decoration: InputDecoration(
                          hintText: 'Sayfa Sayısı',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
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
                        controller: _dil,
                        decoration: InputDecoration(
                          hintText: 'Kitap Dili',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
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
                        controller: _btarihi,
                        decoration: InputDecoration(
                          hintText: 'Kitap Basım Tarihi',
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
                      child: Image.file(
                        File(pickedfile!.path!),
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ElevatedButton(onPressed: selectFile, child: Text('Resim Seç')),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(onPressed: kitapEkle, child: Text('Kaydet')),
                buildProgress(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProgress() => StreamBuilder<TaskSnapshot>(
      stream: uploadTask?.snapshotEvents,
      builder: ((context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          double progress = data.bytesTransferred / data.totalBytes;
          return SizedBox(
            height: 50,
            child: Stack(
              fit: StackFit.expand,
              children: [
                LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey,
                    color: Colors.green),
                Center(
                  child: Text(
                    '${(100 * progress).roundToDouble()}',
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          );
        } else {
          return SizedBox(
            height: 50,
          );
        }
      }));
}
