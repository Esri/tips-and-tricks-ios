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

class PrefetchTilesVC: UIViewController{
    
    @IBOutlet weak var mapView:AGSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                let
tmsl = AGSTiledMapServiceLayer(URL: NSURL(string:"http://services.arcgisonline.com/arcgis/rest/services/World_Topo_Map/MapServer"))
        self.mapView.zoomToScale(30000, withCenterPoint: AGSPoint(x: -4017.962838, y: 6711405.345829, spatialReference: AGSSpatialReference.webMercatorSpatialReference()), animated: true)

        
        // set the buffer factor so we request tiles around us that
        // may soon be panned to
        // WARNING: This will use more memory so be careful!!!!!
        tmsl.bufferFactor = 1.6
    
        self.mapView.addMapLayer(tmsl)

    }
    
}