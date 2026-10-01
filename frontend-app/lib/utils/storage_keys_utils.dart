import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageKeysUtils {

  late final FlutterSecureStorage _storage;

  StorageKeysUtils()
      : _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );
  
  Future<String?> getKey(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> setKey(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<void> deleteKey(String key) async {
    await _storage.delete(key: key);
  }

}