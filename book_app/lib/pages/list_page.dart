// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, avoid_print, avoid_unnecessary_containers, use_build_context_synchronously, unnecessary_null_comparison, non_constant_identifier_names

import 'package:book_app/pages/detail_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
 
 final liste = FirebaseFirestore.instance.collection("Liste");
late Future<List<DocumentSnapshot>> listsFuture;
  List<String> selectedListBooks = [];
TextEditingController listNameController = TextEditingController();
 final CollectionReference kitaplar =
      FirebaseFirestore.instance.collection('Kitaplar');

List<String> bookIds2=[];
late String selectedList;
Future<void> createList() async {
  try {
    String listName = listNameController.text.trim();
    if (listNameController.text.trim().isEmpty) {
      // Liste adı boşsa uyarı göster
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Hata!'),
            content: Text('Liste adı boş olamaz.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Tamam'),
              ),
            ],
          );
        },
      );
      return;
    }
    
    // Diğer listelerle aynı isimde liste olup olmadığını kontrol et
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Liste')
        .where('liste_ad', isEqualTo: listName)
        .where('uye_id',isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      // Liste adı başka bir listede kullanılıyorsa uyarı göster
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Hata!'),
            content: Text('Bu liste adı zaten kullanılıyor.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Tamam'),
              ),
            ],
          );
        },
      );
      return;
    }
    
    // Liste adı benzersizse, liste oluşturma işlemine devam et
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference listsCollection = firestore.collection('Liste');
     
    List<String> emptyBookIds = [];
    Map<String, dynamic> newListData = {
      'liste_ad': listName,
      'uye_id': FirebaseAuth.instance.currentUser!.uid,
      'kitap_ids': emptyBookIds,
    };
    await listsCollection.add(newListData);

    print('Liste oluşturuldu: $listName');
  } catch (error) {
    print('Liste oluşturulurken bir hata oluştu: $error');
  }
}





Future<List<DocumentSnapshot>> getLists() async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await firestore.collection('Liste').where("uye_id",isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();
    return querySnapshot.docs;
  } catch (error) {
    print('Listeler alınırken bir hata oluştu: $error');
    return [];
  }
}




Future<List<String>> getBookIdsFromList(String listId) async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference listRef = firestore.collection('Liste').doc(listId);
    DocumentSnapshot listSnapshot = await listRef.get();
    if (listSnapshot.exists) {
List<dynamic> bookIds = (listSnapshot.data() as Map<String, dynamic>)['kitap_ids'];
      return bookIds.cast<String>();
    } else {
      print('Belirtilen liste bulunamadı: $listId');
      return [];
    }
  } catch (error) {
    print('Listeden kitap ID\'leri alınırken bir hata oluştu: $error');
    return [];
  }
}




Future<void> deleteList(String listId) async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference listRef = firestore.collection('Liste').doc(listId);
    await listRef.delete();

    print('Liste silindi: $listId');
    setState(() {
      selectedListBooks = [];
    });
    listsFuture = getLists();
  } catch (error) {
    print('Liste silinirken bir hata oluştu: $error');
  }
}



