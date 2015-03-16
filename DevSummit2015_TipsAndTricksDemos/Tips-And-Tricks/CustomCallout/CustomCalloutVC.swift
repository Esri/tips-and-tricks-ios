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

class CustomCalloutVC: UIViewController, AGSMapViewTouchDelegate, AGSCalloutDelegate, AGSLayerCalloutDelegate, AGSPopupsContainerDelegate {
    
    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var toggleControl: UISegmentedControl!
    var graphicsLayer: AGSGraphicsLayer!
    var graphic: AGSGraphic!
    var calloutMapView: AGSMapView!
    var popupsContainerVC: AGSPopupsContainerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set touch delegate
        self.mapView.touchDelegate = self
        
        // add base layer to map
        let streetMapUrl = NSURL(string: "http://services.arcgisonline.com/arcgis/rest/services/World_Street_Map/MapServer")
        let tiledLayer = AGSTiledMapServiceLayer(URL: streetMapUrl);
        self.mapView.addMapLayer(tiledLayer, withName:"Tiled Layer")
        
        // zoom to envelope
        let envelope = AGSEnvelope.envelopeWithXmin(-12973339.119440766, ymin:4004738.947715673, xmax:-12972574.749157893, ymax:4006095.704967771, spatialReference: AGSSpatialReference.webMercatorSpatialReference()) as AGSEnvelope
        self.mapView.zoomToEnvelope(envelope, animated: true)
        
        // map view callout is selected by default
        self.toggleCustomCallout(self.toggleControl)
        
