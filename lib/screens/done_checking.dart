import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class DoneChecking extends StatefulWidget {
  final Widget nextScreen;
  final String message;
  const DoneChecking({super.key, required this.nextScreen, required this.message});

  @override
  State<DoneChecking> createState() => _DoneCheckingState();
}

class _DoneCheckingState extends State<DoneChecking> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), (){
      if(mounted) {
        Navigator.pushReplacement(
          context,
          // MaterialPageRoute(builder: (context) => widget.nextScreen)
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (_, _, _) => widget.nextScreen,
            transitionsBuilder:
                (_, animation, _, child) =>
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
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/animations/Done-check.json',
              animate: true,
              width: size.shortestSide * 0.4,
            ),

            Text(widget.message,
              style: TextStyle(
                // color: Colors.blue,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),
      ),
    );
  }
}
