import 'package:demo/models/user_model.dart';
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
import '../models/hospital_model.dart';
import 'package:demo/components/post_status.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:demo/providers/user_provider.dart';

/// A page that displays maps with tabs for posts and hospitals.
class MapPage extends StatefulWidget {
  /// The theme data used for styling the page.
  final ThemeData theme;

  /// Creates a [MapPage] with the given [theme].
  const MapPage({Key? key, required this.theme}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Material(
              child: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'Posts'),
                  Tab(text: 'Hospitals'),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  TabBarView(
                    controller: _tabController,
                    physics: NeverScrollableScrollPhysics(), // Ensure the tab does not switch with horizontal swipes
                    children: [
                      MapComponent(theme: widget.theme),
                      HospitalMapComponent(theme: widget.theme),
                    ],
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios, size: 24),
                      onPressed: () {
                        if (_tabController.index > 0) {
                          _tabController.animateTo(_tabController.index - 1);
                        }
                      },
                      tooltip: 'Go to the previous tab',
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      icon: Icon(Icons.arrow_forward_ios, size: 24),
                      onPressed: () {
                        if (_tabController.index < _tabController.length - 1) {
                          _tabController.animateTo(_tabController.index + 1);
                        }
                      },
                      tooltip: 'Go to the next tab',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// A component that displays posts on a Google Map.
class MapComponent extends StatefulWidget {
  /// The theme data used for styling the component.
  final ThemeData theme;

  /// Creates a [MapComponent] with the given [theme].
  const MapComponent({Key? key, required this.theme}) : super(key: key);

  @override
  _MapComponentState createState() => _MapComponentState();
}

class _MapComponentState extends State<MapComponent> {
  GoogleMapController? _mapController;
  LatLng _currentLatLng = const LatLng(37.7749, -122.4194);
  Map<MarkerId, Marker> _markers = {};
  bool _showOverlay = false;
  Map<String, dynamic>? _selectedPostData;
  bool _isLoading = true;
  UserModel? get currentUser => Provider.of<UserProvider>(context, listen: false).user;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _loadPosts();
    _initMapAndPosts();
  }

/// Initializes the map and loads posts.
  Future<void> _initMapAndPosts() async {
    await _determinePosition();
    await _loadPosts();
    setState(() {
      _isLoading = false; 
    });
  }

/// Callback when the map is created.
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  /// Determines the current position of the user.
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLatLng = LatLng(position.latitude, position.longitude);
      });
      
      // Update user location in provider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.updateLocation(position.latitude, position.longitude);
      
      _mapController?.animateCamera(CameraUpdate.newLatLng(_currentLatLng));
    } catch (e) {
      return Future.error('Failed to get location: ${e.toString()}');
    }
  }

