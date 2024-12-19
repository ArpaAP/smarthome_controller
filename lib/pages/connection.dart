// import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

import '../modules/socketio.dart';

class ConnectionPage extends StatefulWidget {
  const ConnectionPage({super.key});

  @override
  State<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage>
    with AutomaticKeepAliveClientMixin<ConnectionPage> {
  // final remoteConfig = FirebaseRemoteConfig.instance;
  List<dynamic> messages = [];

  void onAny(String event, dynamic data) {
    setState(() {
      messages.add((event, data));
    });
  }

  @override
  void initState() {
    super.initState();

    SocketApi.socket.onAny(onAny);
  }

  @override
  void dispose() {
    super.dispose();

    SocketApi.socket.offAny(onAny);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(messages[index].$1),
              subtitle: Text(messages[index].$2.toString()),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
