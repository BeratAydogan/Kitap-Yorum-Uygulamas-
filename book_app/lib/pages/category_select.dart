import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategorySelectPage extends StatefulWidget {
  const CategorySelectPage({super.key});

  @override
  _CategorySelectPageState createState() => _CategorySelectPageState();
}

class _CategorySelectPageState extends State<CategorySelectPage> {
  late List<String> categories = [];
  late List<String> filteredCategories = [];
  late String selectedCategory = "";

  @override
  void initState() {
    super.initState();
    _getCategories();
  }

  Future<void> _getCategories() async {
    try {
      // Kategorileri Firestore'dan al
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('Kategori').get();
      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          // Kategoriler listesini güncelle
          categories = querySnapshot.docs
              .map((doc) => doc['kategori_ad'] as String)
              .toList();
          // Filtrelenmiş kategoriler listesini de güncelle
          filteredCategories = List.from(categories);
        });
      }
    } catch (e) {
      print("Error getting categories: $e");
    }
  }

  void _filterCategories(String query) {
    setState(() {
      // Kategorileri filtreye göre güncelle
      filteredCategories = categories
          .where((category) =>
              category.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _selectCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
  
  }

  void _saveCategoryToUser(String category) async {
    try {
      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      await userDoc.update({'kategori': category});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kategori kaydedildi: $category'),
        ),
      );
    } catch (e) {
      print('Error saving category: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lütfen bir kategori seçiniz.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: TextField(
          onChanged: _filterCategories,
          decoration: InputDecoration(
            icon: Icon(Icons.search),
            hintText: 'Kategori Ara',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.black54),
          ),
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
        padding: EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 15),
        margin: EdgeInsets.only(top: 20),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: filteredCategories.length,
          itemBuilder: (BuildContext context, int index) {
            final category = filteredCategories[index];
            return InkWell(
              onTap: () {
                _selectCategory(category);
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: category == selectedCategory
                      ? Colors.amber[400] // Seçili kategori için farklı bir renk
                      : Colors.amber[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    category,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: category == selectedCategory
                          ? Colors.white // Seçili kategori için beyaz metin rengi
                          : Colors.black,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _saveCategoryToUser(selectedCategory);
        },
        child: Icon(Icons.save),
      ),
    );
  }
}
