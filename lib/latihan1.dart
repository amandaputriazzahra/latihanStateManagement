import 'package:flutter/material.dart'; // Mengimpor library Material untuk membangun UI Flutter.
import 'package:http/http.dart'
    as http; // Mengimpor library http untuk melakukan permintaan HTTP.
import 'dart:convert'; // Mengimpor library dart:convert untuk mengonversi JSON.
import 'package:provider/provider.dart'; // Mengimpor library Provider untuk manajemen state.

class University {
  String name; // Deklarasi variabel string untuk nama universitas.
  String website; // Deklarasi variabel string untuk alamat website universitas.

  University(
      {required this.name,
      required this.website}); // Konstruktor untuk inisialisasi nama dan website universitas.
}

class UniversityProvider extends ChangeNotifier {
  late Future<List<University>>
      futureUniversities; // Variabel untuk menyimpan hasil fetch data universitas.
  late String url; // Variabel untuk menyimpan URL endpoint API.

  UniversityProvider() {
    // Konstruktor class UniversityProvider.
    url =
        "http://universities.hipolabs.com/search?country=Indonesia"; // URL default untuk mengambil data universitas.
    futureUniversities =
        fetchUniversities(); // Memanggil fungsi fetchUniversities() saat class diinisialisasi.
  }

  Future<List<University>> fetchUniversities() async {
    // Fungsi untuk mengambil data universitas dari API.
    final response =
        await http.get(Uri.parse(url)); // Melakukan permintaan GET ke URL API.

    if (response.statusCode == 200) {
      // Jika status code response adalah 200 (OK).
      List<dynamic> data = json.decode(
          response.body); // Mendekode JSON response menjadi List<dynamic>.
      List<University> universities =
          []; // Inisialisasi list untuk menyimpan objek University.

      for (var item in data) {
        // Looping untuk setiap item dalam data.
        universities.add(
          // Menambahkan objek University ke dalam list universities.
          University(
            name: item['name'], // Mengambil nilai 'name' dari JSON response.
            website: item['web_pages']
                [0], // Mengambil nilai 'web_pages' index 0 dari JSON response.
          ),
        );
      }

      return universities; // Mengembalikan list universities setelah selesai looping.
    } else {
      // Jika status code response bukan 200.
      throw Exception(
          'Failed to load universities'); // Melempar exception dengan pesan 'Failed to load universities'.
    }
  }

  void changeCountry(String country) {
    // Fungsi untuk mengubah negara pada URL API.
    url =
        "http://universities.hipolabs.com/search?country=$country"; // Mengubah URL API berdasarkan negara yang dipilih.
    futureUniversities =
        fetchUniversities(); // Mengambil ulang data universitas berdasarkan URL baru.
    notifyListeners(); // Memberitahu listener bahwa terjadi perubahan state.
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Method untuk membangun UI aplikasi.
    return ChangeNotifierProvider(
      // Widget untuk menyediakan class yang meng-extends ChangeNotifier ke widget-tree.
      create: (context) =>
          UniversityProvider(), // Membuat instance dari UniversityProvider saat aplikasi diinisialisasi.
      child: MaterialApp(
        // Widget utama MaterialApp.
        title: 'Univ ASEAN', // Judul aplikasi.
        home: Scaffold(
          // Widget Scaffold sebagai kerangka utama aplikasi.
          appBar: AppBar(
            // Widget AppBar sebagai app bar pada aplikasi.
            title: Text('Universitas di Negara ASEAN'), // Judul app bar.
            backgroundColor: const Color.fromARGB(
                255, 219, 227, 240), // Warna latar belakang app bar.
          ),
          body: UniversityList(), // Widget body aplikasi berisi UniversityList.
        ),
      ),
    );
  }
}

class UniversityList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Method untuk membangun UI daftar universitas.
    var universityProvider = Provider.of<UniversityProvider>(
        context); // Mendapatkan instance UniversityProvider dari Provider.

    return Column(
      // Widget Column untuk menata child secara vertikal.
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButtonFormField<String>(
            // Widget DropdownButtonFormField untuk dropdown negara.
            decoration: InputDecoration(
              labelText: 'Pilih Universitas',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey[200],
            ),
            items: <String>[
              // Item-item dropdown berupa negara-negara ASEAN.
              'Indonesia',
              'Singapore',
              'Malaysia',
              'Thailand',
              'Vietnam',
              'Philippines',
              'Myanmar',
              'Cambodia',
              'Laos',
              'Brunei'
            ].map((String value) {
              // Mapping item-item dropdown ke DropdownMenuItem.
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              // Event saat nilai dropdown berubah.
              if (newValue != null) {
                // Jika nilai dropdown tidak null.
                universityProvider.changeCountry(
                    newValue); // Memanggil fungsi changeCountry dari UniversityProvider.
              }
            },
          ),
        ),
        Expanded(
          // Widget Expanded untuk mengisi ruang yang tersedia.
          child: FutureBuilder<List<University>>(
            // Widget FutureBuilder untuk menangani Future<List<University>>.
            future: universityProvider
                .futureUniversities, // Future yang akan digunakan sebagai data builder.
            builder: (context, snapshot) {
              // Builder untuk membangun UI berdasarkan snapshot Future.
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Jika sedang loading data.
                return Center(
                  // Widget Center untuk posisi tengah.
                  child:
                      CircularProgressIndicator(), // Widget CircularProgressIndicator untuk indikator loading.
                );
              } else if (snapshot.hasError) {
                // Jika terjadi error saat fetching data.
                return Center(
                  // Widget Center untuk posisi tengah.
                  child: Text(
                      '${snapshot.error}'), // Widget Text untuk menampilkan pesan error.
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                // Jika tidak ada data atau data kosong.
                return Center(
                  // Widget Center untuk posisi tengah.
                  child: Text(
                      'No data available'), // Widget Text untuk menampilkan pesan no data.
                );
              } else {
                // Jika data tersedia.
                return ListView.separated(
                  // Widget ListView untuk menampilkan daftar universitas.
                  shrinkWrap:
                      true, // Membungkus list agar sesuai dengan content.
                  itemCount: snapshot.data!
                      .length, // Jumlah item dalam list sesuai data snapshot.
                  separatorBuilder: (BuildContext context, int index) =>
                      Divider(), // Widget Divider sebagai pemisah antar item.
                  itemBuilder: (context, index) {
                    // Builder untuk item-item dalam list.
                    return ListTile(
                      // Widget ListTile untuk item dalam list.
                      title: Text(
                          snapshot.data![index].name), // Judul universitas.
                      subtitle: Text(snapshot.data![index]
                          .website), // Subtitle berupa website universitas.
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

void main() {
  // Method main untuk menjalankan aplikasi Flutter.
  runApp(MyApp()); // Menjalankan aplikasi MyApp.
}
