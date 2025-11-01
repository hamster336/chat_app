import 'package:flutter/material.dart';

class UiHelper {
  static Widget customTextField(
    TextEditingController controller,
    String text,
    IconData icon,
    bool hide,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: TextField(
        controller: controller,
        obscureText: hide,
        decoration: InputDecoration(
          suffixIcon: Icon(icon),
          labelText: text,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  static Future customAlertBox(BuildContext context, String text) {
    return showDialog(
      // barrierColor: Colors.black12,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            text,
            style: TextStyle(fontSize: 17, color: Colors.black),
            textDirection: TextDirection.ltr,
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  static Future customBottomSheet(BuildContext context, String text) {
    final size = MediaQuery.of(context).size;
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(text, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500)),

              const SizedBox(height: 40,),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: size.width * 0.4,
                    height: size.height * 0.075,
                    child: ElevatedButton(onPressed: (){},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade400
                        ),
                        child: const Text('Cancel', style: TextStyle(fontSize: 25, color: Colors.white),)
                    ),
                  ),

                  SizedBox(
                    width: size.width * 0.4,
                    height: size.height * 0.075,
                    child: ElevatedButton(onPressed: (){},
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade400
                        ),
                        child: const Text('OK', style: TextStyle(fontSize: 25, color: Colors.white),)
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  static void customSnackBar(
      BuildContext context,
      String text,
      {
        IconData? icon = Icons.info_outline,
        Color backgroundColor = Colors.white,
        Color textColor = Colors.black87,
        Duration duration = const Duration(seconds: 3),
      }) {
    final snackBar = SnackBar(
      content: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor.withValues(alpha: 0.8), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
      // width: size.width * 0.8,
      duration: duration,
      elevation: 8,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: backgroundColor.withValues(alpha: 0.8),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

}
