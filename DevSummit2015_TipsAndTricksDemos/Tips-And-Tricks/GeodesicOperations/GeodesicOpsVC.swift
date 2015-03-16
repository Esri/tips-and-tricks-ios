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

import Foundation
import UIKit
import ArcGIS

class GeodesicOpsVC: UIViewController, AGSMapViewTouchDelegate {
    
    @IBOutlet weak var mapView: AGSMapView!
    var pointsLayer: AGSGraphicsLayer!
    var flightPathLayer: AGSGraphicsLayer!
    var startGraphic: AGSGraphic!
    var endGraphic: AGSGraphic!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set touch delegate
        self.mapView.touchDelegate = self
        
        // add base layer to map
        let mapUrl = NSURL(string: "http://services.arcgisonline.com/arcgis/rest/services/World_Imagery/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(URL: mapUrl);
        self.mapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
        
        // add points layer to map
        self.pointsLayer = AGSGraphicsLayer.graphicsLayer() as AGSGraphicsLayer
        self.mapView.addMapLayer(self.pointsLayer)
        
        // add flight path layer to map
        self.flightPathLayer = AGSGraphicsLayer.graphicsLayer() as AGSGraphicsLayer
        self.mapView.addMapLayer(self.flightPathLayer)
    }
    
    @IBAction func goBtnClicked() {
        //
        // remove exiting graphics from flight path layer
        self.flightPathLayer.removeAllGraphics()

        // create a new line to represent our point A and B
        var polyline = AGSMutablePolyline(spatialReference: self.mapView.spatialReference)
        polyline.addPathToPolyline()
        polyline.addPointToPath(self.startGraphic.geometry as AGSPoint)
        polyline.addPointToPath(self.endGraphic.geometry as AGSPoint)
        
        // densify the line so we can follow curvature of the earth
        let denseLine = AGSGeometryEngine.defaultGeometryEngine().geodesicDensifyGeometry(polyline, withMaxSegmentLength: 100, inUnit: AGSSRUnit.UnitSurveyMile)
        
        // show how to get geodesic distance as well...we just log it here...
        let distanceResult = AGSGeometryEngine.defaultGeometryEngine().geodesicDistanceBetweenPoint1(self.startGraphic.geometry as AGSPoint, point2: self.endGraphic.geometry as AGSPoint, inUnit: AGSSRUnit.UnitSurveyMile)
        
        println("distance: \(distanceResult.distance)")
        
        // basic graphic with thin red line
        let flightGraphic = AGSGraphic(geometry: denseLine, symbol: AGSSimpleLineSymbol(color: UIColor.redColor()), attributes: nil)
        
        // nice looking composite symbol, uncomment to use
        //let flightGraphic = AGSGraphic(geometry: denseLine, symbol: self.flightPathSymbol(), attributes: nil)

        // add graphic to layer
        self.flightPathLayer.addGraphic(flightGraphic)
    }
    
    @IBAction func resetBtnClicked() {
        self.pointsLayer.removeAllGraphics()
        self.flightPathLayer.removeAllGraphics()
    }

    func mapView(mapView: AGSMapView!, didClickAtPoint screen: CGPoint, mapPoint mappoint: AGSPoint!, features: [NSObject : AnyObject]!) {
        
        if self.pointsLayer.graphicsCount == 0 {
            let pms = AGSPictureMarkerSymbol(imageNamed: "green_pin")
            pms.offset = CGPointMake(-1, 18)
            self.startGraphic = AGSGraphic(geometry: mappoint, symbol: pms, attributes: nil)
            self.pointsLayer.addGraphic(self.startGraphic)
        }
        else if self.flightPathLayer.graphicsCount == 0 {
            self.pointsLayer.removeGraphic(self.endGraphic)
            let pms = AGSPictureMarkerSymbol(imageNamed: "red_pin")
            pms.offset = CGPointMake(-1, 18)
            self.endGraphic = AGSGraphic(geometry: mappoint, symbol: pms, attributes: nil)
            self.pointsLayer.addGraphic(self.endGraphic)
        }
    }
    
    func flightPathSymbol() -> AGSCompositeSymbol {
        //
        // create a nice gradient line symbol using layered Simple Line Symbols
        let color1 = UIColor(red: 0.223529, green: 0.47451, blue: 0.843137, alpha: 1.0)
        let color2 = UIColor(red: 0.301961, green: 0.545098, blue: 0.858824, alpha: 1.0)
        let color3 = UIColor(red: 0.458824, green: 0.678431, blue: 0.890196, alpha: 1.0)
        let color4 = UIColor(red: 0.603922, green: 0.803922, blue: 0.921569, alpha: 1.0)
        let color5 = UIColor(red: 0.690196, green: 0.866667, blue: 0.937255, alpha: 1.0)

        let sls1 = AGSSimpleLineSymbol(color: color1, width: 10)
        let sls2 = AGSSimpleLineSymbol(color: color2, width: 8)
        let sls3 = AGSSimpleLineSymbol(color: color3, width: 6)
        let sls4 = AGSSimpleLineSymbol(color: color4, width: 4)
        let sls5 = AGSSimpleLineSymbol(color: color5, width: 2)
        
        let cs = AGSCompositeSymbol()
        cs.addSymbols([sls1, sls2, sls3, sls4, sls5])
        return cs
    }
}
