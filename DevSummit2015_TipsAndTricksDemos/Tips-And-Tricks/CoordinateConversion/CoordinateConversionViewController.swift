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

import UIKit
import ArcGIS

class CoordinateConversionViewController: UIViewController, AGSMapViewTouchDelegate, UITextFieldDelegate {
    
    @IBOutlet var textField: UITextField!
    @IBOutlet var mapView: AGSMapView!
    
    var graphicsLayer:AGSSketchGraphicsLayer!
    var symbol:AGSPictureMarkerSymbol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.textField.delegate = self;
        
        // set up a starting value
        self.textField.text = "34 2 2.8 N, 117 53 24.66 E";
        
        // respond to touch events
        self.mapView.touchDelegate = self;
        
        // add a base layer/graphics layer
        let mapUrl = NSURL(string: "http://services.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(URL: mapUrl);
        self.graphicsLayer = AGSSketchGraphicsLayer()
        
        self.mapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
        self.mapView.addMapLayer(self.graphicsLayer, withName:"Graphics Layer")
        
        self.symbol = AGSPictureMarkerSymbol(imageNamed:"red_pin")
        self.symbol.offset = CGPointMake(-1, 18)

        // prevent content from going under the Navigation Bar
        self.edgesForExtendedLayout = UIRectEdge.None;
    }
    
    //MARK: - UITextFieldDelegate

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.graphicsLayer.removeAllGraphics()
        if (!textField.text.isEmpty) {
            // convert DMS string to AGSPoint in our map view's spatial reference
            let convertedPoint: AGSPoint! = AGSPoint(fromDegreesMinutesSecondsString: textField.text, withSpatialReference: self.mapView.spatialReference)

            // create a graphic
            let graphic: AGSGraphic! = AGSGraphic(geometry: convertedPoint, symbol:self.symbol, attributes: nil)
            
            // display on the map
            self.graphicsLayer.addGraphic(graphic)
        }
        
        return false
    }

    //MARK: - AGSMapViewTouchDelegate
    
    func mapView(mapView: AGSMapView!, didClickAtPoint screen: CGPoint, mapPoint mappoint: AGSPoint!, features: [NSObject : AnyObject]!) {
        //clear graphic layer before any update
        self.graphicsLayer?.removeAllGraphics()

        // convert from map point to DMS string
        let dmsString = mappoint.degreesMinutesSecondsStringWithNumDigits(3)
        self.textField.text = dmsString
        
        let graphic = AGSGraphic(geometry: mappoint, symbol: self.symbol, attributes: nil)
        self.graphicsLayer.addGraphic(graphic)
    }
}
