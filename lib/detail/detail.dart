import 'package:flutter/material.dart';
import 'package:green_theme/detail/individual_screen.dart';
import 'package:green_theme/route_animation.dart';

class detail_screen extends StatelessWidget {
   detail_screen({super.key});
List<String> items=[
  'Temple',
  'Devotional site',
  'Organic Farming',
  'Plantation',
  'Development',
  'No Poverty',
  'No somky vechiles',
  'Recyling'
];
late String image;
late String title;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15,right: 15,top: 8,bottom: 15),
      child: ListView.builder(
        itemCount: 8,
        itemBuilder: (context,index){
        return Card(
          child: Stack(
           
            children:[ GestureDetector(
              onTap: (){
                image='assets/image/image${index+1}.jpeg';
                title=items[index];
                _navigateToNextScreen(context, 'individual',index);
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20)
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  
                  child: Image.asset('assets/image/image${index+1}.jpeg',fit: BoxFit.fill,)),
              ),
            ),
            Positioned(
             bottom: 10,
              left: 90,
              child: Card(
                
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(items[index],style: TextStyle(fontSize: 20,fontWeight: FontWeight.w900),),
                )))
            ]
          ),
        );
      }),
    );
  }
   void _navigateToNextScreen(BuildContext context, String screen,int index) {
    Future.delayed(const Duration(milliseconds: 200), () async {
      if (screen == "individual") {
        Navigator.of(context).push(createRoute( individual_screen(image: image,title: title,index: index,)));
      } 
    });
  }
}