import 'dart:async';
import 'package:f4rtech_gdgsivas_hackathon/app/colors.dart';
import 'package:f4rtech_gdgsivas_hackathon/app/constants.dart';
import 'package:f4rtech_gdgsivas_hackathon/models/product.dart';
import 'package:f4rtech_gdgsivas_hackathon/viewmodel/product_model.dart';
import 'package:f4rtech_gdgsivas_hackathon/viewmodel/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'package:provider/provider.dart';

class MapView extends StatefulWidget {
  List<Product> filteredProducts;


  MapView(this.filteredProducts);

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  Completer<GoogleMapController> _controller = Completer();
  Position currentPosition;
  CameraPosition _kGooglePlex;
  String address;
  Set<Marker> markers;
  double radius=500;
  UserModel userModel;

  @override
  void initState() {
    super.initState();
    markers=Set<Marker>();
    userModel=context.read<UserModel>();
    currentPosition=userModel.currentLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
              body: FutureBuilder(future: getMarkers(),builder:(context,snapshot) {
                if (snapshot.hasData) {
                  _kGooglePlex = CameraPosition(
                    target: LatLng(currentPosition.latitude, currentPosition.longitude),
                    zoom: 15.4746,
                  );
                  return Container(
                    height: Constants.getHeight(context),
                    child: GoogleMap(
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      mapToolbarEnabled: false,
                      circles: Set.from([
                        Circle(
                          circleId: CircleId("1"),
                          center: LatLng(
                              currentPosition.latitude,
                              currentPosition.longitude),
                          radius: radius,
                          strokeColor: ColorTable.blue,
                          fillColor: Colors.blue.withOpacity(0.5),
                          strokeWidth: 5,
                        )
                      ]),
                      markers: snapshot.data,
                      mapType: MapType.normal,
                      initialCameraPosition: _kGooglePlex,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                    ),
                  );
                }
                else {
                  return Center(child:CircularProgressIndicator());
                }
              }));
  }

   /*Bu fonksiyon userModel'e taşınabilir*/

  /* Adresin Latitude ve longitude değerlerini kullanarak adresin String halini döndürür */


  Future<Set<Marker>> getMarkers() async{
    final productModel=Provider.of<ProductModel>(context,listen: false);
    //filteredProducts=await productModel.readFilteredProducts(radius);
    for(int i=0;i<widget.filteredProducts.length;++i)
      {
        var latitude=widget.filteredProducts[i].location.latitude;
        var longitude=widget.filteredProducts[i].location.longitude;
          markers.add(Marker(markerId: MarkerId('$i'),
              position: LatLng(
                  latitude, longitude),onTap: (){
            return showModalBottomSheet(context: context,
              backgroundColor: Colors.blue.withOpacity(0),
              builder: (context){
              if(address!=null) address=null;
              return FutureBuilder(future:productModel.getAdress(latitude, longitude),builder: (context,snapshot)
                {
                  if(snapshot.hasData)
                    return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(topRight: Radius.circular(30),topLeft: Radius.circular(30)),
                          color: ColorTable.blue,
                        ),
                        child: Column(
                      children: [
                        Text(snapshot.data.toString()),
                        Text(widget.filteredProducts[i].name),
                        Text(widget.filteredProducts[i].productType),
                        Text(widget.filteredProducts[i].explanation),
                        RaisedButton(child: Text('Teklif Ver'),onPressed: (){
                        },)
                      ],
                    ));
                  else
                    return Center(child:CircularProgressIndicator());
                },);
            },);
              }));

      }
    return markers;
  }
}
