# latihan-flutter-part-vii

Belajar membuat aplikasi yang bisa export dan import database

Halo para jagoan, part 7 akan menjelaskan bagaimana agar kita bisa melakukan export dan import database. Backup data sangatlah penting untuk meminimalisir kehilangan data maka alangkah baiknya backup dilakukan secara rutin sehingga jika ada aksi pada data, maka kita bisa import / restore database. daripada bingung. yuks download sourceCodenya..

untuk androidManifest.xml cukup tambahkan : 

    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />

untuk pubspec.yaml cukup tambahkan :
  path_provider: ^2.1.0
  sqflite: ^2.3.0
  permission_handler: ^11.3.1


selamat mencoba, semoga bermanfaat. Jika butuh dukungan, bisa kontak saya di Email : ferdianarief.arief@gmail.com

