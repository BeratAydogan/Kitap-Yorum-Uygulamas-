// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, unused_local_variable, avoid_print, prefer_const_literals_to_create_immutables, unrelated_type_equality_checks, avoid_unnecessary_containers, sized_box_for_whitespace, use_build_context_synchronously

import 'dart:ui';

import 'package:book_app/pages/category_page.dart';
import 'package:book_app/pages/edit_review_page.dart';
import 'package:book_app/pages/review_page.dart';
import 'package:book_app/pages/search_page.dart';
import 'package:book_app/pages/show_book_reviews.dart';
import 'package:book_app/pages/show_review.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:readmore/readmore.dart';

class DetailPage extends StatefulWidget {
  final DocumentSnapshot<Object?> bookData;
  const DetailPage({super.key, required this.bookData});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<bool> hasReviewedBook;
  bool value = false;
  

  int _incelemeSayisi = 0;
  final CollectionReference yazar =
      FirebaseFirestore.instance.collection('Yazar');
  final CollectionReference kategori =
      FirebaseFirestore.instance.collection('Kategori');
  final CollectionReference yayinevi =
      FirebaseFirestore.instance.collection('Yayinevi');
  final CollectionReference kitaplar =
      FirebaseFirestore.instance.collection('Kitaplar');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
 String dislike="0";
String like="0";
TextEditingController listNameController = TextEditingController();


late String selectedListId = '';

List<String> selectedListIds = [];
final CollectionReference listsCollection =
    FirebaseFirestore.instance.collection('Liste');



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
    
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Liste')
        .where('liste_ad', isEqualTo: listName)
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






bool isBookInOtherLists(String bookId,  DocumentSnapshot<Object?> list) {
  

    List<dynamic>? bookIds = (list.data() as Map<String, dynamic>?)?['kitap_ids'];

    if (bookIds != null && bookIds.contains(bookId)) {
      return true;
    }else {
      return false;
    
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




void addOrRemoveBookFromSelectedLists(String bookId, List<String> selectedListIds) async {
  QuerySnapshot listsSnapshot = await listsCollection.where('uye_id',isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();

  List<String> listsToAdd = [];

  for (DocumentSnapshot list in listsSnapshot.docs) {
    String listId = list.id;

    try {
      if (selectedListIds.contains(listId)) {
        listsToAdd.add(listId);
      } else {
        print('Kitap listeden çıkarılıyor (listede değil): $listId');
        DocumentReference listRef = listsCollection.doc(listId);
        Map<String, dynamic>? data = list.data() as Map<String, dynamic>?;
        if (data != null) {
          List<dynamic> bookIds = data['kitap_ids'] ?? [];
          if (bookIds.contains(bookId)) {
            bookIds.remove(bookId);
            await listRef.update({'kitap_ids': bookIds});
          }
        }
      }
    } catch (error) {
      print('Kitabı listelere eklerken veya listeden çıkarırken bir hata oluştu: $error');
    }
  }

  for (String listId in listsToAdd) {
    try {
      DocumentReference listRef = listsCollection.doc(listId);
      DocumentSnapshot listSnapshot = await listRef.get();
      if (listSnapshot.exists) {
        Map<String, dynamic>? data = listSnapshot.data() as Map<String, dynamic>?;
        List<dynamic> bookIds = data?['kitap_ids'] ?? [];

        if (!bookIds.contains(bookId)) {
          bookIds.add(bookId);
          await listRef.update({'kitap_ids': bookIds});
          print('Kitap listede ekleniyor: $listId');
        }
      } else {
        print('Belirtilen liste bulunamadı: $listId');
      }
    } catch (error) {
      print('Kitabı listeye eklerken bir hata oluştu: $error');
    }
  }
}



Future<void> fetchLikeCount(String commentId, String userId) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("Begeni")
        .where("begeni", isEqualTo: "1")
        .where('yorum_id', isEqualTo: commentId)
        
        .get();
        QuerySnapshot querySnapshot2 = await FirebaseFirestore.instance
        .collection("Begeni")
        .where("begeni", isEqualTo: "0")
        .where('yorum_id', isEqualTo: commentId)
        
        .get();
    int likeCount = querySnapshot.size;
    int dislikeCount =querySnapshot2.size;
    setState(() {
      like = likeCount.toString(); 
      dislike=dislikeCount.toString();
    });
  } catch (error) {
    print("Hata oluştu: $error");
  }
}


  Future<void> likeComment(String commentId, String userId) async {
    try {

      

        QuerySnapshot querySnapshot = await _firestore
          .collection('Begeni')
          .where('yorum_id', isEqualTo: commentId)
          .where('uye_id', isEqualTo: userId)
          .where("begeni",isEqualTo: "1")
          .get();
QuerySnapshot querySnapshot2 = await _firestore
          .collection('Begeni')
          .where('yorum_id', isEqualTo: commentId)
          .where('uye_id', isEqualTo: userId)
          .where("begeni",isEqualTo: "0")
          .get();
          if (querySnapshot.docs.isNotEmpty) {
        String likeId = querySnapshot.docs.first.id;
        await _firestore.collection('Begeni').doc(likeId).delete();
         DocumentSnapshot commentSnapshot = await _firestore.collection('Yorum').doc(commentId).get();
    int currentLikes = int.parse(commentSnapshot.get('begen'));

    currentLikes--;

    await _firestore.collection('Yorum').doc(commentId).update({
      'begen': currentLikes.toString(),
    });

        return;
        }
      await _firestore.collection('Begeni').add({
        'begeni': "1", 
        'uye_id': userId,
        'yorum_id': commentId,
      });
       DocumentSnapshot commentSnapshot = await _firestore.collection('Yorum').doc(commentId).get();
    int currentLikes = int.parse(commentSnapshot.get('begen'));

    currentLikes++;

    await _firestore.collection('Yorum').doc(commentId).update({
      'begen': currentLikes.toString(),
    });
      if (querySnapshot2.docs.isNotEmpty){
      String likeId2 = querySnapshot2.docs.first.id;
      await _firestore.collection('Begeni').doc(likeId2).delete();
       DocumentSnapshot commentSnapshot = await _firestore.collection('Yorum').doc(commentId).get();
    int currentLikes = int.parse(commentSnapshot.get('begenme'));

    currentLikes--;

    await _firestore.collection('Yorum').doc(commentId).update({
      'begenme': currentLikes.toString(),
    });
      }

      
    
     


      print('like!');
    } catch (e) {
      print('Bir hata oluştu: $e');
    }
  }
    Future<void> dislikeComment(String commentId, String userId) async {
    try {


 
    
      QuerySnapshot querySnapshot = await _firestore
          .collection('Begeni')
          .where('yorum_id', isEqualTo: commentId)
          .where('uye_id', isEqualTo: userId)
          .where("begeni",isEqualTo: "0")
          .get();

          QuerySnapshot querySnapshot2 = await _firestore
          .collection('Begeni')
          .where('yorum_id', isEqualTo: commentId)
          .where('uye_id', isEqualTo: userId)
          .where("begeni",isEqualTo: "1")
          .get();

          if (querySnapshot.docs.isNotEmpty) {
        String likeId = querySnapshot.docs.first.id;
        await _firestore.collection('Begeni').doc(likeId).delete();

        print('Dislike');
        DocumentSnapshot commentSnapshot = await _firestore.collection('Yorum').doc(commentId).get();
    int currentLikes = int.parse(commentSnapshot.get('begenme'));

    currentLikes--;

    await _firestore.collection('Yorum').doc(commentId).update({
      'begenme': currentLikes.toString(),
    });

         return;
      }
      await _firestore.collection('Begeni').add({
        'begeni': "0", 
        'uye_id': userId, 
        'yorum_id': commentId, 
        
      });
      DocumentSnapshot commentSnapshot = await _firestore.collection('Yorum').doc(commentId).get();
    int currentLikes = int.parse(commentSnapshot.get('begenme'));

    currentLikes++;

    await _firestore.collection('Yorum').doc(commentId).update({
      'begenme': currentLikes.toString(),
    });
     if (querySnapshot2.docs.isNotEmpty){
      String likeId2 = querySnapshot2.docs.first.id;
      await _firestore.collection('Begeni').doc(likeId2).delete();
      DocumentSnapshot commentSnapshot = await _firestore.collection('Yorum').doc(commentId).get();
    int currentLikes = int.parse(commentSnapshot.get('begen'));

    currentLikes--;

    await _firestore.collection('Yorum').doc(commentId).update({
      'begen': currentLikes.toString(),
    });

      }
     
      print('dislike!');
    } catch (e) {
      print('Bir hata oluştu: $e');
    }
  }


@override
  void initState() {
    super.initState();
    updateGoruntuCount();
    getReviewCount();
    sirala();
    initializeUserReviewedBook();

    hasReviewedBook = checkUserReviewedBook(widget.bookData.id);




  }
  Future<bool> checkUserReviewedBook(String bookId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore
              .instance
              .collection("Yorum")
              .where("uye_id",
                  isEqualTo: FirebaseAuth.instance.currentUser?.uid)
              .where("kitap_id", isEqualTo: bookId)
              .get();
if(querySnapshot.docs.first.exists){
  setState(() { value=true;});
  
}
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Yorum kontrolü sırasında bir hata oluştu: $e');
      return false; 
    }
  }

