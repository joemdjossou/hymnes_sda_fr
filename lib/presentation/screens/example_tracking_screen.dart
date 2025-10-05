import 'package:flutter/material.dart';

import '../../core/mixins/posthog_tracking_mixin.dart';
import '../../core/models/hymn.dart';

/// Example screen showing how to use PostHog tracking in widgets
class ExampleTrackingScreen extends StatefulWidget {
  const ExampleTrackingScreen({super.key});

  @override
  State<ExampleTrackingScreen> createState() => _ExampleTrackingScreenState();
}

class _ExampleTrackingScreenState extends State<ExampleTrackingScreen>
    with PostHogTrackingMixin {
  final TextEditingController _searchController = TextEditingController();
  final List<Hymn> _searchResults = [];

  @override
  void initState() {
    super.initState();
    // Track screen view
    trackScreenView('example_tracking_screen');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    // Simulate search results
    setState(() {
      _searchResults.clear();
      for (int i = 1; i <= 5; i++) {
        _searchResults.add(Hymn(
          number: i.toString(),
          title: 'Hymn $i - $query',
          lyrics: 'Sample lyrics for hymn $i',
          author: 'Author $i',
          composer: 'Composer $i',
          style: 'Traditional',
          sopranoFile: 'soprano_$i.mp3',
          altoFile: 'alto_$i.mp3',
          tenorFile: 'tenor_$i.mp3',
          bassFile: 'bass_$i.mp3',
          midiFile: 'midi_$i.mid',
          theme: 'Worship',
          subtheme: 'Praise',
          story: 'Story for hymn $i',
        ));
      }
    });

    // Track search event
    trackSearch(query, _searchResults.length);
  }

  void _onHymnTap(Hymn hymn, int index) {
    // Track search result click
    trackSearchResultClick(_searchController.text, hymn.number, index + 1);

    // Track hymn view
    trackHymnView(hymn.number, hymn.title, source: 'search');

    // Navigate to hymn detail (example)
    Navigator.pushNamed(context, '/hymn/${hymn.number}');
  }

  void _onShareHymn(Hymn hymn) {
    // Track hymn share
    trackHymnShare(hymn.number, hymn.title, 'share_sheet');

    // Show share dialog (example)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Hymn'),
        content: Text('Share ${hymn.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement actual sharing logic here
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _onError() {
    // Track error event
    trackError('user_action_error', 'User triggered error for testing');

    // Show error dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: const Text('This is a test error for PostHog tracking.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _onCustomEvent() {
    // Track custom event
    trackCustomEvent('custom_button_clicked', {
      'button_name': 'custom_event_button',
      'timestamp': DateTime.now().toIso8601String(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Custom event tracked!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PostHog Tracking Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search section
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search hymns',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: (_) => _onSearch(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onSearch,
              child: const Text('Search'),
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _onError,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Test Error'),
                ),
                ElevatedButton(
                  onPressed: _onCustomEvent,
                  child: const Text('Custom Event'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search results
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final hymn = _searchResults[index];
                  return Card(
                    child: ListTile(
                      title: Text(hymn.title),
                      subtitle: Text('Hymn ${hymn.number}'),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'share',
                            child: const Text('Share'),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'share') {
                            _onShareHymn(hymn);
                          }
                        },
                      ),
                      onTap: () => _onHymnTap(hymn, index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
