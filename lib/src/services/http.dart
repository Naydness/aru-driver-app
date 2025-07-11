import 'package:aru/src/constants.dart';
import 'package:aru/src/services/auth_manager.dart';
import 'package:aru/src/views/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class HttpService extends GetConnect {
  static List exclEndpoints = [
    Endpoint.login,
    Endpoint.signup,
    Endpoint.verifyEmail,
    Endpoint.resendOTP,
    Endpoint.refreshToken
  ];

  AuthManager authManager = Get.find();

  @override
  void onInit() {
    super.onInit();
    httpClient.baseUrl = 'https://aru-backend-production.up.railway.app';
    httpClient.defaultContentType = 'application/json';
    httpClient.timeout = Duration(seconds: 60);
    httpClient.addRequestModifier<dynamic>((req) async {
      if (!exclEndpoints.contains(req.url.path)) {
        final accessToken = await _getAccessToken();
        // debugPrint('Setting token: $accessToken - ${req.url.path}');
        req.headers['Authorization'] = 'Bearer $accessToken';
      }

      return req;
    });

    /*httpClient.addResponseModifier((req, res) {
      
    });*/

    httpClient.maxAuthRetries = 1;
    httpClient.addAuthenticator<dynamic>((req) async {
      if (!exclEndpoints.contains(req.url.path)) {
        final Response res = await post(Endpoint.refreshToken, {
          'refreshToken': await _getRefreshToken()
        });

        if (res.statusCode == 400) {
          Get.until((route) => route.settings.name == '/');
          authManager.clearAuthToken();
          Get.off(Login(), id: 0);
        }

        // debugPrint('Retry res: ${res.body}');
        final data = res.body['data'];
        await authManager.updateAuthToken(
          data['access_token'],
          data['refreshToken']
        );
      }

      return req;
    });
  }

  Future<String?> _getAccessToken() async {
    return await FlutterSecureStorage().read(key: 'accessToken');
  }

  Future<String?> _getRefreshToken() async {
    // return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4NDZlZjdkNWYzZTJjZTljNWYxOGNlOCIsInJvbGUiOiJyaWRlciIsImlhdCI6MTc0OTU3ODc0OSwiZXhwIjoxNzUwMTgzNTQ5fQ.YJzqepN2S8ahDK4aliyAcF3gKjaMkt1Y2nBPFLyodQE';
    return await FlutterSecureStorage().read(key: 'refreshToken');
  }

  Future authenticate(String email, String password) async {
    try {
      final Response res = await post(Endpoint.login, {
        'email': email,
        'password': password
      });

      if (res.status.isOk) {
        return res.body['data'];
      } else {
        return res.body['message'];
      }
    } catch (e) {
      return 'Authentication failed. Please try again later.';
    }
  }

  Future signup(Map<String, dynamic> data) async {
    try {
      print('DATA: $data');
      final FormData formData = FormData(data);

      final Response res = await post(
        Endpoint.signup, 
        formData,
        // contentType: 'multipart/form-data'
      );

      debugPrint('Body: ${res.body}');

      if (res.status.isOk) {
        return res.body['data'];
      } else {
        return res.body['message'];
      }
    } catch (e) {
      return 'Signup failed. Please try again later.';
    }
  }

  Future verifyEmail(String email, String otp) async {
    try {
      final Response res = await post(Endpoint.verifyEmail, {
        'email': email,
        'otp': otp
      });

      if (res.status.isOk) {
        return res.body['data'];
      } else {
        return res.body['message'];
      }
    } catch (e) {
      return 'Verification failed. Please try again later.';
    }
  }

  Future resendOTP(String email) async {
    try {
      final Response res = await post(Endpoint.resendOTP, {
        'email': email,
      });

      if (res.status.isOk) {
        return true;
      }

      return false;
    } catch (e) {
      return null;
    }
  }

  Future forgotPassword(String email) async {
    try {
      final Response res = await post(Endpoint.forgotPassword, {
        'email': email
      });

      if (res.status.isOk) {
        return true;
      }

      return false;
    } catch (e) {
      return null;
    }
  }

  Future getUserProfile() async {
    try {
      final Response res = await get(Endpoint.getUserProfile);

      if (res.status.isOk) {
        return res.body['data'];
      }

      return res.body['message'];
    } catch (e) {
      return 'Error getting user profile';
    }
  }

  Future changePassword(String currentPassword, String password) async {
    try {
      final Response res = await post(Endpoint.changePassword, {
        'currentPassword': currentPassword,
        'password': password,
      });

      if (res.status.isOk) {
        return true;
      }

      if (res.body['error'] != null && res.body['error'] is List) {
        return res.body['error']?.first?['message']
          ?? 'Failed to update password.';
      }

      return res.body['message'];
    } catch (e) {
      return 'Unable to update password. Please try again later.';
    }
  }

  Future resetPassword(Map data) async {
    try {
      final Response res = await post(Endpoint.resetPassword, {
        'email': data['email'],
        'otp': data['otp'],
        'password': data['password']
      });

      if (res.status.isOk) {
        return true;
      }

      return res.body['message'];
    } catch (e) {
      return 'Unable to update password. Please try again later.';
    }
  }

  Future updateProfile(String fname, String lname, String phone) async {
    try {
      final Response res = await patch(Endpoint.updateProfile, {
        'firstName': fname,
        'lastName': lname,
        'phoneNumber': phone
      });

      if (res.status.isOk) {
        return res.body['data'];
      }

      return res.body['message'];
    } catch (e) {
      return 'Unable to update profile. Please try again later.';
    }
  }

  Future getAllTransactions() async {
    try {
      final Response res = await get(Endpoint.getAllTransactions);

      if (res.status.isOk) {
        return res.body['data']['transactions'];
      }

      return res.body['message'];
    } catch (e) {
      return 'Unable to get transactions. Please try again later.';
    }
  }

  Future getAllRequests() async {
    try {
      final Response res = await get(Endpoint.getAllRequests);

      if (res.status.isOk) {
        return res.body['data']['rides'];
      }

      return res.body['message'];
    } catch (e) {
      return 'Unable to get orders. Please try again later.';
    }
  }

  Future acceptRideRequest(String reqId) async {
    try {
      print('Accepting: $reqId');
      final Response res = await get('${Endpoint.rideRequest}/$reqId/accept');

      print('Accept Res: ${res.body}');
      if (res.status.isOk) {
        return res.body['data'];
      }

      return res.body['message'];
    } catch (e) {
      return 'Unable to create ride request. Please try again later.';
    }
  }

  Future rejectRideRequest(String reqId) async {
    try {
      print('Rejecting: $reqId');
      final Response res = await get('${Endpoint.rideRequest}/$reqId/reject');

      print('Reject Res: ${res.body}');
      if (res.status.isOk) {
        return res.body['data'];
      }

      return res.body['message'];
    } catch (e) {
      return 'Unable to create ride request. Please try again later.';
    }
  }

  Future toggleAvailability() async {
    try {
      final Response res = await post(Endpoint.toggleAvailibility, null);

      print('Avail Res: ${res.body}');
      if (res.status.isOk) {
        return true;
      }

      return false;
    } catch (e) {
      return null;
    }
  }


}

class Endpoint {
  static const  _basePath = '/api/v1';

  static const refreshToken = '$_basePath/auth/rider/refresh-token';
  static const login = '$_basePath/auth/driver/login';
  static const signup = '$_basePath/auth/driver/register';
  static const verifyEmail = '$_basePath/auth/driver/verify-email';
  static const resendOTP = '$_basePath/auth/driver/resend-otp';
  static const forgotPassword = '$_basePath/auth/driver/forgot-password';
  static const getUserProfile = '$_basePath/driver/profile';
  static const rideRequest = '$_basePath/ride';
  static const changePassword = '$_basePath/rider/change-password';
  static const resetPassword = '$_basePath/auth/driver/reset-password';
  static const updateProfile = '$_basePath/rider/profile';
  static const getAllTransactions = '$_basePath/transactions/user';
  static const getAllRequests = '$_basePath/ride/history';
  static const toggleAvailibility = '$_basePath/driver/update-availability';
  // static const createStripePaymentIntent = '$_basePath/transactions/top-up';
}