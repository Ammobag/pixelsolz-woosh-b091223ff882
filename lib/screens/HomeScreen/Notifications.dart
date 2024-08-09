import 'package:flutter/material.dart' hide Notification;
import 'package:intl/intl.dart';
import 'package:whoosh/core/BaseScreen.dart';
import 'package:whoosh/core/entities/Notification.dart';
import 'package:whoosh/core/widgets/CardX.dart';
import 'package:whoosh/core/widgets/TextX.dart';

class Notifications extends BasePage {
  final List<Notification> notifications;

  const Notifications({Key? key, required this.notifications})
      : super(key: key);

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends BaseState<Notifications> with MasterPage {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextX.heading("Notifications"),
        SizedBox(height: MediaQuery.of(context).size.height * 0.0123),
        Expanded(
          child: ListView.separated(
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return CardX.getNotificationCard(
                    DateFormat("MMM dd, yyyy  hh:mma")
                        .format(widget.notifications[index].time!),
                    widget.notifications[index].message!);
              },
              separatorBuilder: (context, index) {
                return SizedBox(
                  height: 10,
                );
              },
              itemCount: widget.notifications.length),
        )
      ],
    );
  }
}