/// Loads posts from Firestore and adds markers to the map.
  Future<void> _loadPosts() async {
    final collectionRef = FirebaseFirestore.instance.collection('post');
    try {
      QuerySnapshot querySnapshot = await collectionRef.get();
      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('latitude') && data.containsKey('longitude')) {
          LatLng position = LatLng(data['latitude'], data['longitude']);
          String markerId = doc.id;

          Marker marker = Marker(
            markerId: MarkerId(markerId),
            position: position,
            onTap: () {
              _showPostDetails(doc.id, data); // Pass doc.id here
            },
          );

          setState(() {
            _markers[MarkerId(markerId)] = marker;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load posts: ${e.toString()}')));
    }
  }

  /// Launches the phone dialer with the given [phoneNumber].
  void _launchPhoneURL(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneUri';
    }
  }

   /// Launches navigation to the specified [latitude] and [longitude].
  void _launchNavigationURL(double latitude, double longitude) async {
    final Uri navigationUri = Uri.parse('google.navigation:q=$latitude,$longitude');
    if (await canLaunchUrl(navigationUri)) {
      await launchUrl(navigationUri);
    } else {
      throw 'Could not launch $navigationUri';
    }
  }

  /// Launches the map application to the specified [latitude] and [longitude].
  void _launchMapURL(double latitude, double longitude) async {
    final Uri mapUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    if (await canLaunchUrl(mapUri)) {
      await launchUrl(mapUri);
    } else {
      throw 'Could not launch $mapUri';
    }
  }

  /// Displays a custom dialog with the given [title] and [content].
  void showCustomDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Shows the details of a selected post.
  Future<void> _changeStatus(String docId, PostStatus currentStatus) async {
    final currentUser = Provider.of<UserProvider>(context, listen: false).user;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be logged in to change the status.')),
      );
      return;
    }

    // final bool isAuthor = currentUser.uid == _selectedPostData?['userId'];
    final bool isAuthor = true;

    if (!isAuthor) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You are not authorized to change this status.')),
      );
      return;
    }

    // Present a dialog with status options excluding the current status
    PostStatus? selectedStatus = await showDialog<PostStatus>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text("Change Status"),
          children: PostStatus.values
              .where((status) => status != currentStatus) // Exclude current status
              .map((status) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, status); // Return the selected status
              },
              child: Text(status.toReadableString()),
            );
          }).toList(),
        );
      },
    );

    // If a new status is selected and it's different from the current status
    if (selectedStatus != null && selectedStatus != currentStatus) {
      try {
        // Update the status in Firestore
        await FirebaseFirestore.instance
            .collection('post')
            .doc(docId)
            .update({
          'status': selectedStatus.toDatabaseValue(),
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Status updated to "${selectedStatus.toReadableString()}"')),
        );

        // Refresh markers to reflect the updated status
        _refreshMarkers();
      } catch (e) {
        // Show error message if update fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: ${e.toString()}')),
        );
      }
    }
  }

  void _showPostDetails(String docId, Map<String, dynamic> postData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // To make modal take up more space if needed
      builder: (context) {
        DateTime? utcDate = postData['date']?.toDate();
        String formattedDate = utcDate != null
            ? DateFormat.yMMMd().add_jm().format(utcDate.toLocal())
            : 'Date not available';
        double screenHeight = MediaQuery.of(context).size.height;

        // Convert status string to enum and then to readable string
        PostStatus currentStatus = PostStatusExtension.fromDatabaseValue(postData['status'] ?? 'rideNeeded');
        String readableStatus = currentStatus.toReadableString();

        return Container(
          constraints: BoxConstraints(
            maxHeight: screenHeight * 2 / 3, 
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Header with title and close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Post Detail",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Content
              Row(
                children: [
                  Text("Content: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(child: Text(postData['content'] ?? "No content")),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text("Animal Category: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(child: Text(postData['category'] ?? "N/A")),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text("Location: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(child: Text("${postData['longitude']}, ${postData['latitude']}")),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text("Posted on: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(child: Text(formattedDate)),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text("Address: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(child: Text(postData['address'] ?? "N/A")),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text("Phone: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(child: Text(postData['phone'] ?? "N/A")),
                ],
              ),
              SizedBox(height: 10),
              // Status Row with Edit Button
              Row(
                children: [
                  Text("Status: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(child: Text(readableStatus)),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    tooltip: 'Change Status',
                    onPressed: () => _changeStatus(docId, currentStatus),
                  ),
                ],
              ),
              SizedBox(height: 25),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  FloatingActionButton(
                    heroTag: 'phone',
                    onPressed: () => _launchPhoneURL(postData['phone'] ?? ''),
                    child: Icon(Icons.phone),
                    // backgroundColor: const Color.fromARGB(255, 234, 203, 112),
                  ),
                  FloatingActionButton(
                    heroTag: 'map',
                    onPressed: () => _launchMapURL(postData['latitude'], postData['longitude']),
                    child: Icon(Icons.map),
                    // backgroundColor: const Color.fromARGB(255, 118, 185, 239),
                  ),
                  FloatingActionButton(
                    heroTag: 'navigation',
                    onPressed: () => _launchNavigationURL(postData['latitude'], postData['longitude']),
                    child: Icon(Icons.navigation),
                    // backgroundColor: Colors.green,
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Comments Section
              if (postData['comments'] != null && (postData['comments'] as List).isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: postData['comments']?.length ?? 0,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(Icons.comment),
                        title: Text(postData['comments'][index]['text'] ?? ''),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _writePost() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WritePostPage(
          latitude: _currentLatLng.latitude,
          longitude: _currentLatLng.longitude,
        ),
      ),
    );
  }

  /// Refreshes the map markers by reloading posts.
  void _refreshMarkers() {
    setState(() {
      _markers.clear();
    });
    _loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(target: _currentLatLng, zoom: 15,),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          markers: Set<Marker>.of(_markers.values),
          mapType: MapType.normal,
        ),
        if (_isLoading)
          Center(child: CircularProgressIndicator()),
        Positioned(
          bottom: 20,
          left: 20,
          child: Column(
            children: [
              FloatingActionButton(
                onPressed: _writePost,
                child: Icon(Icons.add, semanticLabel: "Add a new post, including location and other details."),
                tooltip: "Add a new post, including location and other details.",
                backgroundColor: const Color.fromARGB(255, 234, 203, 112),
              ),
              SizedBox(height: 10),
              FloatingActionButton(
                onPressed: _refreshMarkers,
                child: Icon(Icons.refresh, semanticLabel: "Refresh the map markers to display the latest information."),
                tooltip: "Refresh the map markers to display the latest information.",
                backgroundColor: const Color.fromARGB(255, 118, 185, 239),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

  /// A component that displays hospitals on a Google Map.
class HospitalMapComponent extends StatefulWidget {
  final ThemeData theme;

  const HospitalMapComponent({Key? key, required this.theme}) : super(key: key);

  @override
  _HospitalMapComponentState createState() => _HospitalMapComponentState();
}

  /// A component that displays hospitals on a Google Map.
class _HospitalMapComponentState extends State<HospitalMapComponent> {
  GoogleMapController? _mapController;
  LatLng _currentLatLng = const LatLng(37.7749, -122.4194);
  Map<MarkerId, Marker> _markers = {};
  bool _showOverlay = false;
  Map<String, dynamic>? _selectedPostData;
  bool _isLoading = true;
  List<Hospital> hospitals = [
    Hospital(
      name: "Squirrel Refuge",
      address: "Vancouver, WA 98668",
      phone: "360-836-0955",
      altPhone: "",
      specialty: "Small mammals only; no raccoons",
      latLng: LatLng(45.640628, -122.624233),
    ),
    Hospital(
      name: "Central Washington Wildlife Hospital",
      address: "Ephrata, WA",
      altPhone: "",
      phone: "509-450-7016",
      specialty: "Small mammals, porcupine, and opossum",
      latLng: LatLng(47.31764, -119.55365),
    ),
    Hospital(
      name: "Twin Harbors Wildlife Center",
      address: "4 Old Beacon Rd, Montesano, WA 98563",
      phone: "360-861-4556",
      altPhone: "",
      specialty: "Birds of prey; other birds; some small mammals; no raccoons",
      latLng: LatLng(46.983305, -123.566021),
    ),
    Hospital(
      name: "Sarvey Wildlife Care Center",
      address: "13106 148th St NE, Arlington, WA 98223",
      phone: "360-435-4817",
      altPhone: "",
      specialty: "All species except large carnivores; coyote, fox, and bobcat okay - Also accepting deer fawns.",
      latLng: LatLng(48.130131, -122.053933),
    ),
    Hospital(
      name: "Center Valley Animal Rescue",
      address: "11900 Center Rd, Quilcene, WA 98376",
      phone: "360-765-0598",
      altPhone: "",
      specialty: "Most mammals and birds",
      latLng: LatLng(47.863380, -122.850744),
    ),
    Hospital(
      name: "Discovery Bay Wild Bird Rescue",
      address: "1014 Parkridge Dr, Port Townsend, WA 98368",
      phone: "360-379-0802",
      altPhone: "360-643-0056",
      specialty: "Birds of prey, other birds including seabirds",
      latLng: LatLng(48.068945, -122.808996),
    ),
    Hospital(
      name: "PAWS Wildlife Center",
      address: "13508 WA-9, Snohomish, WA 98296",
      phone: "425-412-4040",
      altPhone: "",
      specialty: "All species including large carnivores - No longer accepting deer fawns.",
      latLng: LatLng(47.874054, -122.113960),
    ),
    Hospital(
      name: "SR3 Sealife Response, Rehabilitation and Research",
      address: "22650 Dock Ave S, Des Moines, WA 98198",
      phone: "206-947-4253",
      altPhone: "",
      specialty: "Marine mammals",
      latLng: LatLng(47.398456, -122.327474),
    ),
    Hospital(
      name: "West Sound Wildlife Shelter",
      address: "7501 NE Dolphin Dr, Bainbridge Island, WA 98110",
      phone: "206-855-9057",
      altPhone: "",
      specialty: "All species",
      latLng: LatLng(47.707716, -122.549070),
    ),
    Hospital(
      name: "Mountain Top Wildlife",
      address: "White Salmon, WA",
      phone: "541-615-1565",
      altPhone: "",
      specialty: "All species",
      latLng: LatLng(45.723997104, -121.483498066),
    ),
    Hospital(
      name: "Peninsula Wild Care",
      address: "Ocean Park, WA",
      phone: "360-947-3188",
      altPhone: "",
      specialty: "Squirrels, chipmunks, opossums, cottontails, raccoons, songbirds, waterfowl, seabirds",
      latLng: LatLng(46.489664708, -124.042166498),
    ),
    Hospital(
      name: "Wolf Hollow Wildlife Rehabilitation Center",
      address: "284 Boyce Rd, Friday Harbor, WA 98250",
      phone: "360-378-5000",
      altPhone: "",
      specialty: "All species except large carnivores (fox okay)",
      latLng: LatLng(48.533655, -123.097822),
    ),
    Hospital(
      name: "Fidalgo Animal Medical Center",
      address: "3303 Commercial Ave, Anacortes, WA 98221",
      phone: "360-293-2186",
      altPhone: "",
      specialty: "STABILIZATION CARE ONLY",
      latLng: LatLng(48.495477, -122.612382),
    ),
    Hospital(
      name: "Bat Rehabilitation",
      address: "Bothell, WA 98012",
      phone: "425-481-7446",
      altPhone: "",
      specialty: "Bats only",
      latLng: LatLng(47.77167, -122.204421),
    ),
    Hospital(
      name: "Happy Valley Bats",
      address: "Stanwood, WA 98292",
      phone: "360-652-7690",
      altPhone: "360-631-0668",
      specialty: "Bats only",
      latLng: LatLng(48.242276, -122.351171),
    ),
    Hospital(
      name: "Wisp of Hope Bat Rescue and Rehabilitation",
      address: "Arlington, WA",
      phone: "425-293-2708",
      altPhone: "",
      specialty: "Bats only",
      latLng: LatLng(48.19871, -122.12514),
    ),
    Hospital(
      name: "Hunter Veterinary Clinic",
      address: "301 W Indiana Ave, Spokane, WA 99205",
      phone: "509-327-9354",
      altPhone: "",
      specialty: "Birds of prey only",
      latLng: LatLng(47.674827, -117.416139),
    ),
    Hospital(
      name: "Raindancer Wild Bird Rescue",
      address: "Olympia, WA 98502",
      phone: "360-970-5402",
      altPhone: "",
      specialty: "Birds of prey",
      latLng: LatLng(47.038833178, -122.88916311),
    ),
    Hospital(
      name: "WHS Wildlife Rehabilitation Center",
      address: "5602 Mission Road, Bellingham, WA 98226",
      phone: "360-966-8845",
      altPhone: "",
      specialty: "All species",
      latLng: LatLng(48.843780, -122.353931),
    ),
    Hospital(
      name: "Cervid Rehabilitation",
      address: "Palouse, WA",
      phone: "208-791-3908",
      altPhone: "",
      specialty: "Deer fawns from Region 1 only",
      latLng: LatLng(46.909996, -117.075259),
    ),
    Hospital(
      name: "WSU Exotics and Wildlife Ward",
      address: "100 Grimes Way, Pullman, WA 99164",
      phone: "509-335-0711",
      altPhone: "",
      specialty: "All species including large carnivores",
      latLng: LatLng(46.729655, -117.152320),
    ),
  ];

  Map<MarkerId, Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _determinePosition().then((_) {
      _setMarkers();
      _isLoading = false;
    });
  }

  /// Initializes the map and loads necessary data.
  Future<void> _initMapAndPosts() async {
    await _determinePosition();
    // await _loadPosts();
    setState(() {
      _isLoading = false; 
    });
  }

  /// Callback when the map is created.
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  /// Sets markers for each hospital on the map.
  void _setMarkers() {
    final newMarkers = <MarkerId, Marker>{};
    for (Hospital hospital in hospitals) {
      MarkerId markerId = MarkerId(hospital.name);
      Marker marker = Marker(
        markerId: markerId,
        position: hospital.latLng,
        infoWindow: InfoWindow(
          title: hospital.name,
          snippet: '${hospital.address}, ${hospital.phone}',
          onTap: () {
            _showHospitalDetails(hospital);
          },
        ),
      );
      newMarkers[markerId] = marker;
    }
    setState(() {
      _markers = newMarkers;
    });
  }

  /// Determines the current position of the user.
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLatLng = LatLng(position.latitude, position.longitude);
      });
      
      // Update user location in provider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.updateLocation(position.latitude, position.longitude);
      
      _mapController?.animateCamera(CameraUpdate.newLatLng(_currentLatLng));
    } catch (e) {
      return Future.error('Failed to get location: ${e.toString()}');
    }
  }

  /// Launches the phone dialer with the given [phoneNumber].
  void _launchPhoneURL(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneUri';
    }
  }

  /// Launches navigation to the specified [latitude] and [longitude].
  void _launchNavigationURL(double latitude, double longitude) async {
    final Uri navigationUri = Uri.parse('google.navigation:q=$latitude,$longitude');
    if (await canLaunchUrl(navigationUri)) {
      await launchUrl(navigationUri);
    } else {
      throw 'Could not launch $navigationUri';
    }
  }


  /// Launches the map application to the specified [latitude] and [longitude].
  void _launchMapURL(double latitude, double longitude) async {
    final Uri mapUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    if (await canLaunchUrl(mapUri)) {
      await launchUrl(mapUri);
    } else {
      throw 'Could not launch $mapUri';
    }
  }

  /// Displays a custom dialog with the given [title] and [content].
  void showCustomDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Refreshes the hospital markers on the map.
  void _refreshMarkers() {
    setState(() {
      _markers.clear();
    });
    _setMarkers();
  }

  /// Shows the details of a selected hospital.
  void _showHospitalDetails(Hospital hospital) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        double screenHeight = MediaQuery.of(context).size.height;

        return Container(
          constraints: BoxConstraints(
            maxHeight: screenHeight * 2 / 3, 
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Hospital Details",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text("Name: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(child: Text(hospital.name)),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text("Address: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(child: Text(hospital.address)),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text("Phone: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(child: Text(hospital.phone)),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text("Specialty: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(child: Text(hospital.specialty)),
                ],
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  FloatingActionButton(
                    onPressed: () => _launchPhoneURL(hospital.phone),
                    child: Icon(Icons.phone),
                    tooltip: 'Call the hospital',
                    // backgroundColor: Theme.of(context).primaryColor,
                  ),
                  FloatingActionButton(
                    onPressed: () => _launchMapURL(hospital.latLng.latitude, hospital.latLng.longitude),
                    child: Icon(Icons.map),
                    tooltip: 'Open map location',
                    // backgroundColor: Theme.of(context).accentColor,
                  ),
                  FloatingActionButton(
                    onPressed: () => _launchNavigationURL(hospital.latLng.latitude, hospital.latLng.longitude),
                    child: Icon(Icons.navigation),
                    tooltip: 'Navigate to hospital',
                    // backgroundColor: Theme.of(context).primaryColorLight,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(target: _currentLatLng, zoom: 15,),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          markers: Set<Marker>.of(_markers.values),
          mapType: MapType.normal,
        ),
        if (_isLoading)
          Center(child: CircularProgressIndicator()),
        Positioned(
          bottom: 20,
          left: 20,
          child: Column(
            children: [
              // FloatingActionButton(
              //   onPressed: _writePost,
              //   child: Icon(Icons.add),
              //   backgroundColor: const Color.fromARGB(255, 234, 203, 112),
              // ),
              SizedBox(height: 10),
              FloatingActionButton(
                onPressed: _refreshMarkers,
                child: Icon(Icons.refresh),
                backgroundColor: const Color.fromARGB(255, 118, 185, 239),
              ),
            ],
          ),
        ),
      ],
    );
  }
}