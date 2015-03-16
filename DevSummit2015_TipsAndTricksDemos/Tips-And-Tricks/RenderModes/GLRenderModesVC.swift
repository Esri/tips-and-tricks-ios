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

class GLRenderModesVC: UIViewController, AGSMapViewLayerDelegate {
    
    @IBOutlet weak var mapView: AGSMapView!
    var graphicsLayer: AGSGraphicsLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set mapView layer delegate
        self.mapView.layerDelegate = self
        
        self.mapView.allowRotationByPinching = true
        
        // add base layer to map
        let mapUrl = NSURL(string: "http://services.arcgisonline.com/arcgis/rest/services/World_Imagery/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(URL: mapUrl);
        self.mapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
        
        // add graphics layer to map
        self.graphicsLayer = AGSGraphicsLayer.graphicsLayer() as AGSGraphicsLayer
        self.mapView.addMapLayer(self.graphicsLayer, withName:"Graphics Layer")
        
        // zoom to envelope
        let envelope = AGSEnvelope.envelopeWithXmin(-14405800.682625, ymin:-1221611.989964, xmax:-7030030.629509, ymax:11870379.854318, spatialReference: AGSSpatialReference.webMercatorSpatialReference()) as AGSEnvelope
        self.mapView.zoomToEnvelope(envelope, animated: false)
    }
    
    @IBAction func toggleRenderMode(sender: UISwitch) {
        // remove graphics layer
        self.mapView.removeMapLayer(self.graphicsLayer)
        
        // get graphics
        let graphics = self.graphicsLayer.graphics;

        var renderMode:AGSGraphicsLayerRenderingMode

        if sender.on {
            renderMode = .Dynamic
        }else{
            renderMode = .Static
        }
        
        self.graphicsLayer = AGSGraphicsLayer(fullEnvelope: self.mapView.maxEnvelope, renderingMode: renderMode)
        self.graphicsLayer.addGraphics(graphics)
        self.mapView.addMapLayer(self.graphicsLayer, withName:"Graphics Layer")

    }
    
    func mapViewDidLoad(mapView: AGSMapView!) {
        // add 500 graphics
        self.addRandomPoints(500, envelope: self.mapView.visibleAreaEnvelope)
    }
    
    func addRandomPoints(numPoints: Int, envelope: AGSEnvelope) {
        var graphics = [AGSGraphic]()
        for index in 1...numPoints {
            // get random point
            let pt = self.randomPointInEnvelope(envelope)
            
            // create a graphic to display on the map
            let g = AGSGraphic(geometry: pt, symbol: AGSPictureMarkerSymbol(imageNamed: "red_pin"), attributes: nil)
            
            // add graphic to graphics array
            graphics.append(g)
        }
        
        // add graphics to layer
        self.graphicsLayer.addGraphics(graphics)
    }
    
    func randomPointInEnvelope(envelope : AGSEnvelope) -> AGSPoint {
        var xDomain: UInt32 = (UInt32)(envelope.xmax - envelope.xmin)
        var dx: Double = 0
        if (xDomain != 0) {
            let x: UInt32 = arc4random() % xDomain
            dx = envelope.xmin + Double(x)
        }
        
        var yDomain: UInt32 = (UInt32)(envelope.ymax - envelope.ymin)
        var dy: Double = 0
        if (yDomain != 0) {
            let y: UInt32 = arc4random() % xDomain
            dy = envelope.ymin + Double(y)
        }
        
        return AGSPoint(x: dx, y: dy, spatialReference: envelope.spatialReference)
    }
}
