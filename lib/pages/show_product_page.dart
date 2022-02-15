import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:productapp/models/product_model.dart';
import 'package:productapp/pages/add_product_page.dart';
import 'package:productapp/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowProductPage extends StatefulWidget {
  const ShowProductPage({Key? key}) : super(key: key);

  @override
  _ShowProductPageState createState() => _ShowProductPageState();
}

class _ShowProductPageState extends State<ShowProductPage> {
  List<ProductModel>? products;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    getList();
  }

  Future<String?> getList() async {
    products = [];
    var url =
        Uri.parse('https://laravel-backend-cs115.herokuapp.com/api/products');

    var reponse = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
    });

    var jsonString = jsonDecode(reponse.body);
    products = jsonString['payload']
        .map<ProductModel>((json) => ProductModel.fromJson(json))
        .toList();

    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Show Products'),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        children: [
          showButton(),
          showList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddProductPage(),
              )).then((value) => setState(() {}));
          // Move to Add Product Page
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget showButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {});
      },
      child: const Text('แสดงรายการ'),
    );
  }

  Widget showList() {
    return FutureBuilder(
      future: getList(),
      builder: (context, snapshot) {
        List<Widget> myList;

        if (snapshot.hasData) {
          var jsonString = jsonDecode(snapshot.data.toString());
          List<ProductModel>? products = jsonString['payload']
              .map<ProductModel>((json) => ProductModel.fromJson(json))
              .toList();
          // Convert snapshot.data to jsonString

          // Create List of Product by using Product Model

          // Define Widgets to myList
          myList = [
            Column(
              children: products!.map((item) {
                return Card(
                  child: ListTile(
                    onTap: () {
                      // Navigate to Edit Product
                    },
                    title: Text('${item.productName}'),
                    subtitle: Text('${item.price}'),
                    trailing: IconButton(
                      onPressed: () {
                        // Create Alert Dialog
                        var alertDialog = AlertDialog(
                          title: const Text('Delete Product Confirmation'),
                          content: Text(
                              'คุณต้องการลบสินค้า ${item.productName} ใช่หรือไม่'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('ยกเลิก')),
                            TextButton(
                                onPressed: () {
                                  deleteProduct(item.id)
                                      .then((value) => setState(() {}));
                                },
                                child: const Text(
                                  'ยืนยัน',
                                  style: TextStyle(color: Colors.red),
                                ))
                          ],
                        );

                        // Show Alert Dialog
                        showDialog(
                          context: context,
                          builder: (context) => alertDialog,
                        );
                      },
                      icon: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ];
        } else if (snapshot.hasError) {
          myList = [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('ข้อผิดพลาด: ${snapshot.error}'),
            ),
          ];
        } else {
          myList = [
            const SizedBox(
              child: CircularProgressIndicator(),
              width: 60,
              height: 60,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('อยู่ระหว่างประมวลผล'),
            )
          ];
        }

        return Center(
          child: Column(
            children: myList,
          ),
        );
      },
    );
  }

  Future<void> deleteProduct(int? id) async {
    // Call SharedPreference to get Token
    SharedPreferences prefs = await _prefs;
    var url = Uri.parse(
        'https://laravel-backend-cs115.herokuapp.com/api/products/$id');
    var response = await http.delete(url, headers: {
      HttpHeaders.authorizationHeader: 'Bearer ${prefs.getString('token')}',
    });

    if (response.statusCode == 200) {
      Navigator.pop(context);
    }
    // Define Laravel API for Deleting Produce

    // Request deleting product

    // Check Status Code, then pop to the previous
  }

  Future<void> logout() async {
    // Call SharedPreference to get Token
    final SharedPreferences prefs = await _prefs;
    var url =
        Uri.parse('https://laravel-backend-cs115.herokuapp.com/api/logout');

    var response = await http.post(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ${prefs.getString('token')}',
      },
    );

    if (response.statusCode == 200) {
      prefs.remove('user');
      prefs.remove('token');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    }
    // Define Laravel API for Logout

    // Request for logging out

    // Check Status Code, remove sharedpreference, then pop to the previous
  }
}
