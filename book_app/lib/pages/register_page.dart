// ignore_for_file: prefer_const_constructors

import 'package:book_app/pages/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
//buraya daha sonra sevdiği türleri falan ekletebilrisin, bu bilgileri ayrı sayfalarda aldırabiklirsin falan fişman
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override

void dispose(){
  _emailController.dispose();
  _passwordController.dispose();
  _confirmPasswordController.dispose();
  _firstNameController.dispose();
  _lastNameController.dispose();
  super.dispose();
}

Future<void> signUp() async {
  // Alanların boş olup olmadığını ve şifrelerin uygunluğunu kontrol et
  if (_firstNameController.text.isEmpty ||
      _lastNameController.text.isEmpty ||
      _emailController.text.isEmpty ||
      _passwordController.text.isEmpty ||
      _confirmPasswordController.text.isEmpty) {
    // Boş alan varsa hata mesajı göster
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hata!'),
          content: Text('Lütfen tüm alanları doldurun.'),
          shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        );
      },
    );
    return;
  }

  // E-posta formatını kontrol et
  if (!isValidEmail(_emailController.text.trim())) {
    // Geçersiz e-posta adresi varsa hata mesajı göster
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hata!'),
          content: Text('Geçersiz e-posta adresi.'),
          shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        );
      },
    );
    return;
  }

  // Şifrelerin uyumunu kontrol et
  if (!passwordConfirmed()) {
    // Şifreler uyuşmuyorsa hata mesajı göster
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hata!'),
          content: Text('Girilen şifreler uyuşmuyor.'),
          shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        );
      },
    );
    return;
  }

  // Şifrenin minimum uzunluğunu kontrol et
  if (_passwordController.text.trim().length < 8) {
    // Şifre en az 8 karakter olmalıdır
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hata!'),
          content: Text('Şifre en az 8 karakter olmalıdır.'),
          shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        );
      },
    );
    return;
  }

  // Kullanıcıyı kaydet
  try {
    var user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    await FirebaseFirestore.instance.collection('users').doc(user.user?.uid).set({
      'isim': _firstNameController.text.trim(),
      'soyisim': _lastNameController.text.trim(),
      'eposta': _emailController.text.trim(),
      'profil_foto': "",
    });
  } catch (error) {
    // Hata durumunda genel hata mesajı göster
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hata!'),
          content: Text('Bir hata oluştu. Lütfen tekrar deneyin.'),
          shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        );
      },
    );
  }
}

// E-posta formatını kontrol eden yardımcı fonksiyon
bool isValidEmail(String email) {
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return emailRegex.hasMatch(email);
}





bool passwordConfirmed(){
  if(_passwordController.text.trim()==_confirmPasswordController.text.trim()){
    return true;
  }else{
    return false;
  }
}

  
  @override
  Widget build(BuildContext context) {
     return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              
                Text(
                  'Kaydol',
                  style: GoogleFonts.bebasNeue(fontSize: 52),
                ),
                SizedBox(height: 10),
                Text(
                  'Aşağıdan Kaydolabilirsin!',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 50),
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
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          hintText: '*İsim',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
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
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          hintText: '*Soyisim',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
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
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: '*Email',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
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
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: '*Şifre',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
  SizedBox(
                  height: 10,
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
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: '*Şifre Tekrar',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),


                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector(
                    onTap: signUp,
                    
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                          child: Text(
                        'Kaydol',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      )),
                    ),
                  ),
                ),
                Text("* ile işaretlenmiş alanlar doldurulması zorunludur"),
                SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Zaten üye misin?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: (){
                         Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginPage()));
                      },
                      child: Text(
                        ' Giriş yap',
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}