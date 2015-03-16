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

import UIKit
import ArcGIS

class CustomDynamicLayerVC: UIViewController {
    
    @IBOutlet var mapView: AGSMapView!
    
    var heatMapLayer:USGSQuakeHeatMapLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let mapUrl = NSURL(string: "http://services.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(URL: mapUrl);
        self.mapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
        
        self.addHeatMapLayer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addHeatMapLayer() {
        
        self.heatMapLayer = USGSQuakeHeatMapLayer()
        
        // setting render native resolution so the image callbacks honor screen scale
        // when requesting images... ie iphone 4 retina should be 640x960 not 320x480 (or equivalent)
        self.heatMapLayer.renderNativeResolution = true;
        
        // add layer to our map
        self.mapView.addMapLayer(self.heatMapLayer)
        
        // call load to go out and fetch the JSON data
        self.heatMapLayer.loadWithCompletion { () -> Void in
            NSLog("done adding heat map layer")
        }
    }
    
}
