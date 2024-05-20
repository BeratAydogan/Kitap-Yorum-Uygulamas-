// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, non_constant_identifier_names, avoid_function_literals_in_foreach_calls, avoid_print, unused_local_variable, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'package:book_app/pages/admin_pages/admin_home_page.dart';
import 'package:book_app/pages/APIKitap.dart';
import 'package:book_app/pages/category_select.dart';
import 'package:book_app/pages/detail_page.dart';
import 'package:book_app/pages/profil_page.dart';
import 'package:book_app/pages/search_page2.dart';
import 'package:book_app/pages/settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';//
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController pageController = PageController();

  final CollectionReference yazar =
      FirebaseFirestore.instance.collection('Yazar');
  final CollectionReference kategori =
      FirebaseFirestore.instance.collection('Kategori');
  final CollectionReference yayinevi =
      FirebaseFirestore.instance.collection('Yayinevi');
  final CollectionReference kitaplar =
      FirebaseFirestore.instance.collection('Kitaplar');
      
  int pageNo = 0;
late String selectedListId = '';
  Timer? carouelTimer;
List<String> selectedListIds = [];
TextEditingController listNameController = TextEditingController();

  late String selectedCategory = "";
  late String selectedCategoryID="";
final CollectionReference listsCollection =
    FirebaseFirestore.instance.collection('Liste');


bool isBookInOtherLists(String bookId,  DocumentSnapshot<Object?> list) {
    List<dynamic>? bookIds = (list.data() as Map<String, dynamic>?)?['kitap_ids'];
    if (bookIds != null && bookIds.contains(bookId)) {
      return true;
    }else {
      return false;
    
  }
 
}



Future<void> _getSelectedCategory() async {
  try {
    // Kullanıcının seçtiği kategoriyi Firestore'dan al
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();

    if (userSnapshot.exists) {
      setState(() {
        // Kullanıcının seçtiği kategoriyi güncelle
        selectedCategory = userSnapshot.data()!['kategori'];
      });
    }

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('Kategori').get();

    // Kategori koleksiyonundaki her belgeyi kontrol edelim
    for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
        in querySnapshot.docs) {
      // Belgeden kategori adını alalım
      String categoryAd = documentSnapshot.data()['kategori_ad'];

      // Eğer kategori adı, aranan kategori adına eşitse, o kategorinin ID'sini döndürelim
      if (categoryAd == selectedCategory) {
        setState(() {
                  selectedCategoryID=documentSnapshot["id"];
        });
      }
    }

    // Belirtilen kategori adına sahip bir kategori bulunamazsa null döndürelim
  } catch (e) {
    print("Error getting selected category: $e");
    // Hata durumunda null döndürelim veya bir istisna fırlatalım
  }
}




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


