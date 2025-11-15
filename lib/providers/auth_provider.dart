import 'package:flutter/widgets.dart' hide Notification;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../models/user.dart';
import '../models/analytics.dart';
import '../services/firestore_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthProvider() {
    debugPrint('AuthProvider initialized');
    debugPrint('Firebase Auth instance: $_auth');
    debugPrint('Firestore instance: $_firestore');
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  Future<void> loadCurrentUser({bool emit = true}) async {
    try {
      if (emit) {
        _isLoading = true;
        notifyListeners();
      } else {
        _isLoading = true;
      }

      debugPrint('Loading current user...');

      // Check if Firebase user is signed in
      final firebaseUser = _auth.currentUser;
      debugPrint('Firebase current user: ${firebaseUser?.uid}');

      if (firebaseUser != null) {
        // Load user data from Firestore
        final userDoc =
            await _firestore.collection('users').doc(firebaseUser.uid).get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          userData['id'] = firebaseUser.uid;
          userData['email'] = firebaseUser.email;
          _user = _createUserFromJson(userData);
          debugPrint('Loaded user from Firestore: $_user');

          // Create login notification if this is your monitored email (for app startup)
          await _createLoginNotification(firebaseUser.email!, firebaseUser.uid);
        } else {
          debugPrint('User document not found in Firestore');
          await _auth.signOut();
        }
      } else {
        debugPrint('No Firebase user signed in');
      }
    } catch (error) {
      debugPrint('Error loading current user: $error');
    } finally {
      _isLoading = false;
      if (emit) {
        notifyListeners();
      } else {
        // Defer notification until after current frame to avoid build-time mutations
        try {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            notifyListeners();
          });
        } catch (_) {
          notifyListeners();
        }
      }
    }
  }

  Future<AuthResult> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      debugPrint('Attempting to sign in with email: ${email.trim()}');

      // Validate inputs
      if (email.trim().isEmpty) {
        return AuthResult(success: false, error: 'Email cannot be empty');
      }
      if (password.isEmpty) {
        return AuthResult(success: false, error: 'Password cannot be empty');
      }

      // Sign in with Firebase Auth
      debugPrint('Calling Firebase Auth signInWithEmailAndPassword...');
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      debugPrint('Firebase Auth signInWithEmailAndPassword completed');

      if (credential.user != null) {
        // Load user data from Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          userData['id'] = credential.user!.uid;
          userData['email'] = credential.user!.email;
          _user = _createUserFromJson(userData);
          debugPrint('User logged in successfully: $_user');

          // Create login notification if this is your monitored email
          await _createLoginNotification(
              credential.user!.email!, credential.user!.uid);

          return AuthResult(success: true);
        } else {
          await _auth.signOut();
          return AuthResult(success: false, error: 'User data not found');
        }
      } else {
        return AuthResult(success: false, error: 'Login failed');
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Exception: ${e.code} - ${e.message}');
      debugPrint('Exception details: ${e.toString()}');
      String errorMessage = 'Login failed';
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your connection.';
          break;
        case 'channel-error':
          errorMessage = 'Authentication service error. Please try again.';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid email or password';
          break;
        default:
          errorMessage = e.message ?? 'Login failed';
      }
      return AuthResult(success: false, error: errorMessage);
    } catch (error) {
      debugPrint('Login error: $error');
      return AuthResult(success: false, error: 'An unexpected error occurred');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AuthResult> register(RegisterData userData) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Create Firebase Auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: userData.email.trim(),
        password: userData.password,
      );

      if (credential.user != null) {
        // Create user document in Firestore
        final newUser = {
          'email': userData.email.trim().toLowerCase(),
          'role': userData.role.toString().split('.').last,
          'name': userData.name.trim(),
          'phone': userData.phone?.trim(),
          'address': userData.address?.trim(),
          'city': userData.city?.trim(),
          'state': userData.state?.trim(),
          'country': userData.country?.trim(),
          'postalCode': userData.postalCode?.trim(),
          'location': userData.location?.toJson(),
          'avatar': userData.avatar,
          'shopName': userData.shopName,
          'shopDescription': userData.shopDescription,
          'shopAddress': userData.shopAddress,
          'shopPhone': userData.shopPhone,
          'isApproved': userData.role == UserRole.vendor ? 'approved' : null,
          'deliveryEnabled': userData.role == UserRole.vendor ? true : null,
          'pickupEnabled': userData.role == UserRole.vendor ? true : null,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        // Save user data to Firestore
        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(newUser);

        // Set as current user
        newUser['id'] = credential.user!.uid;
        _user = _createUserFromJson(newUser);
        debugPrint('User registered successfully: $_user');

        return AuthResult(success: true);
      } else {
        return AuthResult(success: false, error: 'Registration failed');
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      String errorMessage = 'Registration failed';
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Password is too weak';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        default:
          errorMessage = e.message ?? 'Registration failed';
      }
      return AuthResult(success: false, error: errorMessage);
    } catch (error) {
      debugPrint('Registration error: $error');
      return AuthResult(success: false, error: 'An unexpected error occurred');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      _user = null;
      notifyListeners();
      debugPrint('User logged out successfully');
    } catch (error) {
      debugPrint('Error during logout: $error');
    }
  }

  Future<AuthResult> updateProfile(Map<String, dynamic> updates) async {
    if (_user == null) {
      return AuthResult(success: false, error: 'No user logged in');
    }

    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        return AuthResult(success: false, error: 'User not authenticated');
      }

      // Handle password update separately if present
      if (updates.containsKey('password') && updates['password'] != null) {
        debugPrint('AuthProvider - Updating password...');
        try {
          await firebaseUser.updatePassword(updates['password']);
          debugPrint('AuthProvider - Password updated successfully');
          // Remove password from updates as it's not stored in Firestore
          updates.remove('password');
        } catch (e) {
          debugPrint('AuthProvider - Error updating password: $e');
          if (e is firebase_auth.FirebaseAuthException) {
            String errorMessage = 'Failed to update password';
            switch (e.code) {
              case 'weak-password':
                errorMessage = 'Password is too weak';
                break;
              case 'requires-recent-login':
                errorMessage =
                    'Please log out and log back in before changing password';
                break;
              default:
                errorMessage = e.message ?? 'Failed to update password';
            }
            return AuthResult(success: false, error: errorMessage);
          }
          return AuthResult(success: false, error: 'Failed to update password');
        }
      }

      // Handle profile image upload if present
      if (updates.containsKey('avatar') && updates['avatar'] != null) {
        final avatarPath = updates['avatar'] as String;
        debugPrint('AuthProvider - Processing avatar: $avatarPath');

        if (avatarPath.startsWith('/')) {
          // Local file path, upload to Supabase and delete previous if exists
          debugPrint(
              'AuthProvider - Detected local file path, uploading to Supabase');
          debugPrint('AuthProvider - Avatar path: $avatarPath');
          debugPrint('AuthProvider - User ID: ${firebaseUser.uid}');
          try {
            final imageFile = File(avatarPath);
            final fileExists = await imageFile.exists();
            debugPrint('AuthProvider - File exists check: $fileExists');
            if (fileExists) {
              debugPrint('AuthProvider - File exists, starting upload...');
              final imageUrl = await FirestoreService.uploadProfileImage(
                  imageFile, firebaseUser.uid);
              debugPrint(
                  'AuthProvider - Upload successful, new URL: $imageUrl');

              // Delete old avatar from Supabase if it was a Supabase URL
              if (_user?.avatar != null &&
                  _user!.avatar!.contains('/storage/v1/object/')) {
                await FirestoreService.deleteProfileImage(_user!.avatar!);
              }
              updates['avatar'] = imageUrl;
              debugPrint('AuthProvider - Updates after upload: $updates');
            } else {
              debugPrint(
                  'AuthProvider - Image file does not exist: $avatarPath');
              updates.remove('avatar'); // Remove invalid avatar path
            }
          } catch (e) {
            debugPrint('AuthProvider - Error uploading profile image: $e');
            debugPrint('AuthProvider - Error type: ${e.runtimeType}');
            debugPrint('AuthProvider - Error details: ${e.toString()}');
            updates.remove('avatar'); // Remove invalid avatar path
          }
        } else if (avatarPath.startsWith('http')) {
          debugPrint(
              'AuthProvider - Avatar is already a network URL, keeping as is');
        } else {
          debugPrint('AuthProvider - Unknown avatar format: $avatarPath');
        }
      } else {
        debugPrint('AuthProvider - No avatar in updates or avatar is null');
      }

      // Update user in Firestore using FirestoreService
      debugPrint(
          'AuthProvider - About to update user in Firestore with: $updates');
      await FirestoreService.updateUser(firebaseUser.uid, updates);
      debugPrint('AuthProvider - Firestore update completed');

      // If avatar was updated, also update the other role's record
      if (updates.containsKey('avatar')) {
        debugPrint(
            'AuthProvider - Avatar was updated, syncing with other role...');
        try {
          final currentRole = _user!.role;
          final otherRole =
              currentRole == UserRole.customer ? 'vendor' : 'customer';

          // Find the other role's record
          final otherRoleQuery = await _firestore
              .collection('users')
              .where('email', isEqualTo: _user!.email.toLowerCase())
              .where('role', isEqualTo: otherRole)
              .limit(1)
              .get();

          if (otherRoleQuery.docs.isNotEmpty) {
            final otherRoleDocId = otherRoleQuery.docs.first.id;
            debugPrint(
                'AuthProvider - Found other role record: $otherRoleDocId');

            // Update the other role's avatar
            await _firestore
                .collection('users')
                .doc(otherRoleDocId)
                .update({'avatar': updates['avatar']});
            debugPrint(
                'AuthProvider - Synced avatar to other role: $otherRole');
          } else {
            debugPrint('AuthProvider - No other role record found to sync');
          }
        } catch (e) {
          debugPrint('AuthProvider - Error syncing avatar to other role: $e');
          // Don't fail the entire update if sync fails
        }
      }

      // Reload user data
      debugPrint('AuthProvider - Reloading user data...');
      final updatedUser = await FirestoreService.getUser(firebaseUser.uid);
      debugPrint('AuthProvider - Reloaded user: $updatedUser');
      debugPrint('AuthProvider - Reloaded user avatar: ${updatedUser?.avatar}');
      if (updatedUser != null) {
        _user = updatedUser;
        debugPrint('Profile updated successfully: $_user');
        debugPrint(
            'Profile updated successfully - user avatar: ${_user?.avatar}');
        notifyListeners();
        return AuthResult(success: true);
      } else {
        debugPrint(
            'Failed to reload user data after update. User ID: ${firebaseUser.uid}');
        return AuthResult(
            success: false, error: 'User data not found after update');
      }
    } catch (error) {
      debugPrint('Profile update error: $error');
      return AuthResult(success: false, error: 'An unexpected error occurred');
    }
  }

  Future<bool> hasAccountWithEmail(String email) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase())
          .get();

      debugPrint(
          'AuthProvider - hasAccountWithEmail: Found ${query.docs.length} accounts with email: $email');

      // Print all account details for debugging
      for (int i = 0; i < query.docs.length; i++) {
        final data = query.docs[i].data();
        debugPrint(
            'AuthProvider - hasAccountWithEmail: Account $i: ${data.toString()}');
      }

      return query.docs.isNotEmpty;
    } catch (error) {
      debugPrint('Error checking for account with email: $error');
      return false;
    }
  }

  Future<bool> hasCustomerAccount() async {
    if (_user == null) {
      debugPrint('AuthProvider - hasCustomerAccount: user is null');
      return false;
    }

    debugPrint(
        'AuthProvider - hasCustomerAccount: current user role: ${_user!.role}');
    debugPrint(
        'AuthProvider - hasCustomerAccount: current user email: ${_user!.email}');

    try {
      // Check if there's a customer account with the same email
      final emailToSearch = _user!.email.toLowerCase();
      debugPrint(
          'AuthProvider - hasCustomerAccount: searching for email: "$emailToSearch"');
      debugPrint(
          'AuthProvider - hasCustomerAccount: searching for role: "customer"');

      final customerQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: emailToSearch)
          .where('role', isEqualTo: 'customer')
          .limit(1)
          .get();

      debugPrint(
          'AuthProvider - hasCustomerAccount: customer query result: ${customerQuery.docs.length} documents found');

      if (customerQuery.docs.isNotEmpty) {
        final customerData = customerQuery.docs.first.data();
        debugPrint(
            'AuthProvider - hasCustomerAccount: found customer data: $customerData');
        debugPrint(
            'AuthProvider - hasCustomerAccount: customer email in DB: "${customerData['email']}"');
        debugPrint(
            'AuthProvider - hasCustomerAccount: customer role in DB: "${customerData['role']}"');
      } else {
        debugPrint(
            'AuthProvider - hasCustomerAccount: no customer account found');

        // Let's also check if there are any accounts with this email at all
        final allAccountsQuery = await _firestore
            .collection('users')
            .where('email', isEqualTo: emailToSearch)
            .get();

        debugPrint(
            'AuthProvider - hasCustomerAccount: total accounts with this email: ${allAccountsQuery.docs.length}');

        for (int i = 0; i < allAccountsQuery.docs.length; i++) {
          final accountData = allAccountsQuery.docs[i].data();
          debugPrint(
              'AuthProvider - hasCustomerAccount: account $i - role: "${accountData['role']}", email: "${accountData['email']}"');
        }

        // Let's also try searching for different role formats
        final customerQueryAlt1 = await _firestore
            .collection('users')
            .where('email', isEqualTo: emailToSearch)
            .where('role', isEqualTo: 'UserRole.customer')
            .limit(1)
            .get();

        debugPrint(
            'AuthProvider - hasCustomerAccount: alternative query 1 (UserRole.customer): ${customerQueryAlt1.docs.length} documents found');

        final customerQueryAlt2 = await _firestore
            .collection('users')
            .where('email', isEqualTo: emailToSearch)
            .where('role', isEqualTo: 'customer')
            .limit(1)
            .get();

        debugPrint(
            'AuthProvider - hasCustomerAccount: alternative query 2 (customer): ${customerQueryAlt2.docs.length} documents found');
      }

      // If the main query didn't find anything, let's try a more flexible approach
      if (customerQuery.docs.isEmpty) {
        debugPrint(
            'AuthProvider - hasCustomerAccount: Main query failed, trying flexible search...');

        // Try to find any account with this email and check the role manually
        final flexibleQuery = await _firestore
            .collection('users')
            .where('email', isEqualTo: emailToSearch)
            .get();

        for (var doc in flexibleQuery.docs) {
          final data = doc.data();
          final role = data['role']?.toString() ?? '';
          debugPrint(
              'AuthProvider - hasCustomerAccount: Found account with role: "$role"');

          // Check if this is a customer account (handle different role formats)
          if (role == 'customer' ||
              role == 'UserRole.customer' ||
              role.contains('customer')) {
            debugPrint(
                'AuthProvider - hasCustomerAccount: Found customer account via flexible search!');
            return true;
          }
        }
      }

      return customerQuery.docs.isNotEmpty;
    } catch (error) {
      debugPrint('Error checking for customer account: $error');
      return false;
    }
  }

  Future<bool> switchToCustomerRole() async {
    if (_user == null) {
      debugPrint('AuthProvider - Cannot switch to customer: user is null');
      return false;
    }

    debugPrint(
        'AuthProvider - switchToCustomerRole: current user role: ${_user!.role}');
    debugPrint(
        'AuthProvider - switchToCustomerRole: current user email: ${_user!.email}');

    try {
      debugPrint(
          'AuthProvider - Switching to customer role for user: ${_user!.email}');
      debugPrint(
          'AuthProvider - Current user avatar before switch: ${_user!.avatar}');

      // Preserve the original account name
      final originalAccountName = _user!.name;
      debugPrint(
          'AuthProvider - Preserving original account name: $originalAccountName');

      // Find customer account with same email
      final customerQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: _user!.email.toLowerCase())
          .where('role', isEqualTo: 'customer')
          .limit(1)
          .get();

      if (customerQuery.docs.isNotEmpty) {
        // Load customer data and set as current user
        final customerData = customerQuery.docs.first.data();
        customerData['id'] = customerQuery.docs.first.id;

        // Preserve the original account name instead of using customer's name
        customerData['name'] = originalAccountName;
        debugPrint(
            'AuthProvider - Customer data from Firestore: $customerData');
        debugPrint(
            'AuthProvider - Preserved account name in customer data: ${customerData['name']}');
        debugPrint(
            'AuthProvider - Customer avatar from Firestore: ${customerData['avatar']}');

        _user = _createUserFromJson(customerData);
        debugPrint('AuthProvider - New user after switch: ${_user?.email}');
        debugPrint('AuthProvider - New user name after switch: ${_user?.name}');
        debugPrint(
            'AuthProvider - New user avatar after switch: ${_user?.avatar}');

        // Clear data when switching roles to prevent conflicts
        _clearDataOnRoleSwitch();

        notifyListeners();
        return true;
      }
      debugPrint(
          'AuthProvider - No customer account found for email: ${_user!.email}');
      return false;
    } catch (error) {
      debugPrint('Error switching to customer role: $error');
      return false;
    }
  }

  Future<bool> hasVendorAccount() async {
    if (_user == null) {
      debugPrint('AuthProvider - hasVendorAccount: user is null');
      return false;
    }

    debugPrint(
        'AuthProvider - hasVendorAccount: current user role: ${_user!.role}');
    debugPrint(
        'AuthProvider - hasVendorAccount: current user email: ${_user!.email}');

    // First check if current user is already a vendor
    if (_user!.role == UserRole.vendor) {
      debugPrint(
          'AuthProvider - hasVendorAccount: current user is already a vendor');
      return true;
    }

    try {
      // Check if there's a separate vendor account with the same email
      final emailToSearch = _user!.email.toLowerCase();
      debugPrint(
          'AuthProvider - hasVendorAccount: searching for vendor account with email: "$emailToSearch"');

      final vendorQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: emailToSearch)
          .where('role', isEqualTo: 'vendor')
          .limit(1)
          .get();

      debugPrint(
          'AuthProvider - hasVendorAccount: vendor query result: ${vendorQuery.docs.length} documents found');

      if (vendorQuery.docs.isNotEmpty) {
        final vendorData = vendorQuery.docs.first.data();
        debugPrint(
            'AuthProvider - hasVendorAccount: found vendor data: $vendorData');
        return true;
      } else {
        debugPrint(
            'AuthProvider - hasVendorAccount: no separate vendor account found');

        // Try flexible search for different role formats
        final flexibleQuery = await _firestore
            .collection('users')
            .where('email', isEqualTo: emailToSearch)
            .get();

        for (var doc in flexibleQuery.docs) {
          final data = doc.data();
          final role = data['role']?.toString() ?? '';
          debugPrint(
              'AuthProvider - hasVendorAccount: Found account with role: "$role"');

          // Check if this is a vendor account (handle different role formats)
          if (role == 'vendor' ||
              role == 'UserRole.vendor' ||
              role.contains('vendor')) {
            debugPrint(
                'AuthProvider - hasVendorAccount: Found vendor account via flexible search!');
            return true;
          }
        }
      }

      return false;
    } catch (error) {
      debugPrint('Error checking for vendor account: $error');
      return false;
    }
  }

  Future<bool> isVendorAccountComplete() async {
    if (_user == null) {
      debugPrint('AuthProvider - isVendorAccountComplete: user is null');
      return false;
    }

    try {
      // Check if there's a complete vendor account with the same email
      final vendorQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: _user!.email.toLowerCase())
          .where('role', isEqualTo: 'vendor')
          .limit(1)
          .get();

      if (vendorQuery.docs.isEmpty) {
        debugPrint(
            'AuthProvider - isVendorAccountComplete: no vendor account found');
        return false;
      }

      final vendorData = vendorQuery.docs.first.data();
      debugPrint(
          'AuthProvider - isVendorAccountComplete: vendor data: $vendorData');

      // Check if all required fields are present for a complete vendor account
      final hasShopName = vendorData['shopName'] != null &&
          vendorData['shopName'].toString().isNotEmpty;
      final hasLocation = vendorData['location'] != null;
      final hasShopAddress = vendorData['shopAddress'] != null &&
          vendorData['shopAddress'].toString().isNotEmpty;
      final hasDeliveryMode = vendorData['deliveryMode'] != null;

      debugPrint(
          'AuthProvider - isVendorAccountComplete: hasShopName: $hasShopName, hasLocation: $hasLocation, hasShopAddress: $hasShopAddress, hasDeliveryMode: $hasDeliveryMode');

      final isComplete =
          hasShopName && hasLocation && hasShopAddress && hasDeliveryMode;
      debugPrint(
          'AuthProvider - isVendorAccountComplete: isComplete: $isComplete');

      return isComplete;
    } catch (error) {
      debugPrint('Error checking vendor account completion: $error');
      return false;
    }
  }

  Future<bool> switchToVendorRole() async {
    if (_user == null) {
      debugPrint('AuthProvider - Cannot switch to vendor: user is null');
      return false;
    }

    debugPrint(
        'AuthProvider - switchToVendorRole: current user role: ${_user!.role}');
    debugPrint(
        'AuthProvider - switchToVendorRole: current user email: ${_user!.email}');

    try {
      debugPrint(
          'AuthProvider - Switching to vendor role for user: ${_user!.email}');
      debugPrint(
          'AuthProvider - Current user avatar before switch: ${_user!.avatar}');

      // Preserve the original account name
      final originalAccountName = _user!.name;
      debugPrint(
          'AuthProvider - Preserving original account name: $originalAccountName');

      // Find vendor account with same email
      final vendorQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: _user!.email.toLowerCase())
          .where('role', isEqualTo: 'vendor')
          .limit(1)
          .get();

      if (vendorQuery.docs.isNotEmpty) {
        // Load vendor data and set as current user
        final vendorData = vendorQuery.docs.first.data();
        vendorData['id'] = vendorQuery.docs.first.id;

        // Preserve the original account name instead of using vendor's name
        vendorData['name'] = originalAccountName;
        debugPrint('AuthProvider - Vendor data from Firestore: $vendorData');
        debugPrint(
            'AuthProvider - Preserved account name in vendor data: ${vendorData['name']}');
        debugPrint(
            'AuthProvider - Vendor avatar from Firestore: ${vendorData['avatar']}');

        _user = _createUserFromJson(vendorData);
        debugPrint('AuthProvider - New user after switch: ${_user?.email}');
        debugPrint('AuthProvider - New user name after switch: ${_user?.name}');
        debugPrint(
            'AuthProvider - New user avatar after switch: ${_user?.avatar}');

        // Clear data when switching roles to prevent conflicts
        _clearDataOnRoleSwitch();

        notifyListeners();
        return true;
      }
      debugPrint(
          'AuthProvider - No vendor account found for email: ${_user!.email}');
      return false;
    } catch (error) {
      debugPrint('Error switching to vendor role: $error');
      return false;
    }
  }

  // Clear data when switching roles to prevent conflicts
  void _clearDataOnRoleSwitch() {
    debugPrint('AuthProvider: Clearing data on role switch');
    // This will be handled by the DataProvider when it detects the role change
    // We don't directly access DataProvider here to avoid circular dependencies
    // The screens will handle the data clearing when they detect the role change
  }

  // Create login notification for security monitoring
  Future<void> _createLoginNotification(String userEmail, String userId) async {
    try {
      // Check if this is your email (replace with your actual email)
      const String yourEmail =
          'your-email@example.com'; // Replace with your actual email

      if (userEmail.toLowerCase() == yourEmail.toLowerCase()) {
        debugPrint(
            'Creating login notification for monitored email: $userEmail');

        final notification = Notification(
          id: 'login_${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          title: 'Login Alert',
          message: 'Someone logged in with your email: $userEmail',
          type: NotificationType.login,
          isRead: false,
          createdAt: DateTime.now(),
          data: {
            'email': userEmail,
            'loginTime': DateTime.now().toIso8601String(),
            'deviceInfo': Platform.isAndroid
                ? 'Android'
                : Platform.isIOS
                    ? 'iOS'
                    : 'Web',
          },
        );

        // Save notification to Firestore
        await _firestore
            .collection('notifications')
            .doc(notification.id)
            .set(notification.toJson());

        debugPrint('Login notification created successfully');
      }
    } catch (error) {
      debugPrint('Error creating login notification: $error');
    }
  }

  User? _createUserFromJson(Map<String, dynamic> json) {
    debugPrint('Creating user from JSON: $json');

    if (json.isEmpty) {
      debugPrint('JSON is empty, returning null');
      return null;
    }

    try {
      final roleString = json['role'];
      debugPrint('Role string from JSON: $roleString');

      final role = UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == roleString,
      );

      debugPrint('Parsed role: $role');

      if (role == UserRole.vendor) {
        final vendor = Vendor.fromJson(json);
        debugPrint('Created vendor: $vendor');
        return vendor;
      } else {
        final customer = Customer.fromJson(json);
        debugPrint('Created customer: $customer');
        return customer;
      }
    } catch (error) {
      debugPrint('Error creating user from JSON: $error');
      return null;
    }
  }
}

class AuthResult {
  final bool success;
  final String? error;

  AuthResult({required this.success, this.error});
}

class RegisterData {
  final String email;
  final String password;
  final UserRole role;
  final String name;
  final String? phone;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final LocationData? location;
  final String? avatar;
  final String? shopName;
  final String? shopDescription;
  final String? shopAddress;
  final String? shopPhone;
  final String? businessLicense;
  final String? taxId;
  final String? bankAccount;

  RegisterData({
    required this.email,
    required this.password,
    required this.role,
    required this.name,
    this.phone,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.location,
    this.avatar,
    this.shopName,
    this.shopDescription,
    this.shopAddress,
    this.shopPhone,
    this.businessLicense,
    this.taxId,
    this.bankAccount,
  });
}
