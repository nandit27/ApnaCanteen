import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class FoodDetailsSlider extends StatelessWidget {
  final String slideImage1;
  final String slideImage2;
  final String slideImage3;

  const FoodDetailsSlider({
    Key? key,
    required this.slideImage1,
    required this.slideImage2,
    required this.slideImage3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Container(
        child: CarouselSlider(
          options: CarouselOptions(
            height: 200.0,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.8,
          ),
          items: [
            Image.asset(slideImage1),
            Image.asset(
              slideImage2,
              height: double.infinity,
              width: double.infinity,
            ),
            Image.asset(
              slideImage3,
              height: double.infinity,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
