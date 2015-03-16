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

class ZoomBeyondVC: UIViewController, AGSLayerDelegate {
    
    @IBOutlet weak var mapView: AGSMapView!
    var originalMaxScale:Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add base layer to map
        let mapUrl = NSURL(string: "http://basemap.nationalmap.gov/arcgis/rest/services/USGSTopo/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(URL: mapUrl);
        tiledLyr.delegate = self
        self.mapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
        
        let lyr = AGSDynamicMapServiceLayer(URL: NSURL(string: "https://sampleserver6.arcgisonline.com/arcgis/rest/services/Water_Network/MapServer"))
        lyr.delegate = self
        self.mapView.addMapLayer(lyr)
        
    }

    @IBAction func toggle(sender: UISwitch) {
        if sender.on {
            self.mapView.maxScale = 1000
        } else {
            self.mapView.maxScale = self.originalMaxScale
        }
    }
    
    func layerDidLoad(layer: AGSLayer!) {
        if layer.name == "Tiled Layer"{
         self.originalMaxScale = layer.maxScale
         layer.maxScale = 0
        }else{
            self.mapView.zoomToEnvelope(layer.initialEnvelope, animated: true)
        }
    }
}
