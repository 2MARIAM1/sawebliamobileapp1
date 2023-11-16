import 'package:flutter/material.dart';

class CustomAppbar extends StatefulWidget {
  final String title;

  const CustomAppbar({Key? key, required this.title}) : super(key: key);

  @override
  State<CustomAppbar> createState() => _CustomAppbarState();
}

class _CustomAppbarState extends State<CustomAppbar> {
  // void _showNewMissionDialog(int missionId) {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (_) => NewMissionDialog(missionId: missionId),
  //       fullscreenDialog: true,
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 30),
      width: double.infinity,
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              // Open the sidebar menu
              Scaffold.of(context).openDrawer();
            },
            icon: const Icon(Icons.menu),
            color: Colors.black,
          ),

          Text(
            widget.title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          // GestureDetector(
          //   onTap: () {
          //     showDialog(
          //       context: context,
          //       builder: (BuildContext context) {
          //         return AlertDialog(
          //           title: const Text('Notifications'),
          //           content: Column(
          //             children: [
          // Expanded(
          //   child: Consumer<NotificationProvider>(
          //     builder: (context, notificationModel, _) {
          //       final notifications =
          //           notificationModel.notifications;
          //       return ListView.builder(
          //         itemCount: notifications.length,
          //         itemBuilder: (context, index) {
          //           return ListTile(
          //             title: Text(notifications[index].title),
          //             subtitle: Text(notifications[index].body),
          //             onTap: () {
          //               // Handle notification item tap here
          //               _showNewMissionDialog(
          //                   notifications[index].missionId!);
          //             },
          //           );
          //         },
          //       );
          //     },
          //   ),
          // ),
          //   ],
          // ),
          // actions: [
          //   TextButton(
          //     onPressed: () {
          //       Navigator.of(context).pop();
          //     },
          //     child: const Text('Close'),
          //   ),
          // ],
          // );
          //  },
          //);
          // },
          //   child: Container(
          //     decoration: BoxDecoration(
          //       color: MyColors.darkblue1.withOpacity(0.3),
          //       borderRadius: BorderRadius.circular(7.0),
          //     ),
          //     height: 27,
          //     width: 27,
          //     child: SvgPicture.asset(
          //       Provider.of<NotificationProvider>(context).newNotification
          //           ? 'assets/images/NotificationReceived.svg'
          //           : 'assets/images/NotificationOut.svg',
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
