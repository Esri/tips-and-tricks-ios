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

class RequestOpWebServiceVC: UIViewController, AGSMapViewTouchDelegate {
    
    @IBOutlet weak var mapView:AGSMapView!
    @IBOutlet var loadingView:UIView!

    var currentJsonOp:AGSJSONRequestOperation!
    var queue:NSOperationQueue!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Add layers
        var mapUrl = NSURL(string: "http://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer")
        var tiledLyr = AGSTiledMapServiceLayer(URL: mapUrl)
        self.mapView.addMapLayer(tiledLyr, withName:"Tiled Layer 1")
        
        
        mapUrl = NSURL(string: "http://services.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/MapServer")
        tiledLyr = AGSTiledMapServiceLayer(URL: mapUrl)
        self.mapView.addMapLayer(tiledLyr, withName:"Tiled Layer 2")
        
        
        //initialize the operation queue which will make webservice requests in the background
        self.queue = NSOperationQueue()
        
        //Set the touch delegate so we can respond when user taps on the map
        self.mapView.touchDelegate = self
        
        //hide the accessory button because we won't be needing it
        self.mapView.callout.accessoryButtonHidden = true
        
        self.mapView.callout.color = UIColor.whiteColor()
        self.mapView.callout.titleColor = UIColor.blueColor()
        self.mapView.callout.detailColor = UIColor.blackColor()
        
        self.loadingView.frame = CGRectMake(0, 0, 36, 36)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: map view touch delegate
    
    func mapView(mapView: AGSMapView!, didClickAtPoint screen: CGPoint, mapPoint mappoint: AGSPoint!, features: [NSObject : AnyObject]!) {
        
        //Cancel any outstanding operations for previous webservice requests
        self.queue.cancelAllOperations()
        
        //Show an activity indicator while we initiate a new request
        
        self.mapView.callout.customView = self.loadingView
        self.mapView.callout.showCalloutAt(mappoint, screenOffset:CGPointZero, animated:true)
        
        let latLong = AGSGeometryEngine.defaultGeometryEngine().projectGeometry(mappoint, toSpatialReference:AGSSpatialReference.wgs84SpatialReference()) as AGSPoint
        //Set up the parameters to send the webservice
        var params = [NSObject:AnyObject]()
        params["lon"] = latLong.x
        params["lat"] = latLong.y
        params["units"] = "imperial"
        
        //Set up an operation for the current request
        let url = NSURL(string: "http://api.openweathermap.org/data/2.5/weather/")
        self.currentJsonOp = AGSJSONRequestOperation(URL: url, queryParameters:params)
        self.currentJsonOp.target = self
        self.currentJsonOp.action = "operation:didSucceedWithResponse:"
        self.currentJsonOp.errorAction = "operation:didFailWithError:"
        
        //Add operation to the queue to execute in the background
        self.queue.addOperation(self.currentJsonOp)
    }
    
    func operation(op:NSOperation, didSucceedWithResponse weatherInfo:[NSObject:AnyObject]) {
        //The webservice was invoked successfully.
        
        let placeName = weatherInfo["name"] as? String
        let country = weatherInfo["sys"]?["country"] as? String
        let temp = weatherInfo["main"]?["temp"] as? Double
        let humidity = weatherInfo["main"]?["humidity"] as? Int
        
        var title = ""
        if placeName != nil {
            title = placeName!
        }
        if country != nil {
            title = title + ", " + country!
        }
        
        var detail = ""
        if temp != nil {
            detail = "\(temp!)\u{00B0}F"
        }
        if humidity != nil {
            detail = "\(detail), \(humidity!)% Humidity"
        }
        self.mapView.callout.customView = nil
        self.mapView.callout.title = title
        self.mapView.callout.detail = detail
    }
    
    func operation(op: NSOperation, didFailWithError error:NSError) {
        //Error encountered while invoking webservice. Alert user
        self.mapView.callout.hidden = true
        UIAlertView(title: "Sorry", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "Ok").show()
    }
}
