import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../modules/socketio.dart';
import '../widgets/dashboard_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  num? temperature;
  num? humidity;
  num? waterLevel;
  num? dust;

  bool? securityMode;
  bool? windowOpen;
  bool? fanOn;
  bool? lightOn;

  bool isProcessingOpenClosed = false;

  void onSensorMeasurementsUpdated(dynamic data) {
    setState(() {
      temperature = data['temperature'];
      humidity = data['humidity'];
      waterLevel = data['waterLevel'];
      dust = data['dust'];
    });
  }

  void onActionUpdated(dynamic data) {
    print(data);
    setState(() {
      securityMode = data['securityMode'] ?? securityMode;
      windowOpen = data['windowOpen'] ?? windowOpen;
      fanOn = data['fanOn'] ?? fanOn;
      lightOn = data['lightOn'] ?? lightOn;
    });
  }

  void forceRebuild() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    SocketApi.socket.on(
      'sensorMeasurementsUpdated',
      onSensorMeasurementsUpdated,
    );
    SocketApi.socket.on(
      'actionUpdated',
      onActionUpdated,
    );
    SocketApi.socket.onConnect((_) => forceRebuild());
    SocketApi.socket.onReconnect((_) => forceRebuild());
    SocketApi.socket.onError((_) => forceRebuild());

    SocketApi.socket.emitWithAck('getSensorMeasurements', null, ack: (data) {
      setState(() {
        temperature = data['temperature'];
        humidity = data['humidity'];
        waterLevel = data['waterLevel'];
        dust = data['dust'];
      });
    });

    SocketApi.socket.emitWithAck('getAction', null, ack: (data) {
      setState(() {
        securityMode = data['securityMode'];
        windowOpen = data['windowOpen'];
        fanOn = data['fanOn'];
        lightOn = data['lightOn'];
      });
    });
  }

  @override
  void dispose() {
    super.dispose();

    SocketApi.socket.off(
      'sensorMeasurementsUpdated',
      onSensorMeasurementsUpdated,
    );
    SocketApi.socket.off(
      'actionUpdated',
      onActionUpdated,
    );
    SocketApi.socket.offAny((event, data) {
      forceRebuild();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final baseButtonStyle = ElevatedButton.styleFrom(
      iconSize: 30,
      elevation: 5,
      shadowColor: Colors.grey.withValues(alpha: .2),
      textStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
      padding: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
    );

    final activeButtonStyle = baseButtonStyle.merge(
      ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        iconColor: Colors.white,
      ),
    );

    final inactiveButtonStyle = baseButtonStyle.merge(
      ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Theme.of(context).colorScheme.primary,
        iconColor: Theme.of(context).colorScheme.primary,
      ),
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
        decelerationRate: ScrollDecelerationRate.fast,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                childAspectRatio: 1,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      SocketApi.socket.emitWithAck(
                        'updateAction',
                        {
                          'securityMode': !(securityMode ?? false),
                        },
                      );
                    },
                    style: securityMode == true
                        ? activeButtonStyle
                        : inactiveButtonStyle,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Icon(Icons.shield), Text("경비모드")],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      SocketApi.socket.emitWithAck(
                        'updateAction',
                        {
                          'windowOpen': !(windowOpen ?? false),
                        },
                      );
                    },
                    style: windowOpen == true
                        ? activeButtonStyle
                        : inactiveButtonStyle,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Icon(Icons.window), Text("창문")],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      SocketApi.socket.emitWithAck(
                        'updateAction',
                        {
                          'fanOn': !(fanOn ?? false),
                        },
                      );
                    },
                    style:
                        fanOn == true ? activeButtonStyle : inactiveButtonStyle,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Icon(Icons.air), Text("선풍기")],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      SocketApi.socket.emitWithAck(
                        'updateAction',
                        {
                          'lightOn': !(lightOn ?? false),
                        },
                      );
                    },
                    style: lightOn == true
                        ? activeButtonStyle
                        : inactiveButtonStyle,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Icon(Icons.lightbulb), Text("전등")],
                    ),
                  )
                ].toList()),
            const SizedBox(height: 16),
            DashboardCard(
              title: '센서 정보',
              child: Column(
                children: [
                  Card(
                    elevation: 0,
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.white, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '기온',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                          Text(
                            temperature != null ? temperature.toString() : '-',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Text(
                            '℃',
                            style: TextStyle(fontSize: 12),
                          )
                        ],
                      ),
                      tileColor: const Color.fromRGBO(242, 244, 245, 1),
                      onTap: () {},
                      leading: const Icon(Icons.thermostat),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      horizontalTitleGap: 8,
                      dense: true,
                    ),
                  ),
                  Card(
                    elevation: 0,
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.white, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '습도',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                          Text(
                            humidity != null ? humidity.toString() : '-',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Text(
                            '%',
                            style: TextStyle(fontSize: 12),
                          )
                        ],
                      ),
                      tileColor: const Color.fromRGBO(242, 244, 245, 1),
                      onTap: () {},
                      leading: const Icon(Icons.cloud),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      horizontalTitleGap: 8,
                      dense: true,
                    ),
                  ),
                  Card(
                    elevation: 0,
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.white, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '강우',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                          Text(
                            '비 내리지 않음',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      tileColor: const Color.fromRGBO(242, 244, 245, 1),
                      onTap: () {},
                      leading: const Icon(Icons.water_drop),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      horizontalTitleGap: 8,
                      dense: true,
                    ),
                  ),
                  Card(
                    elevation: 0,
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.white, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '미세먼지',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                          Text(
                            dust != null ? dust.toString() : '-',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Text(
                            ' ppm',
                            style: TextStyle(fontSize: 12),
                          )
                        ],
                      ),
                      tileColor: const Color.fromRGBO(242, 244, 245, 1),
                      onTap: () {},
                      leading: const Icon(Icons.blur_on),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      horizontalTitleGap: 8,
                      dense: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DashboardCard(
              title: '시스템 커넥션 상태',
              child: Column(
                children: [
                  Card(
                    elevation: 0,
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.white, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Row(
                        children: [
                          const Text(
                            '센싱 하드웨어 연결',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.5),
                          ),
                          const Expanded(child: SizedBox()),
                          Text(
                            SocketApi.socket.connected ? '정상' : '연결 끊김',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: SocketApi.socket.connected
                                  ? Colors.deepPurple
                                  : Colors.pink,
                            ),
                          ),
                        ],
                      ),
                      tileColor: const Color.fromRGBO(242, 244, 245, 1),
                      onTap: () {},
                      leading: const Icon(Icons.wifi),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      horizontalTitleGap: 8,
                      dense: true,
                    ),
                  ),
                  Card(
                    elevation: 0,
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.white, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Row(
                        children: [
                          const Text(
                            '백엔드 서버 소켓 연결',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.5),
                          ),
                          const Expanded(child: SizedBox()),
                          Text(
                            SocketApi.socket.connected ? '연결됨' : '연결 끊김',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: SocketApi.socket.connected
                                  ? Colors.deepPurple
                                  : Colors.pink,
                            ),
                          ),
                        ],
                      ),
                      subtitle: SocketApi.socket.connected
                          ? null
                          : const Text('재연결 시도 중...'),
                      tileColor: const Color.fromRGBO(242, 244, 245, 1),
                      onTap: () {},
                      leading: Icon(
                        SocketApi.socket.connected
                            ? Icons.wifi
                            : Icons.wifi_off,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      horizontalTitleGap: 8,
                      dense: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