void updateRatings() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Kitaplar').get();
  List<QueryDocumentSnapshot> books = snapshot.docs;
  books.forEach((book) async {
    String bookId = book.id;
    Map<String, dynamic> data = book.data() as Map<String, dynamic>;
    if (data['goruntu'] == null || data['goruntu'] == 0) {
      await FirebaseFirestore.instance.collection('Kitaplar').doc(bookId).update({'puan': "0"});
    }
  });
}


  Timer getTimer() {
    return Timer.periodic(const Duration(seconds: 3), (timer) {
      if (pageNo == 7) {
        pageNo = 0;
      }
      pageController.animateToPage(pageNo,
          duration: const Duration(seconds: 3), curve: Curves.easeInOutCirc);
      pageNo++;
    });
  }



  @override
  void initState() {
    pageController = PageController(initialPage: 0, viewportFraction: 0.85);
    carouelTimer = getTimer();
    super.initState();
        _getSelectedCategory();

  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      endDrawer: const NavigationDrawer(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: AppBar(
          leading: Padding(
            padding: EdgeInsets.only(left: 15),
            child: IconButton(
                onPressed: () {
                  
                },
                icon: Icon(
                  Icons.menu_book_sharp,
                  color: Colors.white,
                  size: 50,
                )),
          ),
          centerTitle: true,
          backgroundColor: Colors.black87,
          title: SizedBox(
            height: 40,
            width: 300,
            child: Padding(
              padding: EdgeInsets.only(top: 0, left: 5, right: 10),
              child: TextFormField(
                readOnly: true,
                onTap: () {
                  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchPage2(),
      ),
    );   
                },
                obscureText: false,
                decoration: InputDecoration(
                  labelText: 'Arama Yap',
                  alignLabelWithHint: false,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(width: 1, color: Colors.amber),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                  ),
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                margin: EdgeInsets.only(left: 10),
                child: Builder(
                    builder: (context) => IconButton(
                          onPressed: () {
                            Scaffold.of(context).openEndDrawer();
                          },
                          icon: Icon(
                            Icons.menu,
                            color: Colors.white,
                          ),
                        )),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
      body: StreamBuilder<QuerySnapshot>(
          stream: kitaplar.orderBy('puan',descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List bookList = snapshot.data!.docs;
              return Container(
                margin: EdgeInsets.only(left: 18),
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(children: [
                      Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.only(bottom: 5),
                          child: Text(
                            "En iyi Değerlendirme",
                            style: GoogleFonts.bebasNeue(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white
          ) 
                          )),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: PageView.builder(
                          controller: pageController,
                          onPageChanged: (value) {
                            setState(
                              () {
                                pageNo = value;
                              },
                            );
                          },
                          itemCount: 8,
                          itemBuilder: (context, index) {
                            DocumentSnapshot document = bookList[index];

                            Map<String, dynamic> data =
                                document.data() as Map<String, dynamic>;

                            return FutureBuilder(
                              future: kategori.doc(data['kategoriID']).get(),
                              builder: (context, d) {
                                if (d.hasError) {
                                  return Text('Hata: ${d.error}');
                                } else {
                                  Map<String, dynamic>? categoryData;
                                  if (d.data != null && d.data!.exists) {
                                    categoryData =
                                        d.data!.data() as Map<String, dynamic>;
                                  }

                                  if (categoryData == null ||
                                      data['kitap_ad'] == null ||
                                      categoryData['kategori_ad'] == null) {
                                    return Text('Veri eksik veya hatalı');
                                  }

                                  return AnimatedBuilder(
                                    animation: pageController,
                                    builder: (context, child) {
                                      return child!;
                                    },
                                    child: GestureDetector(
                                      onTap: (){
                                        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(bookData: bookList[index]),
          ),
        );

                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(left: 20),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          color: Colors.white,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: 300,
                                              width: 300,
                                              margin: EdgeInsets.all(20.0),
                                              child: Image(
                                                image: NetworkImage(
                                                    bookList[index]['resim']),
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                            Text(
                                              '${data['kitap_ad']}',
                                               maxLines: 1,
                                      overflow: TextOverflow.clip,
                                              style: TextStyle(
                                                fontSize: 22,
                                                color: Colors.black,
                                              ),
                                            ),
                                            RatingBar.builder(
                  initialRating: double.parse( data["puan"]),
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 20,
                        ignoreGestures: true,

                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ), onRatingUpdate: (double value) {  },
                 
                ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                      Container(
  margin: EdgeInsets.only(top: 30),
  padding: EdgeInsets.only(left: 10, right: 15, bottom: 10),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(25)),
    color: Colors.white,
  ),
  height: 350,
  child: Column(
    children: [
      SizedBox(
        height: 15,
      ),
      Container(
        padding: EdgeInsets.only(left: 10),
        alignment: Alignment.centerLeft,
        child: Text(
          "Sevdiğiniz Kategoriden",
          style: GoogleFonts.bebasNeue(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          )
         
        ),
      ),
      SizedBox(
        height: 20,
      ),

      
      FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('Kitaplar')
            .where('kategoriID', isEqualTo: selectedCategoryID) // Seçilen kategoriye göre kitapları filtrele
            .limit(8)
            .get(),
        builder: (context, snapshot) {
            if (snapshot.hasError) {
            // Hata oluşursa, hata mesajı gösterilebilir
            return Text('Hata: ${snapshot.error}');
          } 
          
          else {
            // Veriler başarıyla alındıysa, GridView ile kitapları listele
            List<DocumentSnapshot> bookList = snapshot.data!.docs;
            return GridView.count(
              mainAxisSpacing: 40,
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: List.generate(bookList.length, (index) {
                DocumentSnapshot document = bookList[index];
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailPage(bookData: bookList[index]),
                      ),
                    );
                  },
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 90,
                        child: Image(
                          image: NetworkImage(data["resim"]),
                          fit: BoxFit.contain,
                        ),
                      ),
                      Text(
                        data["kitap_ad"],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                );
              }),
            );
          }
        },
      ),
    ],
  ),
),
                      Container(
                        margin: EdgeInsets.only(top: 30),
                        padding:
                            EdgeInsets.only(left: 10, right: 15, bottom: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            color: Colors.white),
                        child: Column(
                          children: [
                            Container(
                              alignment: Alignment.topLeft,
                              padding: const EdgeInsets.only(
                                  top: 15, bottom: 5, left: 10),
                              child: Text(
                                "Beğenebilecekleriniz",
                                style:  GoogleFonts.bebasNeue(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          )
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              physics: ScrollPhysics(),
                              itemCount: bookList.length,
                              itemBuilder: (BuildContext context, int index) {
                                DocumentSnapshot document = bookList[index];

                                Map<String, dynamic> data =
                                    document.data() as Map<String, dynamic>;

                                return FutureBuilder(
                                  future: Future.wait([
                                    yazar.doc(data['yazarID']).get(),
                                    kategori.doc(data['kategoriID']).get(),
                                    yayinevi.doc(data['yayineviID']).get(),
                                  ]),
                                  builder: (context,
                                      AsyncSnapshot<List<DocumentSnapshot>>
                                          snapshot) {
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    }
                                    if (!snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return Text('Data not found');
                                    }
    
                                    Map<String, dynamic> authorData =
                                        snapshot.data![0].data()
                                            as Map<String, dynamic>;
                                    String authorName =
                                        authorData['yazar_ad'] ?? 'Unknown';

                                    Map<String, dynamic> categoryData =
                                        snapshot.data![1].data()
                                            as Map<String, dynamic>;
                                    String categoryName =
                                        categoryData['kategori_ad'] ??
                                            'Unknown';

                                    Map<String, dynamic> publisherData =
                                        snapshot.data![2].data()
                                            as Map<String, dynamic>;
                                    String publisherName =
                                        publisherData['yayinevi_ad'] ??
                                            'Unknown';




                                  
                                    return GestureDetector(
                                      onTap: (){
                                        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(bookData: bookList[index]),
          ),
        );
                                      },
                                      child: Container(
                                          margin: EdgeInsets.only(top: 20),
                                          height: 100,
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 60,
                                                margin:
                                                    EdgeInsets.only(right: 15),
                                                child: Image(
                                                  image:
                                                      NetworkImage(data['resim']),
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "#$categoryName",
                                                      style: TextStyle(
                                                          color: Colors.black45,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                      data["kitap_ad"],
                                                      maxLines: 1,
                                                      overflow: TextOverflow.clip,
                                                    ),
                                                    Text(authorName,
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black45)),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          data["dil"] + " • ",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black45),
                                                        ),
                                                        Icon(
                                                          Icons
                                                              .insert_drive_file_outlined,
                                                          color: Colors.black45,
                                                          size: 15,
                                                        ),
                                                        Text(data["sayfa_sayisi"],
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black45))
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: (){
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
if (bookIds != null && bookIds.contains(document.id)) {

       
       if (!selectedListIds.contains(list.id)) {
      selectedListIds.add(list.id);
    }
                                     else if(selectedListIds.contains(list.id)){
selectedListIds.remove(list.id);
                                    }
    }
    a++;
     }

    
    
  }//her tıkaldığımda tekrar ekliyor buna çare bul
  
selectedListIds.addAll(newSelectedListIds);


                      if (snapshot.hasError) {
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
          bool isSelected= isBookInOtherLists(document.id, list); 
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
              padding: EdgeInsets.only(left: 10,right: 10),
  child: ElevatedButton(
                      onPressed: () {
                       
                          addOrRemoveBookFromSelectedLists(document.id, selectedListIds);
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
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.black,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    3))),
                                                    child: Icon(
                                                      size: 25,
                                                      color: Colors.white,
                                                      Icons.add,
                                                    )),
                                              )
                                            ],
                                          )),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              );
            } else {
              return Text('No book');
            }
          }),
    );
  }
}

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({super.key});
  @override
  Widget build(BuildContext context) => Drawer(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildHeader(context),
              buildMenuItems(context),
            ],
          ),
        ),
      );
}

