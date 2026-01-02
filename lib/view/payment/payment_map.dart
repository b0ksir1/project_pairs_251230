import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:project_pairs_251230/model/store.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:geolocator/geolocator.dart';
// StoreModel 정의 파일 import 경로를 확인하세요. (OrderScreen과 동일 폴더에 있다고 가정)
// import 'order.dart';

class PaymentMap extends StatefulWidget {
  const PaymentMap({super.key});

  @override
  State<PaymentMap> createState() => _PaymentMapState();
}

class _PaymentMapState extends State<PaymentMap> {
  // Property
  var value = Get.arguments ?? "__"; // 0. 매장 데이터 , 1. 고객 위치 , 2. 선택한 매장
  late List<Store> storeData;         // 매장데이터
  late latlng.LatLng customer_pos;    // 내 위치
  late MapController mapController;   // 지도

  // 현재 선택된 매장 (초기에는 null)
  Store? _selectedStore;

  @override
  void initState() {
    super.initState();
    storeData = value[0];
    customer_pos = value[1];
    _selectedStore = value[2];
    mapController = MapController();
    calculateStoreDistances(customer_pos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // 1. 지도 뷰 (더미 이미지 또는 실제 지도 위젯 대체)
          _buildMapView(),

          // 2. 매장 목록
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                const SizedBox(height: 20),
                const Text(
                  "모든 픽업 매장",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...storeData
                    .map((store) => _buildStoreListTile(store))
                    .toList(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 앱바 (닫기 버튼 포함)
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Get.back(result: _selectedStore),
        icon: Icon(Icons.arrow_back),
      ),
      title: const Text(
        "매장 찾기",
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.black), // 닫기(X) 버튼
          onPressed: () => Get.back(result: _selectedStore), // 화면 닫기
        ),
      ],
    );
  }

  // 지도 더미 뷰
  Widget _buildMapView() {
    return Container(
      height: 250,
      width: double.infinity,
      color: Colors.grey.shade200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 실제 지도 SDK (Google Maps, Naver Map 등)가 들어갈 공간
          flutterMap(),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // const Icon(Icons.map, size: 50, color: Colors.grey),
                // const SizedBox(height: 10),
                // // Text(
                // //   "실시간 지도 뷰 (현재 사용자 위치 기준)",
                // //   style: TextStyle(color: Colors.grey.shade600),
                // // ),
              ],
            ),
          ),
          // 현재 위치 표시 및 가까운 매장 정보 오버레이 (옵션)
          Positioned(
            bottom: 10,
            right: 10,
            child: FloatingActionButton.extended(
              onPressed: () async {
                Get.snackbar("알림", "현재 위치를 중심으로 매장을 검색합니다.");
                try {
                  if (_selectedStore == null) {
                    Get.snackbar("알림", "픽업 매장을 먼저 선택해주세요.");
                    return;
                  }
                  final myPos = await _getMyLocation();
                  customer_pos = myPos;
                  setState(() {});

                  calculateStoreDistances(customer_pos);
                  setState(() {});

                  _fitToMyAndStore(myPos, _selectedStore!);
                } catch (e) {
                  Get.snackbar("에러", e.toString());
                }
              },
              label: const Text("내 위치 보기"),
              icon: const Icon(Icons.my_location),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // 매장 목록 타일
  Widget _buildStoreListTile(Store store) {
    final isSelected = store.store_id == _selectedStore?.store_id;

    return InkWell(
      onTap: () {
        _selectedStore = store;
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Colors.black : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.store_name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    store.store_phone,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "${store.km_distance!.toStringAsFixed(1)}km",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  } // build

  //--------------------------------functions---------------------------------------

  Future<latlng.LatLng> _getMyLocation() async {
    // 위치 서비스
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("위치 서비스가 꺼져있음");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception("위치 권한 영구 거절");
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return latlng.LatLng(pos.latitude, pos.longitude);
  }

  void _fitToMyAndStore(latlng.LatLng myPos, Store store) {
    final storePos = latlng.LatLng(store.store_lat, store.store_lng);
    final bounds = LatLngBounds.fromPoints([myPos, storePos]);

    mapController.fitCamera(
      // 카메라를 고객위치랑 매장위치 사이 고정
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(60), // 화면 여백
      ),
    );
  }

  void calculateStoreDistances(latlng.LatLng userPos) {
    // meter -> km
    final distanceCalc = latlng.Distance();
    for (final store in storeData) {
      final meters = distanceCalc(
        userPos,
        latlng.LatLng(store.store_lat, store.store_lng),
      );

      store.km_distance = meters / 1000; // km
    }
  }

  flutterMap() {
    // 지도맵
    double initlat = 37.57;
    double initlng = 126.97;
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        // 초기위치 설정
        initialCenter: latlng.LatLng(initlat, initlng),
        initialZoom: 17.0,
      ),
      children: [
        TileLayer(
          // 이게 전버전
          // 지도 타일을 가져올 URL을 직접 지정
          // OpenStreetMap 서버에 직접 요청
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          // 이게 최신버전
          // 더 이상 urlTemplate 기본 제공 X
          // 기본 OpenStreetMap tile을 자동 설정
          // userAgentPackageName을 안적으면 OSM 서버에서 요청을 차단
          // 약간 카카오맵의 API키 제공받을때하는짓
          userAgentPackageName: "com.tj.gpsmapapp",
        ),
        MarkerLayer(
          markers: [
            //내 위치 마커
            Marker(
              point: customer_pos,
              width: 80,
              height: 70,
              child: Column(
                children: [
                  const Text(
                    '내 위치',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Icon(Icons.my_location, color: Colors.blue, size: 30),
                ],
              ),
            ),

            //선택된 매장 마커
            if (_selectedStore != null)
              Marker(
                point: latlng.LatLng(
                  _selectedStore!.store_lat,
                  _selectedStore!.store_lng,
                ),
                width: 80,
                height: 70,
                child: Column(
                  children: [
                     Text(
                    '${_selectedStore!.store_name}매장',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                    const Icon(Icons.location_pin, color: Colors.red, size: 40),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
} // class
