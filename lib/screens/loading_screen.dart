import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingScreen extends StatefulWidget {
  final String message;
  final Future<void> Function() loadData;
  final Widget nextScreen;

  const LoadingScreen({
    super.key,
    required this.message,
    required this.loadData,
    required this.nextScreen,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  // late String _displayMsg = widget.message;

  @override
  void initState() {
    super.initState();
    widget.loadData().then((_) async {
      await Future.delayed(const Duration(seconds: 6));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          // MaterialPageRoute(builder: (_) => widget.nextScreen)
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (_, _, _) => widget.nextScreen,
            transitionsBuilder:
                (_, animation, __, child) =>
                    FadeTransition(opacity: animation, child: child),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // CircularProgressIndicator(
            //   strokeWidth: 3,
            //   color: Colors.blue[800],
            // ),
            //
            // SizedBox(height: size.height * 0.01,),

            Lottie.asset(
              'assets/animations/robot_searching.json',
              animate: true
            ),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
