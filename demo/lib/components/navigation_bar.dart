import 'package:flutter/material.dart';
import '../pages/map.dart';
import '../pages/wikipedia.dart';
import '../pages/profile.dart';

/// A [StatefulWidget] that provides a bottom navigation bar to switch between
/// different pages: Map, Wikipedia, and Profile.
///
/// The [NavigationExample] widget maintains the current selected page index
/// and updates the displayed page accordingly when a navigation destination
/// is selected.
class NavigationExample extends StatefulWidget {
  /// Creates a [NavigationExample] widget.
  ///
  /// The [key] parameter is optional and is passed to the superclass.
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

/// The state for the [NavigationExample] widget.
///
/// Manages the current page index and provides the corresponding page
/// based on user navigation.
class _NavigationExampleState extends State<NavigationExample> {
  /// The index of the currently selected page.
  ///
  /// Defaults to `0`, which corresponds to the Map page.
  int currentPageIndex = 0;

  /// Returns the widget corresponding to the given [index].
  ///
  /// - `0`: [MapPage] displaying interactive maps and location-based information.
  /// - `1`: [WikipediaPage] providing access to summarized articles and related content.
  /// - `2`: [ProfilePage] allowing the user to view and manage profile details.
  ///
  /// If an invalid [index] is provided, defaults to [MapPage].
  ///
  /// ## Parameters
  ///
  /// - [index]: The index of the desired page.
  ///
  /// ## Returns
  ///
  /// A [Widget] corresponding to the selected page.
  Widget _getPage(int index) {
    final ThemeData theme = Theme.of(context);
    switch (index) {
      case 0:
        return MapPage(theme: theme);
      case 1:
        return WikipediaPage(theme: theme);
      case 2:
        return ProfilePage(theme: theme);
      default:
        return MapPage(theme: theme);  
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// The bottom navigation bar that allows switching between pages.
      ///
      /// Contains three [NavigationDestination]s:
      /// - Map
      /// - Wikipedia
      /// - Profile
      bottomNavigationBar: NavigationBar(
        /// Callback when a destination is selected.
        ///
        /// Updates the [currentPageIndex] and rebuilds the widget to display
        /// the selected page.
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        /// The color of the indicator that appears below the selected destination.
        indicatorColor: Colors.amber,

        /// The index of the currently selected destination.
        selectedIndex: currentPageIndex,

        /// The list of destinations in the navigation bar.
        ///
        /// Each [NavigationDestination] includes:
        /// - `icon`: The default icon.
        /// - `selectedIcon`: The icon when selected.
        /// - `label`: The text label.
        /// - `tooltip`: Additional information displayed on long press.
        destinations: const <NavigationDestination>[
          NavigationDestination(
            selectedIcon: Icon(Icons.map, semanticLabel: "Navigate to the Map page. View interactive maps and location-based information."),
            icon: Icon(Icons.public, semanticLabel: "Navigate to the Map page."),
            label: 'Map',
            tooltip: "Navigate to the Map page. View interactive maps and location-based information.",
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.article, semanticLabel: "Navigate to the Wikipedia page. Access summarized articles and related content."),
            icon: Icon(Icons.description, semanticLabel: "Navigate to the Wikipedia page."),
            label: 'Wikipedia',
            tooltip: "Navigate to the Wikipedia page. Access summarized articles and related content.",
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.account_circle, semanticLabel: "Navigate to the Profile page. View and manage your profile details."),
            icon: Icon(Icons.person, semanticLabel: "Navigate to the Profile page."),
            label: 'Profile',
            tooltip: "Navigate to the Profile page. View and manage your profile details.",
          ),
        ],
      ),
      /// The main content of the scaffold, displaying the selected page.
      body: _getPage(currentPageIndex),  
    );
  }
}
