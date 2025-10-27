import 'package:chat_app/models/check_if_logged_in.dart';
import 'package:chat_app/models/local_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await LocalStorage.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.indigo.shade600;
    return SafeArea(
      top: false,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: color,
          canvasColor: Colors.white,

          appBarTheme: AppBarTheme(
            backgroundColor: color,
            elevation: 0.0,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
        ),

        home: CheckIfLoggedIn(),
        // home: CreateAccount(number: "+977 9800000000",),
        // home: ChatScreen(currentUserId: 'IedlfEzyxLQZ8BG5jfYn4jxUXli2', otherUserId: '8vvHjisC2uVVg9jD2SdPUHLcSAz2', chatRoomId: ChatRoom.generateChatRoomId('IedlfEzyxLQZ8BG5jfYn4jxUXli2', '8vvHjisC2uVVg9jD2SdPUHLcSAz2'),),
      ),
    );
  }
}
