import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  ChatMessage(this.data, this.mine);

  final Map<String, dynamic> data;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 8.0,
      ),
      child: Row(
        children: [
          !mine
              ? Padding(
                  padding: EdgeInsets.only(
                    right: 8.0,
                  ),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(data["senderPhotoUrl"]),
                  ),
                )
              : Container(),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                data['imageUrl'] != null
                    ? Image.network(
                        data['imageUrl'],
                        width: 250.0,
                      )
                    : Text(
                        data['text'],
                        textAlign: mine ? TextAlign.end : TextAlign.start,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                Text(
                  data["senderName"],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          mine
              ? Padding(
                  padding: EdgeInsets.only(
                  left: 8.0,
                  ),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(data["senderPhotoUrl"]),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
