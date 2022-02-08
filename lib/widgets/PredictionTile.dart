import 'package:cargo_tracking/constants.dart';
import 'package:cargo_tracking/datamodels/address.dart';
import 'package:cargo_tracking/datamodels/predictions.dart';
import 'package:cargo_tracking/dataprovider/appdata.dart';
import 'package:cargo_tracking/helpers/requesthelper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../brand_colors.dart';
class PredictionTile extends StatelessWidget {
  final Predictions prediction;
  PredictionTile({required this.prediction});


  Future<void> getPlaceDetails(String placeId,context) async {
    String url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";
    var response = await RequestHelper.getRequest(url);
    if(response == 'failed'){
      return;
    }
    if(response['status']=='OK'){
      Address thisPlace = Address(
          placeName: response['result']['name'],
          placeFormatAddress:response['result']['name'],
          placeId: placeId,
          latitude: response['result']['geometry']['location']['lat'],
          longitude: response['result']['geometry']['location']['lng']);

      Provider.of<AppData>(context,listen: false).updateDestinationAddress(thisPlace);
      Navigator.pop(context,'getDirection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: (){
        getPlaceDetails(prediction.placeId, context);
        print("tapped");
      },
      child: Column(
        children: [
          const SizedBox(height: 8,),
          Row(
            children: <Widget>[

              const Icon(Icons.location_on,color: BrandColors.colorDimText,),
              const SizedBox(width: 12,),
              Expanded(
                  child:Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget> [
                      Text(prediction.mainText,overflow: TextOverflow.ellipsis,maxLines:1,style:  TextStyle(fontSize: 16)),
                      const SizedBox(height: 2,),
                      Text(prediction.secondaryText,overflow: TextOverflow.ellipsis,maxLines: 1,),
                    ],
                  ) )
            ],
          ),
          const SizedBox(height: 8,),
        ],
      ),
    );
  }
}