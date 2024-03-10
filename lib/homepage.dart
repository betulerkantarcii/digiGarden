import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_custom_carousel_slider/flutter_custom_carousel_slider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    List<CarouselItem> itemList = [
      CarouselItem(
        image: const AssetImage(
          'assets/digigarden_homepage/7.png',
        ),
        boxDecoration: BoxDecoration(
          gradient: LinearGradient(
            begin: FractionalOffset.bottomCenter,
            end: FractionalOffset.topCenter,
            colors: [
              Colors.brown.shade200,
              Colors.black.withOpacity(.3),
            ],
            stops: const [0.0, 1.0],
          ),
        ),
        onImageTap: (i) {},
      ),
      CarouselItem(
        image: const AssetImage(
          'assets/digigarden_homepage/8.png',
        ),
        onImageTap: (i) {},
      ),
      CarouselItem(
        image: const AssetImage(
          'assets/digigarden_homepage/9.png',
        ),
        onImageTap: (i) {},
      ),
    ];
    return Scaffold(
      backgroundColor: Colors.brown[100],
      appBar: AppBar(
        title: Text('Ana Sayfa', style:TextStyle(fontSize: 25)),
        automaticallyImplyLeading: false,
      ),
      body:SingleChildScrollView(
      child:Column(
        children: [
          Container(
            height: 275,
            margin: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              image:const DecorationImage(
                image: AssetImage('assets/digigarden_homepage/1.png'),
                fit: BoxFit.cover,
              ),
              color: Colors.red,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(width:5.0, color: Colors.black),
            ),
          ),
          SizedBox(height: 20,),
          Container(
          height:275,
          child:ListView(
              children: <Widget>[
                CarouselSlider(
                    options: CarouselOptions(
                      enlargeCenterPage: true,
                      autoPlay: true,
                      aspectRatio: 16/9,
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enableInfiniteScroll: true,
                      autoPlayAnimationDuration: Duration(microseconds: 800),
                      viewportFraction:0.75,
                      ),
                    items:[
                      Container(
                        decoration: BoxDecoration(
                          image:const DecorationImage(
                            image: AssetImage('assets/digigarden_homepage/2.png'),
                            fit: BoxFit.cover,
                          ),
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(width:5.0, color: Colors.black),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          image:const DecorationImage(
                            image: AssetImage('assets/digigarden_homepage/3.png'),
                            fit: BoxFit.cover,
                          ),
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(width:5.0, color: Colors.black),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          image:const DecorationImage(
                            image: AssetImage('assets/digigarden_homepage/4.png'),
                            fit: BoxFit.cover,
                          ),
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(width:5.0, color: Colors.black),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          image:const DecorationImage(
                            image: AssetImage('assets/digigarden_homepage/5.png'),
                            fit: BoxFit.cover,
                          ),
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(width:5.0, color: Colors.black),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          image:const DecorationImage(
                            image: AssetImage('assets/digigarden_homepage/6.png'),
                            fit: BoxFit.cover,
                          ),
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(width:5.0, color: Colors.black),
                        ),
                      ),

                  ]

            ),
                ],
          ),
          ),
          Container(
            height:275,
            margin: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(width:5.0, color: Colors.black),
            ),
            child: CustomCarouselSlider(
              items: itemList,
              width: MediaQuery.of(context).size.width * .9,
              autoplay: false,
              showText: false,
              showSubBackground: false,
              indicatorShape: BoxShape.rectangle,
              indicatorPosition: IndicatorPosition.bottom,
              selectedDotColor: Colors.lightGreen,
              unselectedDotColor: Colors.white,
            ),

            ),
        ],
      )
      )
    );
  }
}