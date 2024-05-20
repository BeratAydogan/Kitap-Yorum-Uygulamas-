// ignore_for_file: unnecessary_null_comparison, prefer_const_constructors, empty_catches


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ShowReview extends StatefulWidget {
  final DocumentSnapshot<Object?> reviewData;
  const ShowReview({super.key, required this.reviewData});

  @override
  State<ShowReview> createState() => _ShowReviewState();
}

class _ShowReviewState extends State<ShowReview> {
  late DocumentSnapshot<Object?> userData;
  late DocumentSnapshot<Object?> bookData;
  late DocumentSnapshot<Object?> yazarData;
late DocumentSnapshot<Object?> kategoriData;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

String dislike="0";
String like="0";
late bool liked=false;
late bool disliked=false;
  @override
 void initState() {
  super.initState();
  fetchUserData();
  fetchBookData().then((_) {
    fetchKategoriData();
      fetchYazarData();

  });
 
  fetchLikeCount(widget.reviewData.id);
}
  Future<void> fetchUserData() async {
    String userId = widget.reviewData['uye_id'];
    DocumentSnapshot<Object?> userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    setState(() {
      userData = userDoc;
    });
  }



Future<void> fetchYazarData() async {
    String bookId = widget.reviewData['kitap_id'];
    DocumentSnapshot<Object?> bookDoc =
        await FirebaseFirestore.instance.collection('Kitaplar').doc(bookId).get();

    DocumentSnapshot<Object?> yazarDoc =
        await FirebaseFirestore.instance.collection('Yazar').doc(bookDoc["yazarID"]).get();

   
    setState(() {
      yazarData=yazarDoc;
    });
  }

Future<void> fetchKategoriData() async {
    String bookId = widget.reviewData['kitap_id'];
    DocumentSnapshot<Object?> bookDoc =
        await FirebaseFirestore.instance.collection('Kitaplar').doc(bookId).get();



    DocumentSnapshot<Object?> kategoriDoc =
        await FirebaseFirestore.instance.collection('Kategori').doc(bookDoc["kategoriID"]).get();
    setState(() {
     
     
      kategoriData=kategoriDoc;
    });
  }
  Future<void> fetchBookData() async {
    String bookId = widget.reviewData['kitap_id'];
    DocumentSnapshot<Object?> bookDoc =
        await FirebaseFirestore.instance.collection('Kitaplar').doc(bookId).get();

    setState(() {
      bookData = bookDoc;
    });
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
 Future<void> likeComment(String commentId, String userId) async {
    try {

      

        QuerySnapshot querySnapshot = await _firestore
          .collection('Begeni')
          .where('yorum_id', isEqualTo: commentId)
          .where('uye_id', isEqualTo: userId)
          .where("begeni",isEqualTo: "1")
          .get();
          setState(() {
      liked = querySnapshot.docs.isNotEmpty;
    });
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
    setState(() {
      currentLikes--;
    });
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
    setState(() {
      currentLikes++;
    });
    await _firestore.collection('Yorum').doc(commentId).update({
      'begen': currentLikes.toString(),
    });
      if (querySnapshot2.docs.isNotEmpty){
      String likeId2 = querySnapshot2.docs.first.id;
      await _firestore.collection('Begeni').doc(likeId2).delete();
       DocumentSnapshot commentSnapshot = await _firestore.collection('Yorum').doc(commentId).get();
    int currentLikes = int.parse(commentSnapshot.get('begenme'));
    setState(() {
      currentLikes--;
    });
    await _firestore.collection('Yorum').doc(commentId).update({
      'begenme': currentLikes.toString(),
    });
      }

      
    
     


      fetchLikeCount(commentId);
    } catch (e) {
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
setState(() {
      disliked = querySnapshot.docs.isNotEmpty;
    });          QuerySnapshot querySnapshot2 = await _firestore
          .collection('Begeni')
          .where('yorum_id', isEqualTo: commentId)
          .where('uye_id', isEqualTo: userId)
          .where("begeni",isEqualTo: "1")
          .get();
          if (querySnapshot.docs.isNotEmpty) {
        String likeId = querySnapshot.docs.first.id;
        await _firestore.collection('Begeni').doc(likeId).delete();

        DocumentSnapshot commentSnapshot = await _firestore.collection('Yorum').doc(commentId).get();
    int currentLikes = int.parse(commentSnapshot.get('begenme'));
    setState(() {
      currentLikes--;
    });
    
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
setState(() {
      currentLikes++;
    });    await _firestore.collection('Yorum').doc(commentId).update({
      'begenme': currentLikes.toString(),
    });
     if (querySnapshot2.docs.isNotEmpty){
      String likeId2 = querySnapshot2.docs.first.id;
      await _firestore.collection('Begeni').doc(likeId2).delete();
      DocumentSnapshot commentSnapshot = await _firestore.collection('Yorum').doc(commentId).get();
    int currentLikes = int.parse(commentSnapshot.get('begen'));
    setState(() {
      currentLikes--;
    });
    await _firestore.collection('Yorum').doc(commentId).update({
      'begen': currentLikes.toString(),
    });

      }
     
      fetchLikeCount(commentId);
    } catch (e) {
    }
  }


Future<void> fetchLikeCount(String commentId) async {
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
 

  @override
  Widget build(BuildContext context) {
   final yapilmaT = DateTime.parse(widget.reviewData["yapilma_t"]);
    return Scaffold(
      appBar: AppBar(
        title: Text("İnceleme"),
      ),
      backgroundColor: Colors.black,
      body: Container(
        margin: EdgeInsets.only(left: 10,right: 10,top: 10),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
          
                Container(
                            padding:
                                EdgeInsets.only(left: 10, right: 15, bottom: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(25)),
                                color: Colors.white),
                            child: bookData != null || yazarData != null || kategoriData != null? Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: SizedBox(
                                      height: 200,
                                      width: 100,
                                      child: Image(
                                        image:
                                            NetworkImage(bookData["resim"]),
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
                                          bookData['kitap_ad'],
                                          maxLines: 2,
                                          overflow: TextOverflow.clip,
                                          style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(yazarData["yazar_ad"]+
                                          " tarafından",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 16, color: Colors.black26),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                           kategoriData["kategori_ad"]+
                                                  " • " +
                                                  bookData["sayfa_sayisi"],
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
                            ):CircularProgressIndicator() 
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            padding:
                                EdgeInsets.only(left: 10, right: 15, bottom: 10,top: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(25)),
                                color: Colors.white),
                            child:Row(
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
  child: userData["profil_foto"] != ""
      ? ClipOval(
          child: Image.network(
            userData["profil_foto"],
            width: 35,
            height: 35,
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
                                                              Column(
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
                                                                            300,
                                                                      ),
                                                                      Text(
                                                                          getRelativeDate(yapilmaT)),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      buildStarRating(
                                                                          double.parse(
                                                                              widget.reviewData["rate"])),
                                                                    ],
                                                                  ),
                                                                  Container(
                                                                    width: 250,
                                                                    padding: EdgeInsets.only(
                                                                        top: 5,
                                                                        bottom:
                                                                            10),
                                                                    child: Text(
                                                                      widget.reviewData[
                                                                              "yorum"] ??
                                                                          "",
                                                                      maxLines:
                                                                          10,
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
                                                                              likeComment(widget.reviewData.id,
                                                                                  FirebaseAuth.instance.currentUser!.uid);
                                                                                setState(() {
                              });
                                                                                  
                                                                            },
                                                                            child:
                                                                                Icon(Icons.thumb_up_alt_outlined,color: liked == true ? Colors.blue : Colors.grey )),
                                                                        Text(widget.reviewData["begen"]),
                                                                        SizedBox(
                                                                          width:
                                                                              20,
                                                                        ),
                                                                        GestureDetector(
                                                                          onTap: (){
                                                                            dislikeComment(widget.reviewData.id,
                                                                                  FirebaseAuth.instance.currentUser!.uid);
                                                                                  
                                                                    setState(() {
                              });
                                                                          },
                                                                            child:
                                                                                Icon(Icons.thumb_down_alt_outlined,color: disliked == true ? Colors.blue : Colors.grey)),
                                                                        Text(widget.reviewData["begenme"]),
                                                                      ],
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ],
                                                          )
                          ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
