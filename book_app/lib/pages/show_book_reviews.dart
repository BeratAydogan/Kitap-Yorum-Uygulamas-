// ignore_for_file: prefer_const_constructors, empty_catches

import 'package:book_app/pages/show_review.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ShowBookReviews extends StatefulWidget {
  final DocumentSnapshot<Object?> bookData;
  
  const ShowBookReviews({super.key, required this.bookData});

  @override
  State<ShowBookReviews> createState() => _ShowBookReviewsState();
}

class _ShowBookReviewsState extends State<ShowBookReviews> {




  late DocumentSnapshot<Object?> userData;
  late DocumentSnapshot<Object?> bookData;
  late DocumentSnapshot<Object?> yazarData;
late DocumentSnapshot<Object?> kategoriData;
String dislike="0";
String like="0";




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
  void initState() {
  super.initState();
 
    fetchKategoriData();
      fetchYazarData();

  
 

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
 



Future<void> fetchYazarData() async {
    
    DocumentSnapshot<Object?> bookDoc =
        await FirebaseFirestore.instance.collection('Kitaplar').doc(widget.bookData.id).get();

    DocumentSnapshot<Object?> yazarDoc =
        await FirebaseFirestore.instance.collection('Yazar').doc(bookDoc["yazarID"]).get();

   
    setState(() {
      yazarData=yazarDoc;
    });
  }

Future<void> fetchKategoriData() async {
   
    DocumentSnapshot<Object?> bookDoc =
        await FirebaseFirestore.instance.collection('Kitaplar').doc(widget.bookData.id).get();



    DocumentSnapshot<Object?> kategoriDoc =
        await FirebaseFirestore.instance.collection('Kategori').doc(bookDoc["kategoriID"]).get();
    setState(() {
     
     
      kategoriData=kategoriDoc;
    });
  }
  

 







  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.black,foregroundColor: Colors.white,
        title: Text(widget.bookData["kitap_ad"],style: TextStyle(color: Colors.white),),
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
          
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
                          )
                        ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Yorum')
                    .where('kitap_id', isEqualTo: widget.bookData.id)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Hata: ${snapshot.error}'),
                    );
                  } else if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('Bu kitaba henüz yorum yapılmamış.'),
                    );
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot yorumSnapshot = snapshot.data!.docs[index];
                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(yorumSnapshot['uye_id'])
                              .get(),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                              
                            } else if (userSnapshot.hasError) {
                              return Text("Hata");
                              
                            } else {
                              var userData = userSnapshot.data!;
                              final yapilmaT = DateTime.parse(yorumSnapshot["yapilma_t"]);
                              return Container(
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
  child: userData["profil_foto"] != ""
    ? ClipOval(
      child: Image.network(
        userData["profil_foto"],
        width: 35,
        height: 35,
        fit: BoxFit.cover,
      ),
    )
    : Container(
     
  width: 35,
  height: 35,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: Colors.blue,),
      child: Center(
        child: Container(
          width: 35,
          height: 35,
          alignment: Alignment.center,
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
    ),
),                                GestureDetector(
                                                              onTap: (){
                                                                 Navigator.push(
                    context,
                    MaterialPageRoute(
          builder: (context) => ShowReview(reviewData: yorumSnapshot),
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
                                                                              "isim"]+" " +userData[
                                                                              "soyisim"]??
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
                                                                              yorumSnapshot["rate"])),
                                                                    ],
                                                                  ),
                                                                  Container(
                                                                    width: 250,
                                                                    padding: EdgeInsets.only(
                                                                        top: 5,
                                                                        bottom:
                                                                            10),
                                                                    child: Text(
                                                                      yorumSnapshot[
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
                                                                        
                                                                                Icon(Icons.thumb_up_alt_outlined),
                                                                                
                                                                        Text(yorumSnapshot["begen"]),
                                                                        SizedBox(
                                                                          width:
                                                                              20,
                                                                        ),
                                                                       
                                                                                Icon(Icons.thumb_down_alt_outlined),
                                                                        Text(yorumSnapshot["begenme"]),
                                                                      ],
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        )
                        );
                            }
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
