import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'auth_service.dart';

/// Encapsulates the Google Sign-In + Firebase Auth flow plus backend sync.
class GoogleSignInService {
	GoogleSignInService._();

	static final GoogleSignIn _googleSignIn = GoogleSignIn(
		scopes: <String>['email', 'profile'],
	);

	static const String _deviceToken =
			'eyurwex5Rqy5Qvu8fz2OtV:APA91bF-C3fcf6sDkqccb2OqVt-5ADIk1rpPpAA81zJ4wQLjrmoglrvklmcSZPi2EkxvC7PjMtDPmDBaWpczQs2p4xDRfeo9aGov8_UiJxE5m70am8Fc9BEriJ8Z9_kwzpEgwe0ZnWBK';

	static const String _apiUrl =
			'https://ecommerce.atithyahms.com/api/v2/ecommerce/customer/google/login';

	/// Signs in with Google, links the session with Firebase Auth, then
	/// notifies the backend so it can return a custom API token.
	static Future<GoogleSignInResult> signInWithGoogle() async {
		try {
			debugPrint('Starting Google Sign-In flow');
			await _signOutSilently();

			final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
			if (googleUser == null) {
				return const GoogleSignInResult(
					success: false,
					message: 'Sign-in canceled',
				);
			}

			final GoogleSignInAuthentication googleAuth =
					await googleUser.authentication;
			final OAuthCredential credential = GoogleAuthProvider.credential(
				accessToken: googleAuth.accessToken,
				idToken: googleAuth.idToken,
			);

			final UserCredential userCredential =
					await FirebaseAuth.instance.signInWithCredential(credential);
			final User? firebaseUser = userCredential.user;

			final _BackendResult backendResult =
					await _syncWithBackend(googleUser, firebaseUser);
			if (!backendResult.success) {
				await _signOutSilently();
				return GoogleSignInResult(
					success: false,
					message: backendResult.message,
				);
			}

			return GoogleSignInResult(
				success: true,
				message: 'Welcome ${googleUser.displayName ?? googleUser.email}!',
				user: googleUser,
				firebaseUser: firebaseUser,
				userData: backendResult.userData,
			);
		} on FirebaseAuthException catch (e) {
			await _signOutSilently();
			return GoogleSignInResult(
				success: false,
				message: e.message ?? 'Firebase authentication failed',
			);
		} catch (e) {
			await _signOutSilently();
			return GoogleSignInResult(
				success: false,
				message: 'Google Sign-In failed: $e',
			);
		}
	}

	static Future<_BackendResult> _syncWithBackend(
		GoogleSignInAccount googleUser,
		User? firebaseUser,
	) async {
		final List<String> nameParts = (googleUser.displayName ?? '').split(' ');
		final String firstName = nameParts.isNotEmpty ? nameParts.first : '';
		final String lastName =
				nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

		final Map<String, dynamic> payload = <String, dynamic>{
			'first_name': firstName,
			'last_name': lastName,
			'mobile_no': '',
			'email': googleUser.email,
			'profile_image': firebaseUser?.photoURL ?? googleUser.photoUrl ?? '',
			'provider_id': googleUser.id,
			'device_token': _deviceToken,
		};

		final http.Response response = await http.post(
			Uri.parse(_apiUrl),
			headers: const <String, String>{
				'Accept': 'application/json',
				'Content-Type': 'application/json',
			},
			body: jsonEncode(payload),
		);

		if (response.statusCode < 200 || response.statusCode >= 300) {
			return _BackendResult(
				success: false,
				message: 'Backend rejected request (${response.statusCode})',
			);
		}

		final dynamic decoded = jsonDecode(response.body);
		if (decoded is! Map<String, dynamic>) {
			return const _BackendResult(
				success: false,
				message: 'Invalid backend response format',
			);
		}

		final Map<String, dynamic> data = decoded;
		final bool loginOk =
				data['status'] == true || data['success'] == true || data['code'] == 200;
		if (!loginOk) {
			final String message =
					data['message']?.toString() ?? 'Google login was not accepted';
			return _BackendResult(success: false, message: message);
		}

		final Map<String, dynamic>? userSection = _extractUserSection(data);
		final dynamic tokenValue = data['token'] ??
				data['access_token'] ??
				data['api_token'] ??
				userSection?['token'] ??
				userSection?['access_token'];

		if (tokenValue == null || tokenValue.toString().isEmpty) {
			return const _BackendResult(
				success: false,
				message: 'Backend did not return an auth token',
			);
		}

		final Map<String, dynamic> userData =
				Map<String, dynamic>.from(userSection ?? <String, dynamic>{});

		await AuthService.saveLoginResponse(
			token: tokenValue.toString(),
			userData: userData,
		);

		return _BackendResult(
			success: true,
			message: 'Login successful',
			userData: userData,
		);
	}

	static Future<void> _signOutSilently() async {
		try {
			await FirebaseAuth.instance.signOut();
		} catch (_) {
			// Ignore sign-out errors.
		}

		try {
			await _googleSignIn.signOut();
		} catch (_) {
			// Ignore sign-out errors.
		}
	}

	static Map<String, dynamic>? _extractUserSection(
			Map<String, dynamic> responseBody) {
		final dynamic raw = responseBody['data'] ?? responseBody['user'];
		if (raw is Map<String, dynamic>) {
			return raw;
		}
		return null;
	}
}

class GoogleSignInResult {
	final bool success;
	final String message;
	final GoogleSignInAccount? user;
	final User? firebaseUser;
	final Map<String, dynamic>? userData;

	const GoogleSignInResult({
		required this.success,
		required this.message,
		this.user,
		this.firebaseUser,
		this.userData,
	});
}

class _BackendResult {
	final bool success;
	final String message;
	final Map<String, dynamic>? userData;

	const _BackendResult({
		required this.success,
		required this.message,
		this.userData,
	});
}