bool userControl() {
  if (FirebaseAuth.instance.currentUser?.email == 'berataydogan@gmail.com') {
    return true;
  } else {
    return false;
  }
}

final CollectionReference<Map<String, dynamic>> user =
    FirebaseFirestore.instance.collection("users");
Widget buildHeader(BuildContext context) => StreamBuilder<Object>(
    stream: user.snapshots(),
    builder: (context, snapshot) {
      
      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }
      QuerySnapshot<Map<String, dynamic>>? userData =
          snapshot.data! as QuerySnapshot<Map<String, dynamic>>?;
      List<QueryDocumentSnapshot<Map<String, dynamic>>> userList =
          userData!.docs;
           String isim="?";
      return SizedBox(
        width: double.infinity,
        height: 300,
        child: ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: userList.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> userData = userList[index].data();
           isim=userData["isim"];
            if (userList[index].id == FirebaseAuth.instance.currentUser!.uid) {
              return Material(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                
                child: InkWell(
                  onTap: () {
                     Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ProfilPage()),
                );
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                        top: 24 + MediaQuery.of(context).padding.top,
                        bottom: 24),
                    child: Column(
                      children: [
                        CircleAvatar(
  radius: 50,
  child: userData["profil_foto"]!.isNotEmpty 
      ? ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Image.network(userData["profil_foto"]!, fit: BoxFit.contain),
        )
      : Container(
          decoration: BoxDecoration(
            color: Colors.amber.shade800,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              isim[0].toUpperCase(),
              style: TextStyle(fontSize: 28, color: Colors.white),
            ),
          ),
        ),
),
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          userData["isim"]+" "+userData["soyisim"],
                          style: TextStyle(fontSize: 28, color: Colors.black),
                        ),
                        Text(
                          userData["eposta"],
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return Text("");
          },
        ),
      );
    });
Widget buildMenuItems(BuildContext context) => Container(
      padding: EdgeInsets.all(24),
      child: Wrap(
        runSpacing: 16,
        children: [
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text("Ayarlar"),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SettingsPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text("Kategori Değiştir"),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>CategorySelectPage()));
            },
          ),
          SizedBox(height: 20,),
          Divider(color: Colors.black54),
          Visibility(
            visible: userControl(),
            child: ListTile(
              title: Text("Kitap Ekle"),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => Deneme()),
                );
              },
              leading: Icon(Icons.add),
            ),
          ),
          Visibility(
              visible: userControl(),
              child: ListTile(
                title: Text("Admin Sayfası"),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => AdminHomePage()),
                  );
                },
                leading: Icon(Icons.settings),
              )),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Çıkış Yap"),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
