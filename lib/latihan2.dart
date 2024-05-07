import 'package:flutter/material.dart'; // Mengimpor library Material untuk membangun UI Flutter.
import 'package:http/http.dart'
    as http; // Mengimpor library http untuk melakukan permintaan HTTP.
import 'dart:convert'; // Mengimpor library dart:convert untuk mengonversi JSON.
import 'package:flutter_bloc/flutter_bloc.dart'; // Mengimpor library flutter_bloc untuk manajemen state dengan BLoC.

class University {
  String name; // Deklarasi variabel string untuk nama universitas.
  String website; // Deklarasi variabel string untuk alamat website universitas.

  University(
      {required this.name,
      required this.website}); // Konstruktor untuk inisialisasi nama dan website universitas.
}

class UniversityCubit extends Cubit<List<University>> {
  // Class UniversityCubit yang meng-extends Cubit untuk manajemen state universitas.
  UniversityCubit()
      : super(
            []); // Konstruktor untuk inisialisasi state awal dengan list kosong.

  void fetchUniversities(String country) async {
    // Fungsi untuk mengambil data universitas dari API.
    String url =
        "http://universities.hipolabs.com/search?country=$country"; // URL API untuk mengambil data universitas berdasarkan negara.
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

      emit(
          universities); // Memancarkan (emit) list universities sebagai state baru.
    } else {
      // Jika status code response bukan 200.
      throw Exception(
          'Failed to load universities'); // Melempar exception dengan pesan 'Failed to load universities'.
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Univ ASEAN',
      home: BlocProvider(
        create: (context) =>
            UniversityCubit(), // Membuat instance UniversityCubit saat aplikasi diinisialisasi.
        child:
            UniversitiesPage(), // Widget UniversitiesPage sebagai halaman utama aplikasi.
      ),
    );
  }
}

class UniversitiesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Widget Scaffold sebagai kerangka utama aplikasi.
      appBar: AppBar(
        // Widget AppBar sebagai app bar pada aplikasi.
        title: Text(
          'Universitas di Negara ASEAN',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor:
            Color.fromARGB(255, 220, 222, 235), // Warna latar belakang app bar.
      ),
      body: Column(
        // Widget Column untuk menata child secara vertikal.
        children: [
          BlocBuilder<UniversityCubit, List<University>>(
            // Widget BlocBuilder untuk membangun UI berdasarkan state dari UniversityCubit.
            builder: (context, universityList) {
              // Builder untuk membangun UI berdasarkan state universityList.
              return Padding(
                // Widget Padding untuk memberi jarak pada child widget.
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
                    'Singapura',
                    'Malaysia',
                    'Thailand',
                    'Vietnam',
                    'Filipina',
                    'Myanmar',
                    'Kamboja',
                    'Laos',
                    'Brunei Darussalam'
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
                      context.read<UniversityCubit>().fetchUniversities(
                          newValue); // Memanggil fungsi fetchUniversities dari UniversityCubit.
                    }
                  },
                ),
              );
            },
          ),
          Expanded(
            // Widget Expanded untuk mengisi ruang yang tersedia.
            child: BlocBuilder<UniversityCubit, List<University>>(
              // Widget BlocBuilder untuk membangun UI berdasarkan state dari UniversityCubit.
              builder: (context, universityList) {
                // Builder untuk membangun UI berdasarkan state universityList.
                if (universityList.isEmpty) {
                  // Jika list universities kosong.
                  return Center(
                    // Widget Center untuk posisi tengah.
                    child:
                        CircularProgressIndicator(), // Widget CircularProgressIndicator untuk indikator loading.
                  );
                } else {
                  // Jika list universities tidak kosong.
                  return ListView.separated(
                    // Widget ListView untuk menampilkan daftar universitas.
                    shrinkWrap:
                        true, // Membungkus list agar sesuai dengan content.
                    itemCount: universityList
                        .length, // Jumlah item dalam list sesuai data universityList.
                    separatorBuilder: (BuildContext context, int index) =>
                        Divider(), // Widget Divider sebagai pemisah antar item.
                    itemBuilder: (context, index) {
                      // Builder untuk item-item dalam list.
                      return ListTile(
                        // Widget ListTile untuk item dalam list.
                        title: Text(
                            universityList[index].name), // Judul universitas.
                        subtitle: Text(universityList[index]
                            .website), // Subtitle berupa website universitas.
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  // Method main untuk menjalankan aplikasi Flutter.
  runApp(MyApp()); // Menjalankan aplikasi MyApp.
}
