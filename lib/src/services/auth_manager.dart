import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthManager extends GetxService {
  late GetStorage _storage;
  late FlutterSecureStorage _secureStorage;
  final RxMap _user = RxMap();

  @override
  void onInit() {
    super.onInit();
    _storage = GetStorage();
    _secureStorage = FlutterSecureStorage();
  }

  Future<bool> get loggedIn async {
    final accessToken = await _secureStorage.read(key: 'accessToken');
    return (accessToken != null);
  }

  Future updateAuthToken(String accessToken, String refreshToken) async {
    await _secureStorage.write(key: 'accessToken', value: accessToken);
    await _secureStorage.write(key: 'refreshToken', value: refreshToken);
  }

  Future clearAuthToken() async {
    await _secureStorage.delete(key: 'accessToken');
    await _secureStorage.delete(key: 'refreshToken');
  }

  void logout() async {
    await _secureStorage.deleteAll();
    await _storage.remove('user');
  }

  Future saveUser(dynamic user) async {
    _user.value = user;
  }

  RxMap get user {
    return _user;
  }

  String get userInitials {
    final fname = userNames.first;
    final lname = userNames.last;
    
    return '${lname.substring(0,1)}${fname.substring(0,1)}'.toUpperCase();
  }

  String get userFullName {
    final String fname = userNames.last;
    final String lname = userNames.first;
    
    return '${fname.capitalizeFirst} ${lname.capitalizeFirst}';
  }

  List<String> get userNames {
    return [_user['lastName'], _user['firstName']];
  }
}