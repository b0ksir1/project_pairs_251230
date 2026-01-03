import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_pairs_251230/model/product.dart';
import 'package:project_pairs_251230/model/product_detail_item.dart';
import 'package:project_pairs_251230/util/global_data.dart';
import 'package:http/http.dart' as http;

class ProductDetail extends StatefulWidget {
  const ProductDetail({super.key});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
 // GetX: CartController 인스턴스화 및 주입
  late final PageController _pageController;
  // 상태 관리 변수들
  int _currentImageIndex = 0;
  int _selectedColorIndex = 0;
  bool _isLiked = false; // wish controller



  Product? _product;



  List<ProductDetailItem> _productList = [];
  late List<int> _productImages = [];
  List<ProductDetailItem> _productColorItemList = [];
  Set _productSize = {};
  Set _productSizeName = {};
  Set _productColor = {};
  Set _productColorName = {};



  
  
  // A1: 선택 가능한 사이즈 목록 (220부터 290까지 5단위)
  // final List<String> _availableSizes = [
  //   for (int size = 220; size <= 300; size += 5) size.toString(),
  // ];
  // A1: 현재 선택된 사이즈
  String? _selectedSize;

  // Property
  late List<Product> list; // 상품1개정보

  int product_id = Get.arguments ?? 1;

  // 더미 데이터: 이미지 리스트 (넘겨받은 imageUrl을 첫 번째 이미지로 사용하도록 변경)
  // 실제 제품의 여러 이미지를 구현하려면 이 리스트를 DetailScreen의 인자로 받아야 하지만,
  // 현재는 넘겨받은 imageUrl을 포함하고 기존 더미를 유지합니다.

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // 넘겨받은 imageUrl을 첫 번째 이미지로 설정 (다른 색상 더미는 유지)


