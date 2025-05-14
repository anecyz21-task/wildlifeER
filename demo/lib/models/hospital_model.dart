import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../services/write_post.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

/// Represents a hospital with its relevant details.
class Hospital {
  /// The name of the hospital.
  String name;

  /// The physical address of the hospital.
  String address;

  /// The primary contact phone number.
  String phone;

  /// An alternative contact phone number.
  String altPhone;

  /// The specialty services offered by the hospital.
  String specialty;

  /// The geographical coordinates of the hospital.
  LatLng latLng;

  /// Creates a [Hospital] instance with the required details.
  ///
  /// All parameters are required and must not be null.
  Hospital({
    required this.name,
    required this.address,
    required this.phone,
    required this.altPhone,
    required this.specialty,
    required this.latLng,
  });
}
