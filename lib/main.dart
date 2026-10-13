import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

const String kFavoritesBox = 'favoritesBox';
const String kPostsUrl = 'https://jsonplaceholder.typicode.com/posts';

class RedditColors {
  static const Color orange = Color(0xFFFF4500);
  static const Color orangeSoft = Color(0xFFFFEDE5);
  static const Color blue = Color(0xFF0079D3);
  static const Color blueSoft = Color(0xFFE5F2FB);
  static const Color canvas = Color(0xFFDAE0E6);
  static const Color card = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF1C1C1C);
  static const Color muted = Color(0xFF787C7E);
  static const Color border = Color(0xFFEDEFF1);
  static const Color red = Color(0xFFEA0027);
}

// Entry point
// Part 3 - Hive initialisation before runApp
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox(kFavoritesBox);
  runApp(const PostReaderApp());
}

// App root
// Part 1 - three named routes
class PostReaderApp extends StatelessWidget {
  const PostReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Post Reader & Favorites',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) => const PostsScreen(),
        '/details': (context) => const PostDetailsScreen(),
        '/favorites': (context) => const FavoritesScreen(),
      },
    );
  }

  ThemeData _buildTheme() {
    final scheme =
        ColorScheme.fromSeed(seedColor: RedditColors.orange).copyWith(
      primary: RedditColors.orange,
      onPrimary: Colors.white,
      secondary: RedditColors.blue,
      surface: RedditColors.card,
      onSurface: RedditColors.ink,
      error: RedditColors.red,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: RedditColors.canvas,
      dividerColor: RedditColors.border,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: RedditColors.blue,
        selectionHandleColor: RedditColors.blue,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: RedditColors.orange,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: RedditColors.blue,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: RedditColors.orange,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: StadiumBorder(),
        extendedTextStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF6F7F8),
        labelStyle: const TextStyle(color: RedditColors.muted),
        floatingLabelStyle: const TextStyle(color: RedditColors.blue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: RedditColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: RedditColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: RedditColors.blue, width: 1.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: RedditColors.ink,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// Shared helpers and widgets
void showSnack(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? RedditColors.red : RedditColors.ink,
      ),
    );
}

AppBar redditAppBar({
  required String title,
  bool showBack = false,
  required BuildContext context,
  List<Widget> actions = const [],
}) {
  return AppBar(
    backgroundColor: RedditColors.card,
    foregroundColor: RedditColors.ink,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    automaticallyImplyLeading: false,
    titleSpacing: showBack ? 0 : 16,
    leading: showBack
        ? IconButton(
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          )
        : null,
    title: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: RedditColors.orange,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.forum, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: RedditColors.ink,
          ),
        ),
      ],
    ),
    actions: actions,
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(1),
      child: Divider(height: 1, thickness: 1, color: RedditColors.border),
    ),
  );
}

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  const InfoChip({
    super.key,
    required this.icon,
    required this.label,
    this.background = const Color(0xFFF6F7F8),
    this.foreground = RedditColors.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: foreground),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback? onTap;
  final bool expanded;
  final Widget? footer;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.expanded = false,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final String title = '${post['title'] ?? ''}';
    final String body = '${post['body'] ?? ''}';
    final String userId = '${post['userId'] ?? 1}';

    return Material(
      color: RedditColors.card,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: RedditColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: RedditColors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      'r/',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'r/posts',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: RedditColors.ink,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Posted by u/user$userId',
                    style: const TextStyle(
                      fontSize: 12,
                      color: RedditColors.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                maxLines: expanded ? null : 2,
                overflow:
                    expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: expanded ? 22 : 17,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: RedditColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                body,
                maxLines: expanded ? null : 2,
                overflow:
                    expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: expanded ? 16 : 14,
                  height: 1.5,
                  color: expanded ? RedditColors.ink : RedditColors.muted,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  InfoChip(icon: Icons.tag, label: 'Post ${post['id']}'),
                  InfoChip(
                    icon: Icons.person_outline,
                    label: 'User $userId',
                  ),
                ],
              ),
              if (footer != null) ...[
                const SizedBox(height: 12),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                color: RedditColors.card,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: RedditColors.orange),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: RedditColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: RedditColors.muted,
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 20),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

