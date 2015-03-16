//
//  KVOVC.swift
//  TipsAndTricks_DevSummit2015
//
//  Created by Divesh Goyal on 3/8/15.
//  Copyright (c) 2015 Esri. All rights reserved.
//

import Foundation
import ArcGIS

class KVOVC: UIViewController {
    
    @IBOutlet weak var mapView: AGSMapView!
    
    @IBOutlet weak var northArrowImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupMap()
        
        self.mapView.addObserver(self, forKeyPath: "rotationAngle", options: NSKeyValueObservingOptions.New, context: nil)
        
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        // get the object
        
        let angle = -(self.mapView.rotationAngle*3.14)/180
        let transform = CGAffineTransformMakeRotation(CGFloat(angle))
        self.northArrowImage.transform = transform

        
    }
    
    func setupMap() {
        self.mapView.allowRotationByPinching = true
        
        let tiledLayer = AGSTiledMapServiceLayer(URL: NSURL(string: "http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Light_Gray_Base/MapServer"))
        self.mapView.addMapLayer(tiledLayer)
        self.mapView.zoomToScale(40000, withCenterPoint: AGSPoint(x: -4017.962838, y: 6711405.345829, spatialReference: AGSSpatialReference.webMercatorSpatialReference()), animated: true)
    }

}
