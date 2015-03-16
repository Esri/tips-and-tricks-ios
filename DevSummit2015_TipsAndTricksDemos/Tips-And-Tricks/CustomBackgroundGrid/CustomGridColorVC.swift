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

class CustomGridColorVC: UIViewController {

    @IBOutlet weak var mapView:AGSMapView!
    var defaultGridLineColor:UIColor!
    var defaultBackgroundColor:UIColor!
    var defaultGridSize:CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let tmsl = AGSTiledMapServiceLayer(URL: NSURL(string:"http://services.arcgisonline.com/arcgis/rest/services/World_Street_Map/MapServer"))
        self.mapView.addMapLayer(tmsl)

        self.defaultBackgroundColor = self.mapView.backgroundColor
        self.defaultGridLineColor = self.mapView.gridLineColor
        self.defaultGridSize = self.mapView.gridSize
 
        
        
        
        // zoom into the US
        let env = AGSEnvelope(xmin: -14405800.682625, ymin: -1221611.989964 , xmax: -7030030.629509, ymax: 11870379.854318, spatialReference: AGSSpatialReference.webMercatorSpatialReference())
        self.mapView.zoomToEnvelope(env, animated: true)

        
    }
    
    @IBAction func toggleGrid(sender: UISwitch) {
        
        if sender.on {
            // simple way to set the background grid for the map
            self.mapView.gridLineColor = UIColor(red:204/255.0, green:189/255.0, blue:167/255.0, alpha:1.0)
            self.mapView.backgroundColor = UIColor(red:228/255.0, green:220/255.0, blue:199/255.0, alpha:1.0)
            self.mapView.gridSize = 128
        }else{
            self.mapView.gridLineColor = self.defaultGridLineColor
            self.mapView.backgroundColor  = self.defaultBackgroundColor
            self.mapView.gridSize = self.defaultGridSize
        }
    }
}