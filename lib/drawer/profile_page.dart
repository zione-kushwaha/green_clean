import 'package:flutter/material.dart';

class profile_page extends StatelessWidget {
  const profile_page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
         
        children: [
          Center(child: CircleAvatar(
            radius: 60,
            child: Icon(Icons.person,size: 60,),)),
             information(name: 'Name: ', info: 'Jeevan kushwaha'),
            information(name: 'Email: ',info: 'person@gmail.com',),
           
            information(name: 'Gender:', info: 'Male'),
            information(name: 'Contact', info: '+977 980-7151008'),
            information(name: 'Address', info: 'purwanipur-01, Bara'),
            
        ],
        ),
      ),
    );
  }
}

class information extends StatelessWidget {
  const information({
    super.key,
    required this.name,
    required this.info
  });
final String name;
final String info;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Row(
        children: [
          Text(name,style: TextStyle(fontSize: 20,fontWeight: FontWeight.w800),),
          SizedBox(width: 12,),
          Text(info)
        ],
      ),
    );
  } 
}