// settings_screen.dart
import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/menu_grid_item.dart';
import '../widgets/sidebar_drawer.dart';
import '../widgets/admin_password_dialog.dart';
import '../utils/navigation_handler.dart';
import '../helpers/database_helper.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Navigate to different screens based on menu selection
  Future<void> _navigateToScreen(String screenId) async {
    switch (screenId) {
      case 'edit_profile':
        await NavigationHandler.navigateToScreen(context, 'profile');
        break;
      case 'printer_config':
        await NavigationHandler.navigateToScreen(context, 'printer');
        break;
      case 'export':
        // Require admin password before showing export options
        bool hasAdminAccess = await AdminPasswordDialog.show(
          context,
          'Export Data',
        );
        if (hasAdminAccess) {
          _showExportDialog();
        }
        break;
      case 'import':
        // Require admin password before showing import options
        bool hasAdminAccess = await AdminPasswordDialog.show(
          context,
          'Import Data',
        );
        if (hasAdminAccess) {
          _showImportDialog();
        }
        break;
    }

    // Refresh settings screen if needed
    if (mounted) {
      setState(() {});
    }
  }

  // Show printer configuration dialog
  void _showPrinterConfigDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.print, color: Colors.blue[600]),
              SizedBox(width: 8),
              Text('Konfigurasi Printer'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.bluetooth, color: Colors.blue),
                title: Text('Printer Bluetooth'),
                subtitle: Text('Konfigurasi printer via Bluetooth'),
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoonSnackBar('Konfigurasi Bluetooth Printer');
                },
              ),
              ListTile(
                leading: Icon(Icons.usb, color: Colors.green),
                title: Text('Printer USB'),
                subtitle: Text('Konfigurasi printer via USB'),
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoonSnackBar('Konfigurasi USB Printer');
                },
              ),
              ListTile(
                leading: Icon(Icons.wifi, color: Colors.orange),
                title: Text('Printer WiFi'),
                subtitle: Text('Konfigurasi printer via WiFi'),
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoonSnackBar('Konfigurasi WiFi Printer');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  // Show export options dialog (now requires admin authentication)
  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.file_upload, color: Colors.green[600]),
              SizedBox(width: 8),
              Text('Export Data'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.table_chart, color: Colors.green),
                title: Text('Export ke Excel'),
                subtitle: Text('Export data transaksi ke file Excel'),
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoonSnackBar('Export ke Excel');
                },
              ),
              ListTile(
                leading: Icon(Icons.description, color: Colors.red),
                title: Text('Export ke PDF'),
                subtitle: Text('Export laporan ke file PDF'),
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoonSnackBar('Export ke PDF');
                },
              ),
              ListTile(
                leading: Icon(Icons.code, color: Colors.blue),
                title: Text('Export ke CSV'),
                subtitle: Text('Export data ke file CSV'),
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoonSnackBar('Export ke CSV');
                },
              ),
              ListTile(
                leading: Icon(Icons.backup, color: Colors.purple),
                title: Text('Backup Database'),
                subtitle: Text('Backup seluruh database ke SQL'),
                onTap: () {
                  Navigator.pop(context);
                  _showBackupDialog();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  // Show import options dialog (now requires admin authentication)
  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.file_download, color: Colors.blue[600]),
              SizedBox(width: 8),
              Text('Import Data'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.table_chart, color: Colors.green),
                title: Text('Import dari Excel'),
                subtitle: Text('Import data produk dari file Excel'),
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoonSnackBar('Import dari Excel');
                },
              ),
              ListTile(
                leading: Icon(Icons.code, color: Colors.blue),
                title: Text('Import dari CSV'),
                subtitle: Text('Import data dari file CSV'),
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoonSnackBar('Import dari CSV');
                },
              ),
              ListTile(
                leading: Icon(Icons.restore, color: Colors.orange),
                title: Text('Restore Database'),
                subtitle: Text('Restore database dari backup SQL'),
                onTap: () {
                  Navigator.pop(context);
                  _showRestoreDialog();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  // Show backup confirmation dialog with SQL export functionality
  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.backup, color: Colors.purple[600]),
              SizedBox(width: 8),
              Text('Backup Database'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apakah Anda yakin ingin membuat backup database?',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[600],
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Informasi Backup:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• File akan disimpan dalam format SQL\n'
                      '• Lokasi: Downloads/POS_Backup/\n'
                      '• Nama file: pos_backup_[tanggal].sql\n'
                      '• Berisi semua data aplikasi',
                      style: TextStyle(fontSize: 11, color: Colors.blue[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _performDatabaseBackup();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[600],
                foregroundColor: Colors.white,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.backup, size: 16),
                  SizedBox(width: 8),
                  Text('Backup'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Perform database backup to SQL file
  Future<void> _performDatabaseBackup() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.purple[600]),
              SizedBox(height: 16),
              Text('Membuat backup database...'),
            ],
          ),
        ),
      );

      // Get directory for saving file
      Directory? directory;

      if (Platform.isAndroid) {
        // Try to get external storage directory first
        directory = await getExternalStorageDirectory();

        if (directory != null) {
          // Navigate to a more accessible location
          List<String> paths = directory.path.split('/');
          int androidIndex = paths.indexOf('Android');
          if (androidIndex != -1) {
            String basePath = paths.sublist(0, androidIndex).join('/');
            String downloadsPath = '$basePath/Download/POS_Backup';
            directory = Directory(downloadsPath);

            try {
              if (!await directory.exists()) {
                await directory.create(recursive: true);
              }
            } catch (e) {
              // If can't create in Downloads, use app directory
              directory = await getExternalStorageDirectory();
              if (directory != null) {
                directory = Directory('${directory.path}/POS_Backup');
                if (!await directory.exists()) {
                  await directory.create(recursive: true);
                }
              }
            }
          }
        }

        // Fallback to application documents directory
        if (directory == null) {
          directory = await getApplicationDocumentsDirectory();
          directory = Directory('${directory.path}/POS_Backup');
          if (!await directory.exists()) {
            await directory.create(recursive: true);
          }
        }
      } else {
        // For iOS
        directory = await getApplicationDocumentsDirectory();
        directory = Directory('${directory.path}/POS_Backup');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
      }

      if (directory == null || !await directory.exists()) {
        Navigator.pop(context);
        _showErrorSnackBar('Tidak dapat mengakses penyimpanan');
        return;
      }

      // Create filename with timestamp
      String timestamp = DateTime.now()
          .toString()
          .replaceAll(' ', '_')
          .replaceAll(':', '-')
          .split('.')[0];
      String fileName = 'pos_backup_$timestamp.sql';
      File backupFile = File('${directory.path}/$fileName');

      // Generate SQL backup content
      String sqlContent = await _generateSQLBackup();

      // Write to file
      await backupFile.writeAsString(sqlContent);

      Navigator.pop(context); // Close loading dialog

      // Show success dialog
      _showBackupSuccessDialog(backupFile.path, fileName);
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      print('Backup error: $e');
      _showErrorSnackBar('Gagal membuat backup: ${e.toString()}');
    }
  }

  // Generate SQL backup content
  Future<String> _generateSQLBackup() async {
    final db = DatabaseHelper();
    final now = DateTime.now();

    StringBuffer sql = StringBuffer();

    // Header
    sql.writeln('-- POS System Database Backup');
    sql.writeln('-- Generated on: $now');
    sql.writeln('-- SQLite Database Export');
    sql.writeln();

    try {
      // Backup business profile
      final profile = await db.getProfile();
      if (profile != null) {
        sql.writeln('-- Business Profile Data');
        sql.writeln('DELETE FROM business_profile;');
        sql.write('INSERT INTO business_profile (');
        sql.write(profile.keys.join(', '));
        sql.write(') VALUES (');
        sql.write(
          profile.values
              .map(
                (v) => v != null
                    ? "'${v.toString().replaceAll("'", "''")}'"
                    : 'NULL',
              )
              .join(', '),
        );
        sql.writeln(');');
        sql.writeln();
      }

      // Backup products
      final products = await db.getAllProducts();
      if (products.isNotEmpty) {
        sql.writeln('-- Products Data (${products.length} records)');
        sql.writeln('DELETE FROM products;');
        for (final product in products) {
          final productJson = product.toJson();
          sql.write('INSERT INTO products (');
          sql.write(productJson.keys.join(', '));
          sql.write(') VALUES (');
          sql.write(
            productJson.values
                .map(
                  (v) => v != null
                      ? "'${v.toString().replaceAll("'", "''")}'"
                      : 'NULL',
                )
                .join(', '),
          );
          sql.writeln(');');
        }
        sql.writeln();
      }

      // Backup transactions
      final transactions = await db.getAllTransactions();
      if (transactions.isNotEmpty) {
        sql.writeln('-- Transactions Data (${transactions.length} records)');
        sql.writeln('DELETE FROM transactions;');
        sql.writeln('DELETE FROM transaction_items;');

        for (final transaction in transactions) {
          // Insert transaction
          sql.writeln(
            'INSERT INTO transactions (id, date, total, status) VALUES (',
          );
          sql.writeln("  '${transaction.id}',");
          sql.writeln("  '${transaction.date.toIso8601String()}',");
          sql.writeln("  ${transaction.total},");
          sql.writeln("  '${transaction.status}'");
          sql.writeln(');');

          // Insert transaction items
          for (final item in transaction.items) {
            sql.writeln(
              'INSERT INTO transaction_items (transactionId, productId, productName, quantity, price) VALUES (',
            );
            sql.writeln("  '${transaction.id}',");
            sql.writeln("  '${item.productId}',");
            sql.writeln("  '${item.productName.replaceAll("'", "''")}',");
            sql.writeln("  ${item.quantity},");
            sql.writeln("  ${item.price}");
            sql.writeln(');');
          }
        }
        sql.writeln();
      }

      // Backup purchases
      final purchases = await db.getAllPurchases();
      if (purchases.isNotEmpty) {
        sql.writeln('-- Purchases Data (${purchases.length} records)');
        sql.writeln('DELETE FROM purchases;');
        for (final purchase in purchases) {
          final purchaseJson = purchase.toJson();
          sql.write('INSERT INTO purchases (');
          sql.write(purchaseJson.keys.join(', '));
          sql.write(') VALUES (');
          sql.write(
            purchaseJson.values
                .map(
                  (v) => v != null
                      ? "'${v.toString().replaceAll("'", "''")}'"
                      : 'NULL',
                )
                .join(', '),
          );
          sql.writeln(');');
        }
        sql.writeln();
      }

      // Backup inventory transactions
      final inventoryTransactions = await db.getAllInventoryTransactions();
      if (inventoryTransactions.isNotEmpty) {
        sql.writeln(
          '-- Inventory Transactions Data (${inventoryTransactions.length} records)',
        );
        sql.writeln('DELETE FROM inventory_transactions;');
        for (final invTransaction in inventoryTransactions) {
          final invJson = invTransaction.toJson();
          sql.write('INSERT INTO inventory_transactions (');
          sql.write(invJson.keys.join(', '));
          sql.write(') VALUES (');
          sql.write(
            invJson.values
                .map(
                  (v) => v != null
                      ? "'${v.toString().replaceAll("'", "''")}'"
                      : 'NULL',
                )
                .join(', '),
          );
          sql.writeln(');');
        }
        sql.writeln();
      }
    } catch (e) {
      sql.writeln('-- Error during backup: $e');
    }

    sql.writeln('-- End of backup');
    return sql.toString();
  }

  // Show backup success dialog
  void _showBackupSuccessDialog(String filePath, String fileName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600]),
            SizedBox(width: 8),
            Text('Backup Berhasil'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Database berhasil di-backup!'),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nama file:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    fileName,
                    style: TextStyle(fontSize: 11, fontFamily: 'monospace'),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Lokasi:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    filePath,
                    style: TextStyle(fontSize: 10, fontFamily: 'monospace'),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[600], size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'File dapat dibuka dengan aplikasi text editor atau database viewer',
                      style: TextStyle(fontSize: 10, color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
            ),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // Show restore confirmation dialog
  void _showRestoreDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red[600]),
              SizedBox(width: 8),
              Text('Restore Database'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red[600], size: 20),
                        SizedBox(width: 8),
                        Text(
                          'PERINGATAN!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Restore database akan menghapus SEMUA data yang ada saat ini dan menggantinya dengan data dari file backup SQL.',
                      style: TextStyle(fontSize: 12, color: Colors.red[700]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[600],
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Yang akan dihapus:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      '• Semua produk dan stok\n'
                      '• Semua transaksi penjualan\n'
                      '• Semua riwayat pembelian\n'
                      '• Semua data inventori\n'
                      '• Pengaturan profil bisnis',
                      style: TextStyle(fontSize: 11, color: Colors.blue[700]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Pilih file backup SQL untuk di-restore:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _selectRestoreFile();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.folder_open, size: 16),
                  SizedBox(width: 8),
                  Text('Pilih File'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Select and restore database file
  Future<void> _selectRestoreFile() async {
    try {
      // Get the backup directory
      Directory? backupDir = await _getBackupDirectory();

      if (backupDir == null || !await backupDir.exists()) {
        _showErrorSnackBar(
          'Folder backup tidak ditemukan. Buat backup terlebih dahulu.',
        );
        return;
      }

      // Get all SQL files from backup directory
      List<FileSystemEntity> files = await backupDir.list().toList();
      List<File> sqlFiles = files
          .where((file) => file is File && file.path.endsWith('.sql'))
          .map((file) => file as File)
          .toList();

      if (sqlFiles.isEmpty) {
        _showErrorSnackBar(
          'Tidak ada file backup SQL yang ditemukan di folder backup.',
        );
        return;
      }

      // Sort by date (newest first)
      sqlFiles.sort(
        (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
      );

      // Show file selection dialog
      _showFileSelectionDialog(sqlFiles);
    } catch (e) {
      _showErrorSnackBar('Error mencari file backup: ${e.toString()}');
    }
  }

  // Get backup directory
  Future<Directory?> _getBackupDirectory() async {
    try {
      if (Platform.isAndroid) {
        Directory? directory = await getExternalStorageDirectory();

        if (directory != null) {
          // Try to access Downloads/POS_Backup
          List<String> paths = directory.path.split('/');
          int androidIndex = paths.indexOf('Android');
          if (androidIndex != -1) {
            String basePath = paths.sublist(0, androidIndex).join('/');
            return Directory('$basePath/Download/POS_Backup');
          }

          // Fallback to app directory
          return Directory('${directory.path}/POS_Backup');
        }
      } else {
        Directory directory = await getApplicationDocumentsDirectory();
        return Directory('${directory.path}/POS_Backup');
      }
    } catch (e) {
      print('Error getting backup directory: $e');
    }
    return null;
  }

  // Show file selection dialog
  void _showFileSelectionDialog(List<File> sqlFiles) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.folder_open, color: Colors.blue[600]),
            SizedBox(width: 8),
            Text('Pilih File Backup'),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(maxHeight: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[600], size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ditemukan ${sqlFiles.length} file backup',
                        style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: sqlFiles.length,
                  itemBuilder: (context, index) {
                    File file = sqlFiles[index];
                    String fileName = file.path.split('/').last;
                    DateTime modifiedDate = file.lastModifiedSync();
                    String dateStr =
                        '${modifiedDate.day}/${modifiedDate.month}/${modifiedDate.year} ${modifiedDate.hour}:${modifiedDate.minute.toString().padLeft(2, '0')}';

                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.backup, color: Colors.green[600]),
                        title: Text(
                          fileName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dibuat: $dateStr',
                              style: TextStyle(fontSize: 10),
                            ),
                            Text(
                              'Ukuran: ${(file.lengthSync() / 1024).toStringAsFixed(1)} KB',
                              style: TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                        trailing: Icon(
                          Icons.restore,
                          color: Colors.orange[600],
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _confirmRestore(file.path);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
        ],
      ),
    );
  }

  // Confirm restore operation
  void _confirmRestore(String filePath) {
    String fileName = filePath.split('/').last;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.restore, color: Colors.orange[600]),
            SizedBox(width: 8),
            Text('Konfirmasi Restore'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('File yang dipilih:'),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                fileName,
                style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Text(
                'PERHATIAN: Operasi ini tidak dapat dibatalkan! Semua data saat ini akan hilang permanen.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Apakah Anda yakin ingin melanjutkan restore?',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performRestore(filePath);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.restore, size: 16),
                SizedBox(width: 8),
                Text('Ya, Restore'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Perform database restore
  Future<void> _performRestore(String filePath) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.orange[600]),
              SizedBox(height: 16),
              Text('Menghapus data lama...'),
            ],
          ),
        ),
      );

      // Read SQL file
      File sqlFile = File(filePath);
      if (!await sqlFile.exists()) {
        Navigator.pop(context);
        _showErrorSnackBar('File backup tidak ditemukan');
        return;
      }

      String sqlContent = await sqlFile.readAsString();

      // Update loading message
      Navigator.pop(context);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.orange[600]),
              SizedBox(height: 16),
              Text('Menjalankan restore...'),
            ],
          ),
        ),
      );

      // Perform restore
      bool success = await _executeRestore(sqlContent);

      Navigator.pop(context); // Close loading dialog

      if (success) {
        _showRestoreSuccessDialog();
      } else {
        _showErrorSnackBar('Gagal melakukan restore database');
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      print('Restore error: $e');
      _showErrorSnackBar('Error restore: ${e.toString()}');
    }
  }

  // Execute restore operation
  Future<bool> _executeRestore(String sqlContent) async {
    try {
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;

      await db.transaction((txn) async {
        // Step 1: Delete all existing data
        await txn.execute('DELETE FROM inventory_transactions');
        await txn.execute('DELETE FROM transaction_items');
        await txn.execute('DELETE FROM transactions');
        await txn.execute('DELETE FROM purchases');
        await txn.execute('DELETE FROM products');
        await txn.execute('DELETE FROM business_profile');

        // Step 2: Reset auto-increment sequences
        await txn.execute(
          'DELETE FROM sqlite_sequence WHERE name IN ("products", "purchases", "transaction_items")',
        );

        // Step 3: Execute SQL commands from backup file
        List<String> commands = sqlContent.split(';');

        for (String command in commands) {
          String trimmedCommand = command.trim();
          if (trimmedCommand.isNotEmpty &&
              !trimmedCommand.startsWith('--') &&
              trimmedCommand.toLowerCase().startsWith('insert')) {
            try {
              await txn.execute(trimmedCommand);
            } catch (e) {
              print('Error executing command: $trimmedCommand');
              print('Error: $e');
              // Continue with other commands even if one fails
            }
          }
        }
      });

      return true;
    } catch (e) {
      print('Execute restore error: $e');
      return false;
    }
  }

  // Show restore success dialog
  void _showRestoreSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600]),
            SizedBox(width: 8),
            Text('Restore Berhasil'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.celebration, color: Colors.green[600], size: 48),
            SizedBox(height: 16),
            Text(
              'Database berhasil di-restore!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    'Semua data telah berhasil dipulihkan dari file backup.',
                    style: TextStyle(fontSize: 12, color: Colors.green[700]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Aplikasi akan kembali ke dashboard.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate back to dashboard
              NavigationHandler.navigateToScreen(context, 'dashboard');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.home, size: 16),
                SizedBox(width: 8),
                Text('Ke Dashboard'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Show coming soon snackbar for features not yet implemented
  void _showComingSoonSnackBar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Fitur akan segera tersedia'),
        backgroundColor: Colors.blue[600],
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // Add the drawer here
      drawer: SidebarDrawer(onMenuItemSelected: _onMenuItemSelected),
      // Disable swipe-to-open drawer gesture to prevent conflict with back gesture
      drawerEnableOpenDragGesture: false,
      appBar: AppBar(
        title: Text('Pengaturan'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        // Add manual hamburger menu button
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header Section
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.settings,
                    color: Colors.orange[600],
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pengaturan Sistem',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Kelola konfigurasi aplikasi dan data',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.orange[600],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Settings Menu Grid
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  // Edit Profile Menu
                  Stack(
                    children: [
                      MenuGridItem(
                        icon: Icons.person_outline,
                        title: 'Profile',
                        iconColor: Colors.blue[600]!,
                        onTap: () => _navigateToScreen('edit_profile'),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.orange[600],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.admin_panel_settings,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Printer Configuration Menu
                  MenuGridItem(
                    icon: Icons.print,
                    title: 'Printer',
                    iconColor: Colors.green[600]!,
                    onTap: () => _navigateToScreen('printer_config'),
                  ),

                  // Export Menu (Now requires admin password)
                  Stack(
                    children: [
                      MenuGridItem(
                        icon: Icons.file_upload,
                        title: 'Export Data',
                        iconColor: Colors.purple[600]!,
                        onTap: () => _navigateToScreen('export'),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.orange[600],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.admin_panel_settings,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Import Menu (Now requires admin password)
                  Stack(
                    children: [
                      MenuGridItem(
                        icon: Icons.file_download,
                        title: 'Import Data',
                        iconColor: Colors.teal[600]!,
                        onTap: () => _navigateToScreen('import'),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.orange[600],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.admin_panel_settings,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Footer Info
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Fitur Export dan Import memerlukan hak akses administrator',
                    style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Handle menu selection from sidebar
  void _onMenuItemSelected(String screenId) {
    Navigator.pop(context); // Close drawer first
    NavigationHandler.navigateToScreen(context, screenId);
  }
}
