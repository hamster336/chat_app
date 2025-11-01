import 'package:chat_app/models/chat_details.dart';
import 'package:chat_app/models/messages.dart';
import 'package:flutter/material.dart';

class MessageCard extends StatefulWidget {
  final Message message;
  final Size size;

  const MessageCard({super.key, required this.message, required this.size});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return (widget.message.fromId == ChatDetails.currentUserId)
        ? _blueCard()
        : _greenCard();
  }

  // user's message card
  Widget _blueCard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: widget.size.shortestSide * 0.02),
          child: Row(
            children: [
              SizedBox(width: widget.size.shortestSide * 0.02),

              // message status icon
              if(widget.message.read.isEmpty) Icon(Icons.done, color: Colors.grey)
              else Icon(Icons.done_all, color: Colors.blue.shade500),

              // sent time
              Text(
                ChatDetails.formatTime(context: context, time: widget.message.sent),
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),

        // messageCard
        Flexible(
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: widget.size.shortestSide * 0.03,
                vertical: widget.size.shortestSide * 0.02
            ),
            margin: EdgeInsets.symmetric(
                horizontal: widget.size.shortestSide * 0.025,
                vertical: widget.size.shortestSide * 0.01
            ),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              border: Border.all(
                color: Colors.blue.shade300,
                width: 2
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
            child: Text(
              widget.message.msg,
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  // other's message card
  Widget _greenCard() {
    // update read status
    if(widget.message.read.isEmpty){
      ChatDetails.updateMessageStatus(widget.message);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // messageCard
        Flexible(
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: widget.size.shortestSide * 0.03,
                vertical: widget.size.shortestSide * 0.02
            ),
            margin: EdgeInsets.symmetric(
                horizontal: widget.size.shortestSide * 0.025,
                vertical: widget.size.shortestSide * 0.01
            ),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              border: Border.all(
                  color: Colors.green.shade500,
                  width: 2
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Text(
              widget.message.msg,
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ),

        // msg sent time
        Padding(
          padding: EdgeInsets.symmetric(vertical: widget.size.shortestSide * 0.02),
          child: Row(
            children: [
              Text(
                ChatDetails.formatTime(context: context, time: widget.message.sent),
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),

              SizedBox(width: widget.size.shortestSide * 0.02),
            ],
          ),
        ),
      ],
    );
  }
}
