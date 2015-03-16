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

class WebTiledLayerVC: UIViewController {
    
    @IBOutlet weak var mapView: AGSMapView!
    var webTiledLayer: AGSWebTiledLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func toggleWebTiledLayer(sender: UISegmentedControl) {
        //
        // reset map view
        self.mapView.reset()

        // load Stamen web tiled layer
        if sender.selectedSegmentIndex == 0 {
            self.webTiledLayer = AGSWebTiledLayer(templateURL: "http://{subDomain}.tile.stamen.com/watercolor/{level}/{col}/{row}.jpg", tileInfo: nil, spatialReference: nil, fullExtent: nil, subdomains: ["a", "b", "c", "d"])
        }
        // load Thunderforest web tiled layer
        else if sender.selectedSegmentIndex == 1 {
            self.webTiledLayer = AGSWebTiledLayer(templateURL: "http://tile.thunderforest.com/transport/{level}/{col}/{row}.png", tileInfo: nil, spatialReference: nil, fullExtent: nil, subdomains: nil)
        }
        // load Google web tiled layer
        else if sender.selectedSegmentIndex == 2 {
            self.webTiledLayer = AGSWebTiledLayer(templateURL: "https://{subDomain}.tiles.mapbox.com/v4/examples.map-8ly8i7pv/{level}/{col}/{row}@2x.png?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6IlhHVkZmaW8ifQ.hAMX5hSW-QnTeRCMAy9A8Q", tileInfo: nil, spatialReference: nil, fullExtent: nil, subdomains: ["a", "b", "c", "d"])
        }
        
        // add layer to map
        self.mapView.addMapLayer(self.webTiledLayer, withName: "Web Tiled Layer")

        // zoom to envelope
        let envelope = AGSEnvelope.envelopeWithXmin(-14405800.682625, ymin:-1221611.989964, xmax:-7030030.629509, ymax:11870379.854318, spatialReference: AGSSpatialReference.webMercatorSpatialReference()) as AGSEnvelope
        self.mapView.zoomToEnvelope(envelope, animated: true)
    }
}
