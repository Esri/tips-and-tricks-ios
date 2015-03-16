// Copyright 2015 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import UIKit
import ArcGIS

class SymbolAlignmentVC: UIViewController, AGSMapViewLayerDelegate, AGSLayerCalloutDelegate {
    
    @IBOutlet weak var mapView: AGSMapView!
    var graphicsLayer: AGSGraphicsLayer!
    var pictureSymbol: AGSPictureMarkerSymbol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set mapView layer delegate
        self.mapView.layerDelegate = self
        
        // add base layer to map
        let mapUrl = NSURL(string: "http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Light_Gray_Base/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(URL: mapUrl);
        self.mapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
        
        // add graphics layer to map
        self.graphicsLayer = AGSGraphicsLayer.graphicsLayer() as AGSGraphicsLayer
        self.graphicsLayer.calloutDelegate = self;
        self.mapView.addMapLayer(self.graphicsLayer, withName:"Graphics Layer")
        
        let pointWGS84 = AGSPoint(fromDecimalDegreesString: "34.35815 S, 18.472 E", withSpatialReference: AGSSpatialReference.wgs84SpatialReference())
        
        let pointWebMerc = AGSGeometryEngine.defaultGeometryEngine().projectGeometry(pointWGS84, toSpatialReference: AGSSpatialReference.webMercatorSpatialReference()) as AGSPoint;
        
        let symbol = AGSSimpleMarkerSymbol(color: UIColor.orangeColor())
        symbol.style = AGSSimpleMarkerSymbolStyle.Circle
        symbol.size = CGSize(width: 10, height: 10)
        let graphic = AGSGraphic(geometry: pointWebMerc, symbol: symbol, attributes: nil)
        self.graphicsLayer.addGraphic(graphic)
        
        self.mapView.zoomToScale(8000000, withCenterPoint: pointWebMerc, animated: true)

        
        self.pictureSymbol = AGSPictureMarkerSymbol(imageNamed: "BluePushpin")
        let graphic2 = AGSGraphic(geometry: pointWebMerc, symbol: self.pictureSymbol, attributes: ["Description":"Cape of Good Hope"])
        self.graphicsLayer.addGraphic(graphic2)
        
        
    }
    
    @IBAction func toggleAlignment(sender: UISwitch) {
        
        if sender.on {
            //9 points right, 16 points up
            self.pictureSymbol.offset = CGPoint(x: 9, y: 16)
            //9 points left, 11 points up
            self.pictureSymbol.leaderPoint = CGPoint(x: -9, y: 11)
        }else{
            
            self.pictureSymbol.offset = CGPoint(x: 0, y: 0)
            self.pictureSymbol.leaderPoint = CGPoint(x: 0, y: 0)
        }
    }

    
    func callout(callout: AGSCallout!, willShowForFeature feature: AGSFeature!, layer: AGSLayer!, mapPoint: AGSPoint!) -> Bool {
        
        let graphic = feature as AGSGraphic
        callout.title = graphic.attributeAsStringForKey("Description")
        return true
    }
    

}
