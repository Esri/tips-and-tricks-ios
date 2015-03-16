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

class RoutePolylineVC: UIViewController, AGSLocatorDelegate, AGSRouteTaskDelegate {
    
    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var fromAddressBar: UISearchBar!
    @IBOutlet weak var toAddressBar: UISearchBar!
    @IBOutlet weak var startStopButton: UIButton!
    var routeTask: AGSRouteTask!
    var routeParams: AGSRouteTaskParameters!
    var locator: AGSLocator!
    var fromLocation: AGSPoint!
    var toLocation: AGSPoint!
    var routePolyline: AGSPolyline!
    var fromLocatorOp: NSOperation!
    var toLocatorOp: NSOperation!
    var fromStopGraphic: AGSStopGraphic!
    var toStopGraphic: AGSStopGraphic!
    var graphicsLayer: AGSGraphicsLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add base layer to map
        let streetMapUrl = NSURL(string: "http://services.arcgisonline.com/arcgis/rest/services/World_Street_Map/MapServer")
        let tiledLayer = AGSTiledMapServiceLayer(URL: streetMapUrl);
        self.mapView.addMapLayer(tiledLayer, withName:"Tiled Layer")
        
        // zoom to envelope
        let envelope = AGSEnvelope.envelopeWithXmin(-14405800.682625, ymin:-1221611.989964, xmax:-7030030.629509, ymax:11870379.854318, spatialReference: AGSSpatialReference.webMercatorSpatialReference()) as AGSEnvelope
        self.mapView.zoomToEnvelope(envelope, animated: true)
        
        // add graphics layer to map
        self.graphicsLayer = AGSGraphicsLayer.graphicsLayer() as AGSGraphicsLayer
        self.mapView.addMapLayer(self.graphicsLayer, withName:"Graphics Layer")
        
        // init locator
        self.locator = AGSLocator.locator() as AGSLocator
        self.locator.delegate = self
        
        // init route task
        self.routeTask = AGSRouteTask(URL: NSURL(string: "http://tasks.arcgisonline.com/ArcGIS/rest/services/NetworkAnalysis/ESRI_Route_NA/NAServer/Route"))
        self.routeTask.delegate = self
        