        // add observer to visibleAreaEnvelope
        self.mapView.addObserver(self, forKeyPath: "visibleAreaEnvelope", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    // MARK: Toggle Action
    
    @IBAction func toggleCustomCallout(sender: UISegmentedControl) {
        //
        // if
        if (self.toggleControl.selectedSegmentIndex == 0) {
            //
            // remove graphics layer
            self.mapView.removeMapLayer(self.graphicsLayer)
            
            // hide callout
            self.mapView.callout.hidden = true
            
            //
            // init callout map view
            self.calloutMapView = AGSMapView(frame: CGRectMake(0, 0, 180, 140))
            
            // add base layer to callout map view
            let imageryMapUrl = NSURL(string: "http://services.arcgisonline.com/arcgis/rest/services/World_Imagery/MapServer")
            let imageryLayer = AGSTiledMapServiceLayer(URL: imageryMapUrl);
            self.calloutMapView.addMapLayer(imageryLayer, withName:"Tiled Layer")
            
            // add graphics layer to map
            self.graphicsLayer = AGSGraphicsLayer.graphicsLayer() as AGSGraphicsLayer
            self.calloutMapView.addMapLayer(self.graphicsLayer, withName:"Graphics Layer")
            
            // zoom to geometry
            if self.mapView.visibleAreaEnvelope != nil {
                self.zoomToVisibleEnvelopeForCalloutMapView()
            }
        }
        else if (self.toggleControl.selectedSegmentIndex == 1) {
            //
            // add graphics layer to map
            self.graphicsLayer = AGSGraphicsLayer.graphicsLayer() as AGSGraphicsLayer
            self.graphicsLayer.calloutDelegate = self
            self.mapView.addMapLayer(self.graphicsLayer, withName:"Graphics Layer")
            
            // add graphics to map
            self.addRandomPoints(15, envelope: self.mapView.visibleAreaEnvelope)
        }
    }
    
    // MARK: Helper Methods
    
    func addRandomPoints(numPoints: Int, envelope: AGSEnvelope) {
        var graphics = [AGSGraphic]()
        for index in 1...numPoints {
            // get random point
            let pt = self.randomPointInEnvelope(envelope)
            
            // create a graphic to display on the map
            let pms = AGSPictureMarkerSymbol(imageNamed: "green_pin")
            pms.leaderPoint = CGPointMake(0, 14)
            let g = AGSGraphic(geometry: pt, symbol: pms, attributes: nil)
            
            // set attributes
            g.setValue(String(index), forKey: "ID")
            g.setValue("Test Name", forKey: "Name")
            g.setValue("Test Title", forKey: "Title")
            g.setValue("Test Value", forKey: "Value")
            
            // add graphic to graphics array
            graphics.append(g)
        }
        
        // add graphics to layer
        self.graphicsLayer.addGraphics(graphics)
    }
    
    func randomPointInEnvelope(envelope : AGSEnvelope) -> AGSPoint {
        var xDomain: UInt32 = (UInt32)(envelope.xmax - envelope.xmin)
        var dx: Double = 0
        if (xDomain != 0) {
            let x: UInt32 = arc4random() % xDomain
            dx = envelope.xmin + Double(x)
        }
        
        var yDomain: UInt32 = (UInt32)(envelope.ymax - envelope.ymin)
        var dy: Double = 0
        if (yDomain != 0) {
            let y: UInt32 = arc4random() % xDomain
            dy = envelope.ymin + Double(y)
        }
        
        return AGSPoint(x: dx, y: dy, spatialReference: envelope.spatialReference)
    }
    
    func zoomToVisibleEnvelopeForCalloutMapView() {
        let mutableEnvelope = self.mapView.visibleAreaEnvelope.mutableCopy() as AGSMutableEnvelope
        mutableEnvelope.expandByFactor(0.15)
        self.calloutMapView.zoomToGeometry(mutableEnvelope, withPadding: 0, animated: true)
    }
    
    // MARK: MapView Touch Delegate
    
    func mapView(mapView: AGSMapView!, shouldProcessClickAtPoint screen: CGPoint, mapPoint mappoint: AGSPoint!) -> Bool {
        // only process tap if we are showing popup callout view
        if (self.toggleControl.selectedSegmentIndex == 1) {
            return true
        }
        return false
    }
    
    func mapView(mapView: AGSMapView!, didTapAndHoldAtPoint screen: CGPoint, mapPoint mappoint: AGSPoint!, features: [NSObject : AnyObject]!) {
        //
        // process only for map view callout
        if (self.toggleControl.selectedSegmentIndex == 0) {
            //
            // set custom view of callout and show it
            self.mapView.callout.color = UIColor.brownColor()
            self.mapView.callout.leaderPositionFlags = .Top | .Bottom
            self.mapView.callout.customView = self.calloutMapView
            self.mapView.callout.showCalloutAt(mappoint, screenOffset: CGPointMake(0, 0), animated: true)
            
            // pan callout map view
            self.calloutMapView.centerAtPoint(mappoint, animated: true)
            
            // add graphic to callout map view
            if self.graphicsLayer.graphics.count == 0 {
                let symbol = AGSSimpleMarkerSymbol(color: UIColor(red: 255, green: 0, blue: 0, alpha: 0.5))
                self.graphic = AGSGraphic(geometry: mappoint, symbol:symbol  as AGSSymbol, attributes: nil)
                self.graphicsLayer.addGraphic(self.graphic)
            }
            else {
                self.graphic.geometry = mappoint;
            }
        }
    }
    
    func mapView(mapView: AGSMapView!, didMoveTapAndHoldAtPoint screen: CGPoint, mapPoint mappoint: AGSPoint!, features: [NSObject : AnyObject]!) {
        //
        // process only for map view callout
        if (self.toggleControl.selectedSegmentIndex == 0) {
            //
            // move callout
            self.mapView.callout.moveCalloutTo(mappoint, screenOffset: CGPointMake(0, 0), animated: true)
            
            // update geometry of graphic
            self.graphic.geometry = mappoint;
            
            // pan callout map view
            self.calloutMapView.centerAtPoint(mappoint, animated: true)
        }
    }
    
    func mapView(mapView: AGSMapView!, didEndTapAndHoldAtPoint screen: CGPoint, mapPoint mappoint: AGSPoint!, features: [NSObject : AnyObject]!) {
        //
        // process only for map view callout
        if (self.toggleControl.selectedSegmentIndex == 0) {
            //
            // remove all graphics from graphics layer
            self.graphicsLayer.removeAllGraphics()
        }
    }
    
    // MARK: Callout Delegate
    
    func callout(callout: AGSCallout!, willShowForFeature feature: AGSFeature!, layer: AGSLayer!, mapPoint: AGSPoint!) -> Bool {
        //
        // show popup view controller in callout
        let popupInfo = AGSPopupInfo(forGraphic: AGSGraphic(feature: feature))
        self.popupsContainerVC =  AGSPopupsContainerViewController(popupInfo: popupInfo, graphic: AGSGraphic(feature: feature), usingNavigationControllerStack: false)
        self.popupsContainerVC.delegate = self
        self.popupsContainerVC.doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: nil, action: nil)
        self.popupsContainerVC.actionButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Trash, target: nil, action: nil)
        self.popupsContainerVC.view.frame = CGRectMake(0,0,150,180)
        callout.leaderPositionFlags = .Right | .Left
        callout.customView = self.popupsContainerVC.view
        return true
    }
    
    // MARK: Poups Container Delegate
    
    func popupsContainerDidFinishViewingPopups(popupsContainer: AGSPopupsContainer!) {
        self.mapView.callout.hidden = true
    }
    
    // MARK: Observe
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        // get the object
        let mapView: AGSMapView = object as AGSMapView
        
        // zoom in the callout map view
        self.zoomToVisibleEnvelopeForCalloutMapView()
    }
}
