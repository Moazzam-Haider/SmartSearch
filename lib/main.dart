import 'dart:developer';
import 'dart:io';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:smartsearch/consts.dart';

void main() {
  Gemini.init(apiKey: GEMINI_API_KEY);
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'Smart Search',
          theme: themeNotifier.currentTheme,
          home: const ChatScreen(),
        );
      },
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final Gemini gemini = Gemini.instance;

  bool _isLoading = false;
  OverlayEntry? _overlayEntry;

  ChatUser currentUser = ChatUser(id: "0", firstName: "Useer");
  ChatUser geminiUser = ChatUser(
      id: "1",
      firstName: "Gemini",
      profileImage:
          "https://seeklogo.com/images/G/google-gemini-logo-A5787B2669-seeklogo.com.png");
  List<ChatMessage> messages = [];
  // Search history
  final Map<String, List<String>> _searchHistory = {
    'Today': [],
    'Last 7 Days': [],
    'Last 30 Days': [],
  };

  void sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      setState(() {
        String message = _controller.text.trim();
        _messages.add({'user': message});
        _controller.clear();
        _addToHistory(message);
      });
    }
  }

  void _addToHistory(String message) {
    final now = DateTime.now();
    final formattedDate = DateFormat('yMd').format(now);

    final oneDayAgo = now.subtract(const Duration(days: 1));
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    if (_searchHistory['Today']!.isNotEmpty) {
      final lastEntry = DateFormat('yMd').parse(_searchHistory['Today']!.last);
      if (lastEntry.isBefore(oneDayAgo)) {
        _searchHistory['Last 7 Days']!.addAll(_searchHistory['Today']!);
        _searchHistory['Today']!.clear();
      }
    }

    if (_searchHistory['Last 7 Days']!.isNotEmpty) {
      final lastEntry =
          DateFormat('yMd').parse(_searchHistory['Last 7 Days']!.last);
      if (lastEntry.isBefore(sevenDaysAgo)) {
        _searchHistory['Last 30 Days']!.addAll(_searchHistory['Last 7 Days']!);
        _searchHistory['Last 7 Days']!.clear();
      }
    }

    if (_searchHistory['Last 30 Days']!.isNotEmpty) {
      final lastEntry =
          DateFormat('yMd').parse(_searchHistory['Last 30 Days']!.last);
      if (lastEntry.isBefore(thirtyDaysAgo)) {
        _searchHistory['Last 30 Days']!.clear();
      }
    }

    setState(() {
      _searchHistory['Today']!.add(formattedDate);
    });
  }

  Widget _buildHistorySection(String period) {
    final historyList = _searchHistory[period]!;

    return ExpansionTile(
      title: Text(period),
      children: [
        if (historyList.isEmpty)
          const ListTile(
            title: Text('No history available'),
          )
        else
          ...historyList.map(
            (entry) => ListTile(
              title: Text(entry),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _deleteHistory(period, entry);
                },
              ),
            ),
          ),
      ],
    );
  }

  void _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      log('File Name: ${file.name}');
      log('File Size: ${file.size}');
      log('File Path: ${file.path}');

      setState(() {
        _messages.add({
          'user': 'Document: ${file.name}',
          'filePath': file.path,
          'fileType': 'document'
        });
      });
    } else {
      // User canceled the picker
    }
  }

  void _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'png',
        'jpg',
        'jpeg',
        'gif',
        'bmp',
        'tiff',
        'webp',
        'txt'
      ],
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      log('File Name: ${file.name}');
      log('File Size: ${file.size}');
      log('File Path: ${file.path}');

      if (file.extension != null &&
          ['png', 'jpg', 'jpeg', 'gif', 'bmp', 'tiff', 'webp']
              .contains(file.extension!.toLowerCase())) {
        setState(() {
          _messages.add({
            'user': 'Image: ${file.name}',
            'filePath': file.path,
            'fileType': 'image'
          });
        });
      }
    } else {
      // User canceled the picker
    }
  }

  void _showAttachmentOptions() {
    if (_overlayEntry != null && _overlayEntry!.mounted) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    } else {
      OverlayState? overlayState = Overlay.of(context);
      _overlayEntry = OverlayEntry(
        builder: (context) => GestureDetector(
          onTap: () {
            _overlayEntry?.remove();
            _overlayEntry = null;
          },
          behavior: HitTestBehavior.translucent,
          child: Stack(
            children: [
              Positioned(
                left: 16,
                bottom: 80,
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FloatingActionButton(
                        heroTag: 'document',
                        onPressed: () {
                          _pickDocument();
                          _overlayEntry?.remove();
                          _overlayEntry = null;
                        },
                        backgroundColor: const Color.fromARGB(255, 42, 42, 42),
                        child: const Icon(
                          Icons.insert_drive_file,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: 'image',
                        onPressed: () {
                          _pickImage();
                          _overlayEntry?.remove();
                          _overlayEntry = null;
                        },
                        backgroundColor: const Color.fromARGB(255, 42, 42, 42),
                        child: const Icon(
                          Icons.image,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          if (overlayState.mounted) {
            overlayState.insert(_overlayEntry!);
          }
        },
      );
    }
  }

  void _addNewChat() {
    setState(() {
      _messages.clear();
      _controller.clear();
      _addToHistory('New Chat at ${DateFormat('yMd').format(DateTime.now())}');
    });
  }

  void _deleteHistory(String period, String entry) {
    setState(() {
      _searchHistory[period]!.remove(entry);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Smart Search',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color.fromARGB(255, 42, 42, 42)
              : const Color.fromARGB(255, 42, 42, 42),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.chat),
              onPressed: _addNewChat,
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.grey,
                ),
                child: Text('Search History'),
              ),
              _buildHistorySection('Today'),
              _buildHistorySection('Last 7 Days'),
              _buildHistorySection('Last 30 Days'),
              ListTile(
                title: const Text('Toggle Theme'),
                trailing: Icon(themeNotifier.currentTheme == ThemeData.light()
                    ? Icons.dark_mode
                    : Icons.light_mode),
                onTap: () {
                  themeNotifier.toggleTheme();
                },
              ),
            ],
          ),
        ),
        body: _buildUI(),
      ),
    );
  }

  Widget _buildUI() {
    return DashChat(
        currentUser: currentUser, onSend: _sendMessage, messages: messages);
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });
    try {
      String question = chatMessage.text;
      gemini.streamGenerateContent(question).listen((event) {
        ChatMessage? lastMessage = messages.firstOrNull;
        if (lastMessage != null && lastMessage.user == geminiUser) {
          lastMessage = messages.removeAt(0);

          String response = event.content?.parts?.fold(
                  "", (previous, current) => "$previous ${current.text}") ??
              "";
          lastMessage.text += response;
          setState(() {
            messages = [lastMessage!, ...messages];
          });
        } else {
          String response = event.content?.parts?.fold(
                  "", (previous, current) => "$previous ${current.text}") ??
              "";
          ChatMessage message = ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: response,
          );
          setState(() {
            messages = [message, ...messages];
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }
}