        // retrieve default route parameters
        self.routeTask.retrieveDefaultRouteTaskParameters()
    }
    
    // MARK: Route Action
    
    @IBAction func startStopAction(sender: UIButton) {
        
        if (sender.currentTitle == "Go") {
            //
            // change UI
            self.fromAddressBar.userInteractionEnabled = false
            self.toAddressBar.userInteractionEnabled = false
            self.startStopButton.setTitle("Stop", forState: UIControlState.Normal)
            
            //
            // resign first responders of search bars
            self.fromAddressBar.resignFirstResponder()
            self.toAddressBar.resignFirstResponder()
            
            //
            // geocode from and to addrsses
            //
            // from address
            let findParams = AGSLocatorFindParameters()
            findParams.outSpatialReference = self.mapView.spatialReference
            findParams.outFields = ["*"]
            findParams.text = self.fromAddressBar.text
            self.fromLocatorOp = self.locator.findWithParameters(findParams)
            //
            // to address
            findParams.outSpatialReference = self.mapView.spatialReference
            findParams.outFields = ["*"]
            findParams.text = self.toAddressBar.text
            self.toLocatorOp = self.locator.findWithParameters(findParams)
        }
        else {
            //
            // change UI
            self.fromAddressBar.userInteractionEnabled = true
            self.toAddressBar.userInteractionEnabled = true
            self.startStopButton.setTitle("Go", forState: UIControlState.Normal)
            
            // stop data source
            self.mapView.locationDisplay.stopDataSource()
        }
    }
    
    // MARK: Locator Delegate
    
    func locator(locator: AGSLocator!, operation op: NSOperation!, didFind results: [AnyObject]!) {
        //
        // check results
        if (results.count <= 0) {
            // let user know
            self.showError("Unable to Locate Address", message: "Unable to locate one of the address. Please change address and retry.")
        }
        
        //
        // check the result is for from or to address
        if (op == self.fromLocatorOp) {
            //
            // get the from location
            self.fromLocation = (results[0] as AGSLocatorFindResult).graphic.geometry as AGSPoint
        }
        else if (op == self.toLocatorOp) {
            //
            // get the to location
            self.toLocation = (results[0] as AGSLocatorFindResult).graphic.geometry as AGSPoint
        }
        
        //
        // if from and to locations are avilable route them
        if (self.fromLocation != nil && self.toLocation != nil) {
            //
            // set route params
            self.routeParams.outSpatialReference = self.mapView.spatialReference
            self.routeParams.returnRouteGraphics = true
            
            // create from stop
            self.fromStopGraphic = AGSStopGraphic.graphicWithGeometry(self.fromLocation, symbol: nil, attributes: nil) as AGSStopGraphic
            self.fromStopGraphic.name = "from"
            
            // create to stop
            self.toStopGraphic = AGSStopGraphic.graphicWithGeometry(self.toLocation, symbol: nil, attributes: nil) as AGSStopGraphic
            self.toStopGraphic.name = "to"
            
            // set stops on route params
            self.routeParams.setStopsWithFeatures([self.fromStopGraphic, self.toStopGraphic])
            
            // solve route 
            self.routeTask.solveWithParameters(self.routeParams)
        }
    }
    
    func locator(locator: AGSLocator!, operation op: NSOperation!, didFailToFindWithError error: NSError!) {
        self.showError("Failed to Locate Address", message: error.localizedDescription)
    }
    
    // MARK: Route Task Delegate
    
    func routeTask(routeTask: AGSRouteTask!, operation op: NSOperation!, didRetrieveDefaultRouteTaskParameters routeParams: AGSRouteTaskParameters!) {
        self.routeParams = routeParams
    }
    
    func routeTask(routeTask: AGSRouteTask!, operation op: NSOperation!, didFailToRetrieveDefaultRouteTaskParametersWithError error: NSError!) {
        self.showError("Failed to Retrieve Default Route Params", message: error.localizedDescription)
    }
    
    func routeTask(routeTask: AGSRouteTask!, operation op: NSOperation!, didSolveWithResult routeTaskResult: AGSRouteTaskResult!) {
        self.processRouteTaskResult(routeTaskResult)
    }
    
    func routeTask(routeTask: AGSRouteTask!, operation op: NSOperation!, didFailSolveWithError error: NSError!) {
        self.showError("Failed to Solve Route", message: error.localizedDescription)
    }
    
    // MARK: Process Route Result
    
    func processRouteTaskResult(routeTaskResult: AGSRouteTaskResult) {
        //
        // remove all graphics
        self.graphicsLayer.removeAllGraphics()
        
        // add route graphic to layer
        let routeResult = routeTaskResult.routeResults[0] as AGSRouteResult
        
        // add route graphic to map
        let routeGraphic = AGSGraphic(geometry: routeResult.routeGraphic.geometry, symbol: self.routeSymbol(), attributes: nil)
        self.graphicsLayer.addGraphic(routeGraphic)
        
        // assign symbols to stop graphics
        let fromStopSymbol = AGSPictureMarkerSymbol(imageNamed: "green_pin")
        fromStopSymbol.offset = CGPointMake(-1, 18)
        self.fromStopGraphic.symbol = fromStopSymbol
        
        let toStopSymbol = AGSPictureMarkerSymbol(imageNamed: "red_pin")
        toStopSymbol.offset = CGPointMake(-1, 18)
        self.toStopGraphic.symbol = toStopSymbol
        
        // add stop graphics to map
        self.graphicsLayer.addGraphics([fromStopGraphic, toStopGraphic])
        
        if (self.mapView.locationDisplay.dataSourceStarted) {
            self.mapView.locationDisplay.stopDataSource()
        }
        
        // first stop location display data source if started
        self.simulateLocationUpdates(routeResult)
    }
    
    //
    // set custom data source for the location display
    //
    func simulateLocationUpdates(routeResult: AGSRouteResult){

        //get route polyline
        let polyline = routeResult.routeGraphic.geometry as AGSPolyline
        
        
        //densify polyline to add vertices every 10 meters. Resulting speed=10*60*60/1000 = 36 KM/h
        let densifiedPolyline = AGSGeometryEngine.defaultGeometryEngine().densifyGeometry(polyline, withMaxSegmentLength: 10) as AGSPolyline

        
        //project to WGS84 (location updates are always WGS84)
        let wgs84Polyline = AGSGeometryEngine.defaultGeometryEngine().projectGeometry(densifiedPolyline, toSpatialReference: AGSSpatialReference.wgs84SpatialReference()) as AGSPolyline
        
        
        // create custom data source using polyline
        let lsDataSource = AGSSimulatedLocationDisplayDataSource()
        lsDataSource.setLocationsFromPolyline(wgs84Polyline)
        
        // set data source on location display and start
        self.mapView.locationDisplay.dataSource = lsDataSource
        self.mapView.locationDisplay.startDataSource()
        
        // set autoPan mode to navigation
        self.mapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanMode.Navigation
    }
    
    // MARK: Helper Method
    
    func showError(title: String!, message: String!) {
        let av = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK")
        av.show()
    }
    
    func routeSymbol() -> AGSCompositeSymbol {
        //
        // create a nice gradient line symbol using layered Simple Line Symbols
        let color1 = UIColor(red: 0.223529, green: 0.47451, blue: 0.843137, alpha: 1.0)
        let color2 = UIColor(red: 0.301961, green: 0.545098, blue: 0.858824, alpha: 1.0)
        let color3 = UIColor(red: 0.458824, green: 0.678431, blue: 0.890196, alpha: 1.0)
        let color4 = UIColor(red: 0.603922, green: 0.803922, blue: 0.921569, alpha: 1.0)
        let color5 = UIColor(red: 0.690196, green: 0.866667, blue: 0.937255, alpha: 1.0)
        
        let sls1 = AGSSimpleLineSymbol(color: color1, width: 10)
        let sls2 = AGSSimpleLineSymbol(color: color2, width: 8)
        let sls3 = AGSSimpleLineSymbol(color: color3, width: 6)
        let sls4 = AGSSimpleLineSymbol(color: color4, width: 4)
        let sls5 = AGSSimpleLineSymbol(color: color5, width: 2)
        
        let cs = AGSCompositeSymbol()
        cs.addSymbols([sls1, sls2, sls3, sls4, sls5])
        return cs
    }
    
}