  Widget buildStarRating(double rating) {
    return RatingBar.builder(
      initialRating: rating,
      minRating: 0,
      direction: Axis.horizontal,
      allowHalfRating: true, 
      itemCount: 5,
      itemSize: 15,
      ignoreGestures: true,
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (double value) {},
    );
  }

  void updateGoruntuCount() {
    final DocumentReference<Object?> docRef = widget.bookData.reference;
    String currentGoruntuString = widget.bookData["goruntu"] ?? "0";
    int currentGoruntu = int.parse(currentGoruntuString);
    currentGoruntu = currentGoruntu + 1;

    String newGoruntu = currentGoruntu.toString();

    docRef.update({'goruntu': newGoruntu}).then((_) {
      setState(() {});
    }).catchError((error) {
      print("Hata: $error");
    });
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  void getReviewCount() {
    CollectionReference yorumlarCollection =
        FirebaseFirestore.instance.collection('Yorum');
    yorumlarCollection
        .where('kitap_id', isEqualTo: widget.bookData.id)
        .get()
        .then((QuerySnapshot querySnapshot) {
     
      setState(() {
        _incelemeSayisi = querySnapshot.size; 
      });
    }).catchError((error) {
      print("Hata: $error");
    });
  }

  Future<void> sirala() async {
    try {
      QuerySnapshot querySnapshot =
          await kitaplar.orderBy("puan", descending: true).get();

      List<QueryDocumentSnapshot> sortedBooks = querySnapshot.docs;

      for (int i = 0; i < sortedBooks.length; i++) {
        if (sortedBooks[i].id == hedefKitapId) {
          hedefKitapSirasi = i + 1;
          break; 
        }
      }
    } catch (error) {
      print("Hata: $error");
    }
  }

  late String hedefKitapId = widget.bookData.id; 
  late bool userReviewedBook;
  void initializeUserReviewedBook() async {
    userReviewedBook = await checkUserReviewedBook(widget.bookData.id);
  }

  int hedefKitapSirasi = -1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FutureBuilder<bool>(
          future: hasReviewedBook,
          builder: (context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Hata: ${snapshot.error}');
            } else {
              bool? hasReviewed = snapshot.data;
              if (hasReviewed != null) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                  margin: EdgeInsets.only(left: 50),
                  padding: EdgeInsets.only(
                    bottom: 15,
                    top: 15,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    color: Colors.transparent,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: EdgeInsets.only(left: 15, right: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                margin: EdgeInsets.only(right: 5),
                                child: FloatingActionButton(
                                  heroTag: null,
                                  backgroundColor: Colors.amber.shade800,
                                  onPressed: () async {
                                    userReviewedBook =
                                        await checkUserReviewedBook(
                                            widget.bookData.id);
                                    Widget nextPage = userReviewedBook
                                        ? EditReviewPage(
                                            bookId: widget.bookData.id,
                                            userId: FirebaseAuth
                                                .instance.currentUser!.uid,
                                          )
                                        : ReviewPage(
                                            bookId: widget.bookData.id,
                                          );
                                    int refresh = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => nextPage),
                                    );
                                    if (refresh == 1) {
                                      setState(() {
                                        value = true;
                                      });
                                    } else {
                                      setState(() {
                                        value = false;
                                      });
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        value
                                            ? "İncelemeyi düzenle"
                                            : "İnceleme yaz",
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      Icon(Icons.edit, size: 30),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: FloatingActionButton(
                                heroTag: null,
                                backgroundColor: Colors.white,
                                onPressed: () {
                                  selectedListIds.clear();
                                  showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Kitabı Bir Listeye Ekleyin',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  FutureBuilder<List<DocumentSnapshot>>(
                    future: getLists(),
                    builder: (context, snapshot) {
Set<String> newSelectedListIds = {};
  for (DocumentSnapshot list in snapshot.data??[]) {
   int a=1;

    List<dynamic>? bookIds = (list.data() as Map<String, dynamic>?)?['kitap_ids'];

    
     if(a==1){
if (bookIds != null && bookIds.contains(widget.bookData.id)) {

       
       if (!selectedListIds.contains(list.id)) {
      selectedListIds.add(list.id);
    }
                                     else if(selectedListIds.contains(list.id)){
selectedListIds.remove(list.id);
                                    }
    }
    a++;
     }

    
    
  }
  
selectedListIds.addAll(newSelectedListIds);


                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Hata: ${snapshot.error}');
                      } else {
                        List<DocumentSnapshot> lists =
                            snapshot.data ?? [];
                        return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: lists.map((list) {
          String listId = list.id;
          String listName = (list.data() as Map<String, dynamic>)['liste_ad'] ?? '';
          bool isSelected= isBookInOtherLists(widget.bookData.id, list); 
          bool isSelected2=false;
              
          return ListTile(
                              onTap: () {
                             
                                setState(() {
                                  
                                    
                                    if (!selectedListIds.contains(listId)) {
      selectedListIds.add(listId);
    }
                                     else if(selectedListIds.contains(listId)){
selectedListIds.remove(listId);
                                    }
                                    
                                  
                                });
                                print(selectedListIds);
                              },
                              title: Row(
                                children: [
                                  Icon(
                                    selectedListIds.contains(listId) ? Icons.check_box : Icons.check_box_outline_blank,
                                    color: selectedListIds.contains(listId) ? Colors.amber.shade800 : Colors.grey,
                                  ),
                                  SizedBox(width: 8),
                                  Text(listName),
                                ],
                              ),
                            );
        }).toList(),
      );
                      }
                    },
                  ),
                  SizedBox(height: 16),
                 Row(
                    children: [
Container(
  width: 200,
              padding: EdgeInsets.only(left: 40,right: 10),
  child: ElevatedButton(
                      onPressed: () {
                       
                          addOrRemoveBookFromSelectedLists(widget.bookData.id, selectedListIds);
                          Navigator.pop(context);
                         
                      },
                      style: ElevatedButton.styleFrom(
                         backgroundColor: Colors.amber.shade800, 
                         padding: EdgeInsets.symmetric(vertical: 15),
                         shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
                           
                       ),
                      child: Text('Kitabı Kaydet', style: TextStyle(
                             fontSize: 18, 
                             fontWeight: FontWeight.bold, 
                             color: Colors.white,
                           ),),
                    ),
),
                  Container(
                    width: 150,
              padding: EdgeInsets.only(left: 10,right: 10),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                         backgroundColor: Colors.amber.shade800, 
                         padding: EdgeInsets.symmetric(vertical: 15),
                         shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), 
      ),
                        
                       ),
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
                                  'Listeye İsim Ver',
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
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.amber.shade800, 
                       padding: EdgeInsets.symmetric(vertical: 15),
                       shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), 
    ),
                       
                     ),
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
            setState(() {});
            Navigator.pop(context); 
                                  },
                                  child: Container(padding: EdgeInsets.only(left: 15,right: 15),
                                    child: Text('Liste Oluştur',style: TextStyle(
                                                                 fontSize: 18, 
                                                                 fontWeight: FontWeight.bold, 
                                                                 color: Colors.white,
                                                               ),),
                                  ),),
                                
                              ],
                            ),
                          ),
                        );
                      },
                    );
                         
                      },
                      child: Text('Liste Oluştur',style: TextStyle(
                             fontSize: 18, 
                             fontWeight: FontWeight.bold, 
                             color: Colors.white,
                           ),),
                    ),
                  ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
                  },
                                child: Icon(
                                  Icons.add,
                                  size: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return Text('Veri alınamadı.');
              }
            }
          },
        ),
        backgroundColor: Colors.black,
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          title: Text('Kitap Detayı'),
        ),
        body: FutureBuilder(
            future: Future.wait([
              yazar.doc(widget.bookData['yazarID']).get(),
              kategori.doc(widget.bookData['kategoriID']).get(),
              yayinevi.doc(widget.bookData['yayineviID']).get(),
            ]),
            builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); 
              } else if (snapshot.hasError) {
                return Text('Hata: ${snapshot.error}');
              } else {
                List<DocumentSnapshot> documents = snapshot.data!;
                Map<String, dynamic> yazarData =
                    documents[0].data() as Map<String, dynamic>;
                Map<String, dynamic> kategoriData =
                    documents[1].data() as Map<String, dynamic>;
                Map<String, dynamic> yayineviData =
                    documents[2].data() as Map<String, dynamic>;

                return Container(
                    margin: EdgeInsets.only(left: 5),
                    child: SafeArea(
                        child: SingleChildScrollView(
                            child: Column(children: [
                      Container(
                        padding:
                            EdgeInsets.only(left: 10, right: 15, bottom: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            color: Colors.white),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                  height: 200,
                                  width: 100,
                                  child: Image(
                                    image:
                                        NetworkImage(widget.bookData["resim"]),
                                    fit: BoxFit.contain,
                                  )),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                margin: EdgeInsets.only(left: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.bookData['kitap_ad'],
                                      maxLines: 2,
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      yazarData['yazar_ad'] + " tarafından",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black26),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          kategoriData['kategori_ad'] +
                                              " • " +
                                              widget.bookData["sayfa_sayisi"],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black54),
                                        ),
                                        Icon(
                                          Icons.insert_drive_file_outlined,
                                          color: Colors.black45,
                                          size: 15,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        padding:
                            EdgeInsets.only(left: 10, right: 15, bottom: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            color: Colors.white),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              padding: EdgeInsets.only(
                                  left: 10, right: 15, bottom: 10, top: 10),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                color: Colors.amber.shade800,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.bookmark),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        "Sıralama NO." +
                                            hedefKitapSirasi.toString(),
                                        style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Icon(Icons.arrow_forward_ios_outlined)
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              padding: EdgeInsets.only(
                                left: 10,
                                right: 15,
                                bottom: 10,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        "Puan",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 5),
                                        child: Row(
                                          children: [
                                            Text(
                                              double.parse(
                                                      widget.bookData["puan"])
                                                  .toStringAsFixed(1),
                                              style: TextStyle(fontSize: 14),
                                            ), 
                                            Icon(
                                              Icons.star,
                                              size: 20,
                                              color: Colors.amber.shade800,
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text("Görüntülenme Sayısı",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600)),
                                      Text(widget.bookData["goruntu"],
                                          style: TextStyle(fontSize: 14))
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text("İnceleme Sayısı",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600)),
                                      Text(_incelemeSayisi.toString(),
                                          style: TextStyle(fontSize: 14))
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        padding:
                            EdgeInsets.only(left: 10, right: 15, bottom: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            color: Colors.white),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: (){
                                Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryPage(kategori: kategoriData["id"]),
      ),
    );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "#" + kategoriData['kategori_ad'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.arrow_forward_ios_rounded))
                                ],
                              ),
                            ),
                            ReadMoreText(
                              widget.bookData["ozet"],
                              trimLines: 3,
                              textAlign: TextAlign.start,
                              
                              trimMode: TrimMode.Line,
                              trimCollapsedText: " Daha Fazla ",
                              trimExpandedText: "",
                              moreStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800),
                              style: TextStyle(fontSize: 16, height: 1.7,fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 10),
                          padding:
                              EdgeInsets.only(left: 10, right: 15, bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            color: Colors.white,
                          ),
                          child: Column(children: [
                            Container(
                              padding: EdgeInsets.only(bottom: 10, top: 10),
                              child: GestureDetector(
                                onTap: (){

                                    Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShowBookReviews(bookData: widget.bookData),
          ),
        );
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "İncelemeler",
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(_incelemeSayisi.toString(),style: TextStyle(fontWeight: FontWeight.bold,),),
                                        Icon(Icons.arrow_forward_ios),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('Yorum')
                                    .where("kitap_id",
                                        isEqualTo: widget.bookData.id)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                        
                                    return CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Hata: ${snapshot.error}');
                                  } else if (snapshot.data?.docs == Null) {
                                    return Container(
                                        color: Colors.black,
                                        child:
                                            Text("İlk İnceleme Yapan Sen Ol!"));
                                  } else {
                                    final reviews = snapshot.data!.docs;
                                    if (reviews.isEmpty) {
                                      return Container(
                                        child: Text(
                                          "İlk İnceleme Yapan Sen Ol!",
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      );
                                    } else {
                                      final reviews = snapshot.data!.docs;
                                      reviews.sort((a, b) => b["yapilma_t"]
                                          .compareTo(a["yapilma_t"]));

                                      return SizedBox(
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.5, 
                                        child: PageView.builder(
                                          controller: PageController(viewportFraction: 0.9),
                                          itemCount: reviews.length,
                                          itemBuilder: (context, index) {
                                            final reviewData = reviews[index]
                                                .data() as Map<String, dynamic>;
                                            final yapilmaT = DateTime.parse(
                                                reviewData["yapilma_t"]);
                                            final formattedDate =
                                                getRelativeDate(yapilmaT);
                                                

                                            return Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    FutureBuilder<
                                                        DocumentSnapshot>(
                                                      future: FirebaseFirestore
                                                          .instance
                                                          .collection("users")
                                                          .doc(reviewData[
                                                              'uye_id'])
                                                          .get(),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot.hasData) {
                                                          final userData =
                                                              snapshot.data!;

                                                          return Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
  margin: EdgeInsets.only(right: 15),
  width: 35,
  height: 35,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: Colors.blue, 
  ),
  child: userData["profil_foto"].isNotEmpty 
    ? ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Image.network(
          userData["profil_foto"],
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      )
    : Center(
        child: Text(
          userData["isim"][0].toUpperCase(), 
          style: TextStyle(
            color: Colors.white,
            fontSize: 20, 
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
),
                                                              GestureDetector(
                                                                onTap: (){
                                                                  Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShowReview(reviewData: reviews[index],),
          ),
        );
                                                                },
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Text(userData[
                                                                                "isim"]+" "+userData[
                                                                                "soyisim"] ??
                                                                            ""),
                                                                        SizedBox(
                                                                          width: MediaQuery.of(context).size.width -
                                                                              340,
                                                                        ),
                                                                        Text(
                                                                            formattedDate),
                                                                      ],
                                                                    ),
                                                                    Row(
                                                                      children: [

                                                                        buildStarRating(
                                                                            double.parse(
                                                                                reviewData["rate"])),
                                                                      ],
                                                                    ),
                                                                    userData["kategori"]!=""||userData["kategori"]!=null?
                                                                    Row(
                                                                      children: [
                                                                        Icon(Icons.category),
                                                                        Text(userData["kategori"]??""),
                                                                      ]
                                                                    ):Text(""),
                                                                    Container(
                                                                      width: 250,
                                                                      padding: EdgeInsets.only(
                                                                          top: 5,
                                                                          bottom:
                                                                              10),
                                                                      child: Text(
                                                                        reviewData[
                                                                                "yorum"] ??
                                                                            "",
                                                                        maxLines:
                                                                            3,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                        ),
                                                                        overflow:
                                                                            TextOverflow
                                                                                .ellipsis,
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      margin: EdgeInsets.only(top: 20),
                                                                      child: Row(
                                                                        children: [
                                                                          GestureDetector(
                                                                              onTap:
                                                                                  () {
                                                                                likeComment(reviews[index].id,
                                                                                    FirebaseAuth.instance.currentUser!.uid);
                                                                                  
                                                                                    
                                                                              },
                                                                              child:
                                                                                  Icon(Icons.thumb_up_alt_outlined)),
                                                                          Text(reviewData["begen"]),
                                                                          SizedBox(
                                                                            width:
                                                                                20,
                                                                          ),
                                                                          GestureDetector(
                                                                            onTap: (){
                                                                              dislikeComment(reviews[index].id,
                                                                                    FirebaseAuth.instance.currentUser!.uid);
                                                                                    
                                                                      
                                                                            },
                                                                              child:
                                                                                  Icon(Icons.thumb_down_alt_outlined)),
                                                                          Text(reviewData["begenme"]),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        } else {
                                                          return CircularProgressIndicator();
                                                        }
                                                      },
                                                    ),
                                                    SizedBox(height: 10),
                                                  ],
                                                ));
                                          },
                                        ),
                                      );
                                    }
                                  }
                                }),
                            Divider(
                              thickness: 2,
                              color: Colors.black26,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "İnceleme Yaz",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    if (await checkUserReviewedBook(
                                        widget.bookData.id)) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditReviewPage(
                                            bookId: widget.bookData.id,
                                            userId: FirebaseAuth
                                                .instance.currentUser!.uid,
                                          ),
                                        ),
                                      );
                                    } else {
                                      if (value) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ReviewPage(
                                              bookId: widget.bookData.id,
                                            ),
                                          ),
                                        );
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditReviewPage(
                                              bookId: widget.bookData.id,
                                              userId: FirebaseAuth
                                                  .instance.currentUser!.uid,
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 15,
                                        color: Colors.grey[500],
                                      ),
                                      Icon(
                                        Icons.star,
                                        size: 15,
                                        color: Colors.grey[500],
                                      ),
                                      Icon(
                                        Icons.star,
                                        size: 15,
                                        color: Colors.grey[500],
                                      ),
                                      Icon(
                                        Icons.star,
                                        size: 15,
                                        color: Colors.grey[500],
                                      ),
                                      Icon(
                                        Icons.star,
                                        size: 15,
                                        color: Colors.grey[500],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ])),
                      FutureBuilder(
                        future: kitaplar.get(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Hata: ${snapshot.error}');
                          } else {
                            List<QueryDocumentSnapshot> books =
                                snapshot.data!.docs;

                            books.removeWhere(
                                (book) => book.id == widget.bookData.id);

                            List<QueryDocumentSnapshot> sameCategoryBooks =
                                books
                                    .where((book) =>
                                        book['kategoriID'] ==
                                        widget.bookData['kategoriID'])
                                    .toList();

                            List<QueryDocumentSnapshot> sortedByRatingBooks =
                                List.from(books)
                                  ..sort(
                                      (a, b) => b['puan'].compareTo(a['puan']));
                            int hedefKitapSirasi =
                                sortedByRatingBooks.indexWhere(
                                        (book) => book.id == hedefKitapId) +
                                    1;

                            return Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  padding: EdgeInsets.only(
                                      left: 10, right: 15, bottom: 50, top: 15),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25)),
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                         
                           Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryPage(kategori: kategoriData["id"]),
      ),
    );
                        },
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding:
                                                  EdgeInsets.only(bottom: 10),
                                              child: Text(
                                                "Aynı Kategoriden",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text((sameCategoryBooks.length+1).toString(),style: TextStyle(fontWeight: FontWeight.bold,)),
                                                Icon(Icons.arrow_forward_ios_rounded),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      sameCategoryBooks.isEmpty
                                          ? Center(
                                              child: Text(
                                                  "Bu kategoriden başka kitap yok!"),
                                            )
                                          : Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 20),
                                              child: GridView.count(
                                                crossAxisSpacing: 10,
                                                mainAxisSpacing: 70,
                                                crossAxisCount: 4,
                                                shrinkWrap: true,
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                children: List.generate(
                                                    sameCategoryBooks.length,
                                                    (index) {
                                                  DocumentSnapshot document =
                                                      sameCategoryBooks[index];
                                                  Map<String, dynamic> data =
                                                      document.data() as Map<
                                                          String, dynamic>;

                                                  return GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              DetailPage(
                                                                  bookData:
                                                                      sameCategoryBooks[
                                                                          index]),
                                                        ),
                                                      );
                                                    },
                                                    child: Wrap(
                                                      alignment:
                                                          WrapAlignment.center,
                                                      children: [
                                                        SizedBox(
                                                          width: 100,
                                                          height: 90,
                                                          child: Image(
                                                            image: NetworkImage(
                                                                data["resim"]),
                                                            fit: BoxFit.contain,
                                                          ),
                                                        ),
                                                        Text(
                                                          data["kitap_ad"],
                                                          style: TextStyle(
                                                              fontSize: 15),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 2,
                                                          textAlign:
                                                              TextAlign.center,
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                }),
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  padding: EdgeInsets.only(
                                      left: 10, right: 15, bottom: 50, top: 15),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25)),
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: (){
                                   
                                          Navigator.push(context, MaterialPageRoute(builder:(context)=> SearchPage()));
                                        },
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding:
                                                  EdgeInsets.only(bottom: 10),
                                              child: Text(
                                                "Beğenebilecekleriniz",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Icon(Icons.arrow_forward_ios_rounded)
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(bottom: 20),
                                        child: GridView.count(
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 70,
                                          crossAxisCount: 4,
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          children: List.generate(8, (index) {
                                            DocumentSnapshot document =
                                                sortedByRatingBooks[index];
                                            Map<String, dynamic> data = document
                                                .data() as Map<String, dynamic>;
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        DetailPage(
                                                            bookData:
                                                                sortedByRatingBooks[
                                                                    index]),
                                                  ),
                                                );
                                              },
                                              child: Wrap(
                                                  alignment:
                                                      WrapAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width: 100,
                                                      height: 90,
                                                      child: Image(
                                                        image: NetworkImage(
                                                            data["resim"]),
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                    Text(
                                                      data["kitap_ad"],
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                      textAlign:
                                                          TextAlign.center,
                                                    )
                                                  ]),
                                            );
                                          }),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        padding: EdgeInsets.only(
                            left: 10, right: 15, bottom: 20, top: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Kitap Detayları",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                top: 15,
                                bottom: 10,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Yazar",
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black45,
                                        ),
                                      ),
                                      Text(
                                        yazarData["yazar_ad"],
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Text(
                                        "Kitap Dili",
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black45,
                                        ),
                                      ),
                                      Text(
                                        widget.bookData["dil"],
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Yayınevi",
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black45,
                                        ),
                                      ),
                                      Text(
                                        yayineviData["yayinevi_ad"],
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Text(
                                        "Basım Tarihi",
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black45,
                                        ),
                                      ),
                                      Text(
                                        widget.bookData["btarihi"],
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 150,
                      )
                    ]))));
              }
            }));
  }

  String getRelativeDate(DateTime yapilmaT) {
    final now = DateTime.now();
    final difference = now.difference(yapilmaT);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Şimdi';
    }
  }
}
