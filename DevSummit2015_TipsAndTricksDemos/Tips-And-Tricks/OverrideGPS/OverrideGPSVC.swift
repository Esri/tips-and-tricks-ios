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

class OverrideGPSVC: UIViewController {

    @IBOutlet var mapView: AGSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let mapUrl = NSURL(string: "http://services.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(URL: mapUrl);
        self.mapView.addMapLayer(tiledLyr, withName:"Tiled Layer")

        // set the location display properties so we can override symbols
        self.mapView.locationDisplay.defaultSymbol = self.defaultSymbolOverride();
        self.mapView.locationDisplay.accuracySymbol = self.accuracySymbolOverride();
        self.mapView.locationDisplay.pingSymbol = self.pingSymbolOverride();
        self.mapView.locationDisplay.headingSymbol = self.headingSymbolOverride();
        self.mapView.locationDisplay.courseSymbol = self.courseSymbolOverride();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startStopAction(sender: AnyObject) {
        if self.mapView.locationDisplay.dataSourceStarted {
            let button = sender as UIBarButtonItem
            button.title = "Start GPS";
            self.mapView.locationDisplay.stopDataSource();
        }
        else {
            let button = sender as UIBarButtonItem
            button.title = "Stop GPS";
            self.mapView.locationDisplay.startDataSource();
            self.mapView.locationDisplay.autoPanMode = .Default;
        }
    }
    
    func defaultSymbolOverride() ->AGSMarkerSymbol {
        var sms = AGSSimpleMarkerSymbol(color: UIColor.orangeColor())
        sms.outline = nil
        return sms
    }
    
    func accuracySymbolOverride() ->AGSSimpleFillSymbol {
        let innerColor = UIColor.greenColor().colorWithAlphaComponent(0.35)
        let outerColor = UIColor.greenColor()
        var sfs = AGSSimpleFillSymbol(color: innerColor, outlineColor: outerColor)
        return sfs
    }
    
    func pingSymbolOverride() ->AGSMarkerSymbol {
        var sms = AGSSimpleMarkerSymbol(color: UIColor.yellowColor())
        sms.size = CGSizeMake(200, 200)
        return sms
    }
    
    func headingSymbolOverride() ->AGSMarkerSymbol {
        return self.defaultSymbolOverride()
    }
    
    func courseSymbolOverride() ->AGSMarkerSymbol {
        return self.defaultSymbolOverride()
    }
}