Future<void> updateListName(String listId, String newName) async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference listRef = firestore.collection('Liste').doc(listId);
    await listRef.update({'liste_ad': newName});

    print('Liste güncellendi: $listId, Yeni ad: $newName');
  } catch (error) {
    print('Liste güncellenirken bir hata oluştu: $error');
  }
}





  @override
  void initState() {
    super.initState();
    listsFuture = getLists();
  }

  @override
 Widget build(BuildContext context) {
    return Scaffold(
      
      floatingActionButton: FloatingActionButton(
    onPressed: () {
      listNameController.clear();
showModalBottomSheet(
  isScrollControlled: true,
  context: context,
  builder: (BuildContext context) {

    return Container(
      padding: EdgeInsets.all(16),
      
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Liste Ekle',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: listNameController,
              decoration: InputDecoration(
                labelText: 'Yeni Liste Adı',
                border: OutlineInputBorder(),
              ),
             
            ),
            SizedBox(height: 16),
             Container(
              alignment: Alignment.topLeft,
              width: 200,
              padding: EdgeInsets.only(left: 10,right: 10),
               child: ElevatedButton(
                     onPressed: () {

String listName = listNameController.text.trim();
            if (listName.isEmpty) {
              // Liste adı boşsa uyarı göster
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Hata!'),
                    content: Text('Liste adı boş olamaz.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Tamam'),
                      ),
                    ],
                  );
                },
              );
              return; 
            }
            
            createList();
            setState(() { selectedListBooks = [];});
            listsFuture = getLists();
            Navigator.pop(context); 

                       
                       
                       
                     
                     },
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.amber.shade800,
                       padding: EdgeInsets.symmetric(vertical: 15),
                       shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
                     ),
                     child: Container(
                      padding: EdgeInsets.only(left: 10,right: 10),
                       child: Text(
                         'Liste Oluştur',
                         style: TextStyle(
                           fontSize: 18,
                           fontWeight: FontWeight.bold,
                           color: Colors.white,
                         ),
                       ),
                     ),
                   ),
             ),
          ],
        ),
      ),
    );
  },
);    },
backgroundColor: Colors.white,
    child: Icon(Icons.add,
    
    ),
  ),
      appBar: AppBar(
        title: Text('Kitap Listeleri'),
      ),
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: EdgeInsets.only(left: 10,top: 10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          color: Colors.white,
                                        ),
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
  stream: FirebaseFirestore.instance.collection('Liste').where("uye_id",isEqualTo: FirebaseAuth.instance.currentUser!.uid).snapshots(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return Text('Hata: ${snapshot.error}');
    } else {
List<DocumentSnapshot> lists = snapshot.data!.docs;      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: lists.map((list) {
            String listName = (list.data() as Map<String, dynamic>)['liste_ad'] ?? '';
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.amber.shade800,
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: EdgeInsets.only(right: 5),
                child: Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          List<String> bookIds =
                              await getBookIdsFromList(list.id);
                          bookIds2 =
                              await getBookIdsFromList(list.id);
                          selectedList=list.id;
                          setState(() {
                            selectedListBooks = bookIds;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.only(left: 15),
                          child: Text(listName,maxLines: 1,style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),),
                        ),
                      ),
                    ),
                    IconButton(icon: Icon(Icons.more_vert),onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            child: Wrap(
                              children: [
                                ListTile(
  leading: Icon(Icons.edit),
  title: Text('Düzenle'),
  onTap: () async {
    String newName = await showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController newNameController = TextEditingController();
        return AlertDialog(
          title: Text('Liste Adını Düzenle'),
          content: TextField(
            controller: newNameController,
            decoration: InputDecoration(
              labelText: 'Yeni Liste Adı',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(newNameController.text);
              },
              child: Text('Kaydet'),
            ),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty) {
      bool nameExists = false;
      for (var list in snapshot.data!.docs) {
        String existingName = (list.data())['liste_ad'] ?? '';
        if (existingName == newName) {
          nameExists = true;
          break;
        }
      }
      if (nameExists) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Hata!'),
              content: Text('Bu liste adı zaten kullanılıyor.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Tamam'),
                ),
              ],
            );
          },
        );
        return;
      }
    

      await updateListName(list.id, newName);
      setState(() {
        selectedListBooks = [];
      });
      listsFuture = getLists();
    }
    Navigator.pop(context);
  },
),
                                ListTile(
                                  leading: Icon(Icons.delete),
                                  title: Text('Sil'),
                                  onTap: () async{
                                    await deleteList(list.id);
                                    setState(() {
                                      selectedListBooks = [];
                                      
                                    });
                                    listsFuture = getLists();
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        
      }).toList(),
    ),
  );
}

 })
            ),
         Expanded(
  child: selectedListBooks.isEmpty
      ? Center(
          child: Container(
            padding: EdgeInsets.all(25),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          color: Colors.white,
                                        ),
            child: Text(
              'Listede Kitap Bulunmamaktadır.',
              style: TextStyle(fontSize: 18),
            ),
          ),
        )
      : Container(
          margin: EdgeInsets.only(left: 10, top: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
          ),
          child:StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance.collection('Kitaplar').snapshots(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return Text('Hata: ${snapshot.error}');
    } else {
      List<DocumentSnapshot> allBooks = snapshot.data!.docs;
      List<DocumentSnapshot> selectedBooks = [];
      for (var book in allBooks) {
        if (bookIds2.contains(book.id)) {
          selectedBooks.add(book);
        }
      }

      return Container(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
          ),
          itemCount: selectedBooks.length,
          itemBuilder: (context, index) {
            QueryDocumentSnapshot<Object?> bookData = selectedBooks[index] as QueryDocumentSnapshot<Object?>;
            
            String bookTitle = bookData['kitap_ad'];
            String bookImageUrl = bookData['resim'];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailPage(bookData: bookData),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.only(left: 10, top: 10, right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.amber.shade800,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 10),
                      child: Image.network(
                        bookImageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Text(
                      bookTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    PopupMenuButton(
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem(
                            value: 'option1',
                            child: Text('Listeden Çıkar'),
                          ),
                        ];
                      },
                      onSelected: (value) async {
                        if (value == 'option1') {
                          String bookIdToRemove = selectedBooks[index].id;
                          String listId = selectedList;
                          List<String> bookIds = await getBookIdsFromList(listId);
                          bookIds.remove(bookIdToRemove);
                          await FirebaseFirestore.instance.collection('Liste').doc(listId).update({'kitap_ids': bookIds});
                         
setState(() {
   selectedListBooks = bookIds;
   bookIds2=bookIds;
});
                           
                       
                          print(bookIds);
                          listsFuture = getLists();
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
  },
),

        ),
),
        ],)
      
    );
  }
}

Future<List<DocumentSnapshot>> getBooksFromList(String listId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference listRef = firestore.collection('Liste').doc(listId);
      DocumentSnapshot listSnapshot = await listRef.get();

      if (listSnapshot.exists) {
        List<dynamic> bookIds = (listSnapshot.data() as Map<String, dynamic>)['kitap_ids'];
        List<DocumentSnapshot> bookSnapshots = [];

        for (String bookId in bookIds) {
          DocumentSnapshot bookSnapshot = await firestore.collection('Kitap').doc(bookId).get();
          if (bookSnapshot.exists) {
            bookSnapshots.add(bookSnapshot);
          }
        }

        return bookSnapshots;
      } else {
        print('Belirtilen liste bulunamadı: $listId');
        return [];
      }
    } catch (error) {
      print('Listeden kitaplar alınırken bir hata oluştu: $error');
      return [];
    }
  }
