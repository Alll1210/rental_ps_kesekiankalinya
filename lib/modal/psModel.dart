class psModel{
  final String idBilik; // Sesuaikan dengan respons JSON
  final String jenisPs; // Sesuaikan dengan respons JSON
  final String daftarGame; // Sesuaikan dengan respons JSON
  final String harga; // Sesuaikan dengan respons JSON
  final String idUsers; // Sesuaikan dengan respons JSON
  final String nama; // Sesuaikan dengan respons JSON


  psModel(this.idBilik, this.jenisPs, this.daftarGame, this.harga, this.idUsers, this.nama);

// Jika diperlukan, tambahkan metode toJson dan fromJson di dalam kelas psModel
}