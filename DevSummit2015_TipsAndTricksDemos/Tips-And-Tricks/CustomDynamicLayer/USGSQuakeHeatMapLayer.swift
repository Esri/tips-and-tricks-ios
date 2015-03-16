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

class USGSQuakeHeatMapLayer: AGSDynamicLayer {

    var currentJsonOp: AGSJSONRequestOperation!
    var points: NSMutableArray!
    var bgQueue: NSOperationQueue!
    var completion: (() -> Void)!
    
    override init() {
        super.init()
        
        // queue to process our operation
        self.bgQueue = NSOperationQueue()
        
        // holds on to our earthquake data
        self.points = NSMutableArray();
    }
    
    func loadWithCompletion(completion:() -> Void) {
        
        self.completion = completion
        
        // go grab JSON from usgs.gov
        let url = NSURL(string:"http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.geojson")
        
        // create our JSON request operation
        self.currentJsonOp = AGSJSONRequestOperation(URL: url)
        self.currentJsonOp.target = self
        self.currentJsonOp.action = "operation:didSucceedWithResponse:"
        self.currentJsonOp.errorAction = "operation:didFailWithError:"
        
        self.bgQueue.addOperation(self.currentJsonOp)
    }
    
    // MARK: operation actions

    // this will be called when the JSON has been downloaded and parsed
    func operation(op:NSOperation, didSucceedWithResponse json:[NSObject:AnyObject]) {
        // simple json parsing to create an array of AGSPoints
        
        let features = json["features"] as [NSDictionary]
        for featureJSON in features {
            let geometry = featureJSON["geometry"] as NSDictionary
            let coordinates = geometry["coordinates"] as NSArray
            
            let latitude = coordinates[1].doubleValue
            let longitude = coordinates[0].doubleValue
            
            // note use of AGSSpatialReference class methods... these are shared instances so we don't created potentially several hundred (or thousand)
            // instances when we have loops like this
            let wgs84Pt = AGSPoint(x: longitude, y: latitude, spatialReference: AGSSpatialReference.wgs84SpatialReference())
            
            // project to mercator since we know we will be using a mercator map in this sample
            let mercPt = AGSGeometryEngine.defaultGeometryEngine().projectGeometry(wgs84Pt, toSpatialReference: AGSSpatialReference.webMercatorSpatialReference())
            self.points.addObject(mercPt)
        }
        
        self.layerDidLoad()
        if let comp = self.completion {
            comp()
        }
    }

    func operation(op: NSOperation, didFailWithError error:NSError) {
        self.layerDidFailToLoad(error)
        if let comp = self.completion {
            comp()
        }
    }

    // MARK: Dynamic layer overrides
    
    override var fullEnvelope: AGSEnvelope! {
        return self.mapView.maxEnvelope
    }
    
    override var initialEnvelope: AGSEnvelope! {
        get {
            return self.mapView.maxEnvelope
        }
        
        set {
            super.initialEnvelope = initialEnvelope
        }
    }
    
    override var spatialReference: AGSSpatialReference! {
        return self.mapView.spatialReference;
    }
    
    func requestImage(width w:NSInteger, height h:NSInteger, envelope env:AGSEnvelope, timeExtent te:AGSTimeExtent) {
        // if we are currently processing a current draw request we want to make sure we cancel it
        // because the user may have move away from that extent...
        self.bgQueue.cancelAllOperations()

        // kickoff an operation to draw our layer so we don't block the main thread.
        // This operation is responsible for creating a UIImage for the given envelope
        // and setting it on the layer
        var drawOp = USGSQuakeHeatMapDrawingOperation()
        drawOp.envelope = env;
        drawOp.rect = CGRectMake(0, 0, CGFloat(w), CGFloat(h));
        drawOp.layer = self;
        drawOp.points = self.points;

        //    // add our drawing operation to the queue
        self.bgQueue.addOperation(drawOp)
    }
}