    // +++ 상품 DB 연결
    getProductData(product_id);
    getProductImages(product_id);
    // +++ 위시리스트 연결
    // _loadWishState();
  }

  // +++ 상품 DB 연결
  

  Future getProductImages(int id) async{
     var url = Uri.parse(
      '${GlobalData.url}/images/select/$id',
    );
    var response = await http.get(url);

    // print(response.body);
    // print('getProductData : ${response.body} / $url');

    if (response.statusCode == 200) {
      var dataConvertedData = json.decode(utf8.decode(response.bodyBytes));
      var results = dataConvertedData['results'];
      _productImages.clear();
      for(var item in results)
      {
        _productImages.add(item['images_id']);
      }

      setState(() {});
    } else {
      print("error : ${response.statusCode}");
    }
  }


  // +++ 위시리스트 등록
  // void _loadWishState() async {
  //   final liked = await wishHandler.exists(
  //     GlobalLoginData.customer_id,
  //     product_id,
  //   );

  //   if (!mounted) return;

  //   setState(() {
  //     _isLiked = liked;
  //   });
  // }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: _product == null
            ? Center(child: const CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. 이미지 캐러셀
                  _buildImageCarousel(),

                  // 2. 색상 선택 썸네일
                  _buildColorSelector(),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 3. 상품 정보 (타이틀, 가격)
                        const SizedBox(height: 20),
                        Text(
                          _product!
                              .product_name, //widget.title, // 넘겨받은 title 사용
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Text(
                        //   '${product!.gender} 신발', //widget.subtitle, // 넘겨받은 subtitle 사용
                        //   style: const TextStyle(
                        //     fontSize: 14,
                        //     color: Colors.grey,
                        //   ),
                        // ),
                        const SizedBox(height: 16),
                        Text(
                          '₩${_product!.product_price.toString()}', //widget.price, // 넘겨받은 price 사용
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),

                        // 4. 사이즈 선택 버튼
                        const SizedBox(height: 30),
                        _buildSizeSelector(),

                        // 5. 메인 액션 버튼들 (장바구니, 구매, 위시)
                        const SizedBox(height: 20),
                        _buildActionButtons(),

                        // 6. 안내 박스
                        const SizedBox(height: 30),
                        _buildInfoBox(),

                        // 제품 설명 추가 (description 활용)
                        const SizedBox(height: 20),
                        Text(
                          "제품 설명",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _product!
                              .product_description!, //widget.description, // 넘겨받은 description 사용
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                        const Divider(
                          height: 60,
                          thickness: 1,
                          color: Color(0xFFEEEEEE),
                        ),

                        // 7. 함께 본 상품
                        const Text(
                          "함께 본 상품",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildRecommendations(),

                        const Divider(
                          height: 60,
                          thickness: 1,
                          color: Color(0xFFEEEEEE),
                        ),

                        // 8. 리뷰 섹션
                        // _buildReviewSection(),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }


  // === Functions ===

  Future getProductData(int id) async {
    var url = Uri.parse(
      '${GlobalData.url}/product/selectById/$id',
    );
    var response = await http.get(url);

    // print('getProductData : ${response.body} / $url');

    if (response.statusCode == 200) {
      var dataConvertedData = json.decode(utf8.decode(response.bodyBytes));
      var results = dataConvertedData['results'];
      print(results);
      _product = Product.fromJson(results.first);
      
      getProductDataList(_product!.product_name);
      setState(() {});
    } else {
      print("error : ${response.statusCode}");
    }
  }

  Future getProductDataList(String name) async{
    var url = Uri.parse(
      '${GlobalData.url}/product/selectByName/$name',
    );
    var response = await http.get(url);

    print('getProductData : ${response.body} / $url');

    if (response.statusCode == 200) {
      _productList.clear();
      var dataConvertedData = json.decode(utf8.decode(response.bodyBytes));
      List results = dataConvertedData['results'];
      print(results);
      for(var item in results)
      {
          ProductDetailItem product = ProductDetailItem(
            productId: item['product_id'],
            colorId: item['product_color_id'],
            colorName: item['color_name'],
            brandId: item['product_brand_id'],
            categoryId: item['product_category_id'],
            sizeId: item['product_size_id'],
            sizeName: item['size_name'],
            price: item['product_price'],
            productDescription: item['product_description'],
            qty: item['stock_quantity'],
          );

          _productList.add(product);
          // _productSize.add(product.sizeId);
          _productColor.add(product.colorId);

          // bool possible = true;
          // for(var i in _productColorItemList)
          // {
          //   if(i.colorId == product.colorId)
          //   {
          //     possible = false;
          //     break;
          //   }
          // }
          // if(possible) 
          // {
          //   _productColorItemList.add(product);
          // }
      }

      setState(() {});
    } else {
      print("error : ${response.statusCode}");
    }
  }

  void classify()
  { 
    
  }

  // === Widget ===
  // 앱바
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        _product != null ? _product!.product_name : '...', // 넘겨받은 title 사용
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined, color: Colors.black),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: () {},
        ),
      ],
    );
  }
  // 이미지 슬라이더
  Widget _buildImageCarousel() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        AspectRatio(
          aspectRatio: 1.1, // 정사각형에 가깝게
          child: PageView.builder(
            itemCount: _productImages.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
                
              });
            },
            itemBuilder: (context, index) {
              return Container(
                color: const Color(0xFFF5F5F5), // 연한 회색 배경
                child: Image.network(
                  '${GlobalData.url}/images/view/${_productImages[_currentImageIndex]}',
                  fit: BoxFit.cover, // 사진 꽉 채우기 or contain
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_productImages.length, (index) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentImageIndex == index
                      ? Colors.black
                      : Colors.grey.withOpacity(0.5),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // 색상 선택 리스트
  Widget _buildColorSelector() {
    // print("${GlobalData.url}/images/view/${_productColorItemList[_selectedColorIndex].productId}" );
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_productColor.length, (index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedColorIndex = index;

                // 실제 앱에선 여기서 Carousel 페이지도 이동시킬 수 있음
              });
            },
            child: Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _selectedColorIndex == index
                      ? Colors.black
                      : Colors.transparent,
                  width: 2,
                ),
                
                image: DecorationImage(
                  image: NetworkImage('${GlobalData.url}/images/view/${_productImages[index]}',),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // 사이즈 선택 버튼 (A1: 가로 스크롤 선택 버튼)
  Widget _buildSizeSelector() {
    int selectedQty() {
      // size check
      if (_selectedSize == null) {
        return 0;
      }
      final s = int.tryParse(_selectedSize!) ?? 0;


      // sizeStockCheck = sizeStock[s] ?? 0;
      // return sizeStock[s] ?? 0; // 없는 사이즈면 0

      return 0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            _selectedSize == null
                ? "사이즈를 선택해주세요"
                : "선택된 사이즈: ${_selectedSize!} | 재고: ${selectedQty()}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 50,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _productSize.map((size) {
                final isSelected = _selectedSize == size;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSize = isSelected ? null : size;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      size,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  } // build

  // 장바구니/구매/위시 버튼
  Widget _buildActionButtons() {
    return Column(
      children: [
        // 장바구니 (검정)
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () async {
              if (_selectedSize == null) {
                Get.snackbar(
                  "경고",
                  "사이즈를 선택해주세요",
                  snackPosition: SnackPosition.TOP,
                );
                return;
              }
              final selectedSizeInt = int.tryParse(_selectedSize!) ?? 0;
              // final stock = sizeStock[selectedSizeInt] ?? 0;
                final stock = 0;

              if (stock <= 0) {
                Get.snackbar(
                  "경고",
                  "품절된 사이즈입니다",
                  snackPosition: SnackPosition.TOP,
                );
                return;
              }
              // +++ 상품 DB 연동 핸들러
              // final variantId = await productHandler.findVariantProductId(
              //   productName: product!.product_name,
              //   productColor: product!.product_color,
              //   productSize: selectedSizeInt,
              // );

              // if (variantId == null) {
              //   Get.snackbar(
              //     "오류",
              //     "해당 사이즈 상품을 찾을 수 없습니다",
              //     snackPosition: SnackPosition.TOP,
              //   );
              //   return;
              // }

              // await cartController.addToCart(
              //   productId: variantId,
              //   title: product!.product_name,
              //   price: product!.product_price,
              //   image: product!.mainImageUrl ?? "",
              //   size: _selectedSize!,
              // );

              // +++ 장바구니 연결
              // Get.to(ShoppingCartView());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: const Text(
              "장바구니",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // 구매하기 & 위시리스트
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: () async {
                    if (_selectedSize == null) {
                      Get.snackbar(
                        "경고",
                        "사이즈를 선택해주세요",
                        snackPosition: SnackPosition.TOP,
                      );
                      return;
                    }
                    final selectedSizeInt = int.tryParse(_selectedSize!) ?? 0;
                    // final stock = sizeStock[selectedSizeInt] ?? 0;
                    final stock = 0;
                    if (stock <= 0) {
                      Get.snackbar(
                        "경고",
                        "품절된 사이즈입니다",
                        snackPosition: SnackPosition.TOP,
                      );
                      return;
                    }

                    // +++ 상품, 주문 DB 연동
                    // final variantId = await productHandler.findVariantProductId(
                    //   productName: product!.product_name,
                    //   productColor: product!.product_color,
                    //   productSize: selectedSizeInt,
                    // );

                    // if (variantId == null) {
                    //   Get.snackbar(
                    //     "오류",
                    //     "해당 사이즈 상품을 찾을 수 없습니다",
                    //     snackPosition: SnackPosition.TOP,
                    //   );
                    //   return;
                    // }
                    // Get.to(
                    //   OrderView(),
                    //   arguments: [
                    //     Order(
                    //       customer_id: GlobalLoginData.customer_id,
                    //       product_id: variantId,
                    //       order_store_id: 0,
                    //       product_name: product!.product_name,
                    //       order_quantity: 1,
                    //       order_total_price: product!.product_price,
                    //       order_status: '요청',
                    //       product_mainImageUrl: product!.mainImageUrl,
                    //       created_at: DateTime.now(),
                    //     ),
                    //   ],
                    // );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "구매하기",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 56, // 위시리스트 버튼은 동그랗거나 작게
              height: 56, // 높이 맞춤
              child: OutlinedButton(
                onPressed: () async {
                  
                  // +++ 위시 리스트 연동
                  // if (_isLiked) {
                  //   await wishHandler.deleteWish(
                  //     GlobalLoginData.customer_id,
                  //     product_id,
                  //   );
                  // } else {
                  //   await wishHandler.insert(
                  //     Wish(
                  //       customer_id: GlobalLoginData.customer_id,
                  //       product_id: product_id,
                  //       created_at: DateTime.now(),
                  //     ),
                  //   );
                  // }
                  // setState(() {
                  //   _isLiked = !_isLiked;
                  // });
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ), // 원형에 가깝게
                ),
                child: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? Colors.red : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 안내 박스
  Widget _buildInfoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "무료 반품 안내",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "제품 수령일로부터 14일 동안 제공되는 무료 반품 서비스를 만나보세요.",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "자세히 보기",
            style: TextStyle(
              fontSize: 13,
              color: Colors.black,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  // 추천 상품 가로 스크롤
  Widget _buildRecommendations() {
    final List<Map<String, String>> recItems = [
      {
        "name": "리액트 인피니티 런",
        "price": "₩149,000",
        "img":
            "https://lh3.googleusercontent.com/aida-public/AB6AXuDDt5iFoapJl0uzAcARC3gJPbzvQs0B0DGYyikn9yhKPgDeNRWgFMpXnUr543Jf4vgND33BjX-omWHAi_KpAfShPPreEqkR-yCUnKJky7U2aAQmce0EwmhHCpdCcoe97sMNXf47C-paUuhwWsWrvESOpXxkCknBejgTx2jGR5dPFZV9By4ISUZVn3ztQtLeovreJkxKQgA-_ejVKAy8CBbnG6yRp_dqSedQE7Ye-Mjk7jWUv2utjph7EKzhqKXkuJRpZia9Qa2XD1w",
      },
      {
        "name": "에어 조던 1",
        "price": "₩179,000",
        "img":
            "https://lh3.googleusercontent.com/aida-public/AB6AXuAWT5XtZPPiASQ8v75AKCbnfIgfTjhgk5Dj_gZr9bzaJQKrKplCfMVmgOgJtbWv4j-r7MrvNRUHqIPXGKxCvdfeAcW-08p1c3rOzAnacZFQ6f9b12Tv2f6p2rVGF3zee4uGNrau6nuOEuMEdeqMnPdhDFXGGkJu5qZhCiV4v2WnB1nLp_8rkPfnBewikUnse8MFk4Uo06qfh8-sq_Rvly7PPKRpL3vB5wu4dwzd_aVDZANNvo0slxuaHN9brDT6P0XM01CiHxmTgaU",
      },
      {
        "name": "블레이저 미드",
        "price": "₩119,000",
        "img":
            "https://kream-phinf.pstatic.net/MjAyMDEwMjJfOTAg/MDAxNjAzMzMzOTUxMDA1.bOJymr5uzMrQ2Cj_Aqrt1NaMCavrz2I1qnovubaoGxYg.rzuR3QeGruP4Zppwd2_mlcFH5qMVEXarZ1FEkXFE--Ag.PNG/p_19795_0_222cc7bf0acb485ab5d2f2bf47fbee2c.png?type=l_webp",
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: recItems.map((item) {
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(item['img']!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['name']!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  item['price']!,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // +++ 리뷰. 날릴 예정
  // 리뷰 섹션
  // Widget _buildReviewSection() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       // 평점 헤더
  //       Row(
  //         crossAxisAlignment: CrossAxisAlignment.end,
  //         children: [
  //           Text(
  //             (rateReport['rateTotalPoint'] / rateReport['totalCount'])
  //                 .toString(),
  //             style: TextStyle(
  //               fontSize: 48,
  //               fontWeight: FontWeight.bold,
  //               height: 1.0,
  //             ),
  //           ),
  //           const SizedBox(width: 8),
  //           Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Row(
  //                 children: List.generate(5, (index) {
  //                   return Icon(
  //                     index <
  //                             (rateReport['rateTotalPoint'] /
  //                                 rateReport['totalCount'])
  //                         ? Icons.star
  //                         : Icons.star_border,
  //                     size: 16,
  //                     color: Colors.black,
  //                   );
  //                 }),
  //                 //List.generate(5, (index) => const Icon(Icons.star, size: 18, color: Colors.black)),
  //               ),
  //               const SizedBox(height: 4),
  //               Text(
  //                 "${rateReport['totalCount']} reviews",
  //                 style: TextStyle(color: Colors.grey, fontSize: 12),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //       const SizedBox(height: 20),
  //       // 평점 그래프 (간소화)
  //       Column(
  //         children: List.generate(
  //           rateReport['rates'].length,
  //           (index) => _buildRatingBar(
  //             rateReport['rates'][index]['review_rating'],
  //             0.5,
  //           ),
  //         ),
  //       ),

  //       _buildRatingBar(5, 0.5),
  //       _buildRatingBar(4, 0.3),
  //       _buildRatingBar(3, 0.1),
  //       _buildRatingBar(2, 0.05),
  //       _buildRatingBar(1, 0.05),
  //       const SizedBox(height: 30),
  //       Text(
  //         "리뷰 (${rateReport['totalCount']})",
  //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //       ),
  //       const SizedBox(height: 16),

  //       // 개별 리뷰 아이템
  //       Column(children: _buildReview()),
  //       _buildReviewItem(
  //         "지우",
  //         "2023년 10월 26일",
  //         5,
  //         "정말 편하고 디자인도 예뻐요! 매일 신고 다닙니다.",
  //       ),
  //       _buildReviewItem(
  //         "민준",
  //         "2023년 10월 20일",
  //         4,
  //         "사이즈가 조금 크게 나온 것 같아요. 그래도 만족합니다.",
  //       ),
  //     ],
  //   );
  // }

  Widget _buildRatingBar(int star, double pct) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(
            width: 12,
            child: Text(
              "$star",
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.grey.shade200,
              color: Colors.black,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 30,
            child: Text(
              "${(pct * 100).toInt()}%",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  // +++ 리뷰. 날릴 예정
  // List<Widget> _buildReview() {
  //   return reviewList
  //       .map(
  //         (data) => Padding(
  //           padding: const EdgeInsets.only(bottom: 24.0),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Row(
  //                 children: [
  //                   const CircleAvatar(
  //                     radius: 16,
  //                     backgroundColor: Color(0xFFEEEEEE),
  //                     child: Icon(Icons.person, color: Colors.grey, size: 20),
  //                   ),
  //                   const SizedBox(width: 10),
  //                   Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         data.customer_name!,
  //                         style: const TextStyle(
  //                           fontWeight: FontWeight.bold,
  //                           fontSize: 14,
  //                         ),
  //                       ),
  //                       Text(
  //                         data.created_at.toString(),
  //                         style: const TextStyle(
  //                           color: Colors.grey,
  //                           fontSize: 12,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //               const SizedBox(height: 8),
  //               Row(
  //                 children: List.generate(5, (index) {
  //                   return Icon(
  //                     index < data.review_rating
  //                         ? Icons.star
  //                         : Icons.star_border,
  //                     size: 16,
  //                     color: Colors.black,
  //                   );
  //                 }),
  //               ),
  //               const SizedBox(height: 8),
  //               Text(
  //                 data.review_content!,
  //                 style: const TextStyle(fontSize: 14, height: 1.4),
  //               ),
  //               const SizedBox(height: 10),
  //               Row(
  //                 children: [
  //                   const Icon(
  //                     Icons.thumb_up_alt_outlined,
  //                     size: 16,
  //                     color: Colors.grey,
  //                   ),
  //                   const SizedBox(width: 4),
  //                   Text(
  //                     "${(data.review_rating * 2) + 3}",
  //                     style: const TextStyle(fontSize: 12, color: Colors.grey),
  //                   ), // 더미 숫자
  //                   const SizedBox(width: 16),
  //                   const Icon(
  //                     Icons.thumb_down_alt_outlined,
  //                     size: 16,
  //                     color: Colors.grey,
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       )
  //       .toList();

    // return [Padding(
    //   padding: const EdgeInsets.only(bottom: 24.0),
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Row(
    //         children: [
    //           const CircleAvatar(
    //             radius: 16,
    //             backgroundColor: Color(0xFFEEEEEE),
    //             child: Icon(Icons.person, color: Colors.grey, size: 20),
    //           ),
    //           const SizedBox(width: 10),
    //           Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    //               Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
    //             ],
    //           ),
    //         ],
    //       ),
    //       const SizedBox(height: 8),
    //       Row(
    //         children: List.generate(5, (index) {
    //           return Icon(
    //             index < stars ? Icons.star : Icons.star_border,
    //             size: 16,
    //             color: Colors.black,
    //           );
    //         }),
    //       ),
    //       const SizedBox(height: 8),
    //       Text(comment, style: const TextStyle(fontSize: 14, height: 1.4)),
    //       const SizedBox(height: 10),
    //       Row(
    //         children: [
    //           const Icon(Icons.thumb_up_alt_outlined, size: 16, color: Colors.grey),
    //           const SizedBox(width: 4),
    //           Text("${(stars * 2) + 3}", style: const TextStyle(fontSize: 12, color: Colors.grey)), // 더미 숫자
    //           const SizedBox(width: 16),
    //           const Icon(Icons.thumb_down_alt_outlined, size: 16, color: Colors.grey),
    //         ],
    //       )
    //     ],
    //   ),
    // )];
  // }

  Widget _buildReviewItem(String name, String date, int stars, String comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFEEEEEE),
                child: Icon(Icons.person, color: Colors.grey, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    date,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < stars ? Icons.star : Icons.star_border,
                size: 16,
                color: Colors.black,
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(comment, style: const TextStyle(fontSize: 14, height: 1.4)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.thumb_up_alt_outlined,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                "${(stars * 2) + 3}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ), // 더미 숫자
              const SizedBox(width: 16),
              const Icon(
                Icons.thumb_down_alt_outlined,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 하단 네비게이션 바 (MainScreen과 스타일 맞춤)
  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _NavIcon(icon: Icons.home_filled, label: "홈"),
          _NavIcon(icon: Icons.search, label: "탐색"),
          _NavIcon(icon: Icons.favorite_border, label: "위시리스트"),
          _NavIcon(icon: Icons.shopping_bag_outlined, label: "장바구니"),
          _NavIcon(icon: Icons.person_outline, label: "프로필"),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _NavIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.grey, size: 24),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}