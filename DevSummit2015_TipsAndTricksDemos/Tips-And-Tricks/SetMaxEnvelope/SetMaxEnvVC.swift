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

class SetMaxEnvVC: UIViewController, AGSWebMapDelegate{
    
    @IBOutlet weak var mapView:AGSMapView!
    var webMap:AGSWebMap!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.webMap = AGSWebMap(itemId:"658732a227624146ba8322a94bc6ad8c", credential:nil)
        self.webMap.delegate = self
        self.webMap.openIntoMapView(self.mapView)
    }
    
    @IBAction func toggleMaxEnv(sender: UISwitch) {
        
        if sender.on {
            // restrict map to reasonable envelope
            self.mapView.maxEnvelope = AGSEnvelope(xmin: -12504837.275788, ymin: 3918992.625644, xmax: -12453585.779608, ymax: 4004138.444631, spatialReference: AGSSpatialReference.webMercatorSpatialReference())

        }else{
            self.mapView.maxEnvelope =  nil
        }
        
    }
    
    func webMap(webMap: AGSWebMap!, didFailToLoadLayer layerInfo: AGSWebMapLayerInfo!, baseLayer: Bool, federated: Bool, withError error: NSError!) {

        println("failed to load web map \(error)")
    }

    
}