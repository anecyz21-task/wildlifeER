import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  UserModel? get user => _user;

  Future<void> setUser(User firebaseUser) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    _user = UserModel(
      uid: firebaseUser.uid,
      username: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      lastLatitude: userDoc.data()?['lastLatitude'],
      lastLongitude: userDoc.data()?['lastLongitude'],
      lastUpdated: userDoc.data()?['lastUpdated']?.toDate(),
    );
    notifyListeners();
  }

  Future<void> updateLocation(double latitude, double longitude) async {
    if (_user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .update({
        'lastLatitude': latitude,
        'lastLongitude': longitude,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      _user = UserModel(
        uid: _user!.uid,
        username: _user!.uid,
        email: _user!.email,
        lastLatitude: latitude,
        lastLongitude: longitude,
        lastUpdated: DateTime.now(),
      );
      notifyListeners();
    }
  }

  void clearLocalData() {
    _user = null;
    notifyListeners();
  }

  void updateName(String newName) {
    _user?.username = newName;
    notifyListeners();
  }
}