// Screen 1 - Posts
// Part 2 - GET and POST
class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  List<Map<String, dynamic>> _serverPosts = [];
  final List<Map<String, dynamic>> _localPosts = [];
  int _localId = 100;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  // GET request with status code check and jsonDecode
  Future<void> _fetchPosts() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await http
          .get(Uri.parse(kPostsUrl))
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _serverPosts =
              data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _loading = false;
        });
      } else {
        setState(() {
          _error =
              'The request failed with status code ${response.statusCode}.';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load posts. Please check your internet connection.';
        _loading = false;
      });
    }
  }

  // POST request with jsonEncode, 201 means success
  Future<void> _createPost(String title, String body) async {
    try {
      final response = await http
          .post(
            Uri.parse(kPostsUrl),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({'title': title, 'body': body, 'userId': 1}),
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 201) {
        final created = jsonDecode(response.body);
        setState(() {
          _localId++;
          _localPosts.insert(0, {
            'id': _localId,
            'title': title.isEmpty ? '(no title)' : title,
            'body': body.isEmpty ? '(no body)' : body,
            'userId': 1,
          });
        });
        showSnack(
          context,
          'Post created successfully (server id: ${created['id']}).',
        );
      } else {
        showSnack(
          context,
          'Failed to create post. Status code: ${response.statusCode}.',
          error: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      showSnack(context, 'Failed to create post. Please try again.',
          error: true);
    }
  }

  void _showCreateDialog() {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: RedditColors.card,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Create a post',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bodyController,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Body'),
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final title = titleController.text.trim();
                final body = bodyController.text.trim();
                Navigator.pop(dialogContext);
                _createPost(title, body);
              },
              child: const Text('Post'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: redditAppBar(
        context: context,
        title: 'Posts',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/favorites'),
              icon: const Icon(Icons.bookmark, size: 20),
              label: const Text('Favorites'),
            ),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('Create post'),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: RedditColors.orange),
      );
    }

    if (_error != null) {
      return EmptyState(
        icon: Icons.wifi_off,
        title: 'Something went wrong',
        message: _error!,
        actionLabel: 'Try again',
        onAction: _fetchPosts,
      );
    }

    final posts = [..._localPosts, ..._serverPosts];

    if (posts.isEmpty) {
      return EmptyState(
        icon: Icons.inbox,
        title: 'No posts yet',
        message: 'Pull down to refresh or create the first post.',
        actionLabel: 'Refresh',
        onAction: _fetchPosts,
      );
    }

    return RefreshIndicator(
      color: RedditColors.orange,
      onRefresh: _fetchPosts,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: PostCard(
              post: post,
              onTap: () {
                // Passing id, title and body as route arguments
                Navigator.pushNamed(
                  context,
                  '/details',
                  arguments: {
                    'id': post['id'],
                    'title': post['title'],
                    'body': post['body'],
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// Screen 2 - Post Details
class PostDetailsScreen extends StatelessWidget {
  const PostDetailsScreen({super.key});

  void _save(BuildContext context, Box box, Map<String, dynamic> post) {
    final key = post['id'];

    // The post id is the key, so the same post can never be saved twice.
    if (box.containsKey(key)) {
      showSnack(context, 'This post is already in your favorites.');
      return;
    }

    box.put(key, {
      'id': post['id'],
      'title': post['title'],
      'body': post['body'],
      'note': '',
    });
    showSnack(context, 'Post saved to favorites.');
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve the arguments sent through the named route
    final args = Map<String, dynamic>.from(
      ModalRoute.of(context)!.settings.arguments as Map,
    );
    final Box box = Hive.box(kFavoritesBox);

    return Scaffold(
      appBar: redditAppBar(
        context: context,
        title: 'Post Details',
        showBack: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/favorites'),
              icon: const Icon(Icons.bookmark, size: 20),
              label: const Text('Favorites'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            PostCard(post: args, expanded: true),
            const SizedBox(height: 14),
            ValueListenableBuilder(
              valueListenable: box.listenable(),
              builder: (context, Box b, _) {
                final bool isSaved = b.containsKey(args['id']);
                return SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: isSaved ? null : () => _save(context, b, args),
                    icon: Icon(isSaved ? Icons.check : Icons.bookmark_add),
                    label: Text(
                      isSaved ? 'Saved to Favorites' : 'Save to Favorites',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Screen 3 - Favorites
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  // Update functionality
  // Editing the personal note and writing it back with put()
  void _editNote(BuildContext context, Box box, Map<String, dynamic> item) {
    final controller = TextEditingController(text: '${item['note'] ?? ''}');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: RedditColors.card,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Personal note',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: TextField(
            controller: controller,
            maxLines: 4,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Write a short note',
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final updated = Map<String, dynamic>.from(item);
                updated['note'] = controller.text.trim();
                box.put(item['id'], updated);
                Navigator.pop(dialogContext);
                showSnack(context, 'Note updated.');
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Delete functionality
  // Removing the saved post with delete()
  Future<bool> _confirmDelete(
    BuildContext context,
    Box box,
    Map<String, dynamic> item,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: RedditColors.card,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Remove favorite',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Text('Remove this post from your favorites?'),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await box.delete(item['id']);
      if (context.mounted) showSnack(context, 'Favorite removed.');
    }
    return false; // the ValueListenableBuilder rebuilds the list itself
  }

  @override
  Widget build(BuildContext context) {
    final Box box = Hive.box(kFavoritesBox);

    return Scaffold(
      appBar: redditAppBar(
        context: context,
        title: 'Favorites',
        showBack: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box b, _) {
          // Read functionality
          // Lists every saved post from the box
          final items =
              b.values.map((e) => Map<String, dynamic>.from(e as Map)).toList();

          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.bookmark_border,
              title: 'No favorites yet',
              message:
                  'Open a post and tap "Save to Favorites" to keep it here.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final String note = '${item['note'] ?? ''}';

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Dismissible(
                    key: ValueKey('fav_${item['id']}'),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (_) => _confirmDelete(context, b, item),
                    background: Container(
                      color: RedditColors.orange,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: PostCard(
                      post: item,
                      footer: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (note.isNotEmpty)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: RedditColors.blueSoft,
                                borderRadius: BorderRadius.circular(8),
                                border: const Border(
                                  left: BorderSide(
                                    color: RedditColors.blue,
                                    width: 4,
                                  ),
                                ),
                              ),
                              child: Text(
                                note,
                                style: const TextStyle(
                                  color: RedditColors.ink,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: () => _editNote(context, b, item),
                                icon: const Icon(Icons.edit, size: 18),
                                label: Text(
                                  note.isEmpty ? 'Add note' : 'Edit note',
                                ),
                              ),
                              const SizedBox(width: 4),
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  foregroundColor: RedditColors.orange,
                                ),
                                onPressed: () =>
                                    _confirmDelete(context, b, item),
                                icon: const Icon(Icons.delete, size: 18),
                                label: const Text('Remove'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
