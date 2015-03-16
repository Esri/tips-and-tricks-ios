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

class SimulatedLocationVC: UIViewController {

    @IBOutlet var mapView: AGSMapView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let mapUrl = NSURL(string: "http://services.arcgisonline.com/arcgis/rest/services/World_Imagery/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(URL: mapUrl);
        
        self.mapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
    }

  
    @IBAction func startSimulation(sender: AnyObject) {
        
        // get the path to our GPX file
        let gpxPath = NSBundle.mainBundle().pathForResource("toughmudder2012", ofType: "gpx")
        
        // create our data source
        let gpxLDS = AGSGPXLocationDisplayDataSource(path: gpxPath)
        
        // tell the AGSLocationDisplay to use our data source
        self.mapView.locationDisplay.dataSource = gpxLDS;
        
        // enter nav mode so we can play it back oriented in the same way we would be if it
        // were happening "live"
        self.mapView.locationDisplay.autoPanMode = .Default;
        
        // we have to start the datasource in order to play it back
        self.mapView.locationDisplay.startDataSource()
    }

    @IBAction func stopSimulation(sender: AnyObject) {
        self.mapView.locationDisplay.stopDataSource()
    }
}
