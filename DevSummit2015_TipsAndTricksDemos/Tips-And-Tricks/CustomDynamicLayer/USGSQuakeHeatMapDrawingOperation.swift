//
//  USGSQuakeHeatMapDrawingOperation.swift
//  TipsAndTricks_DevSummit2015
//
//  Created by Mark Dostal on 3/3/15.
//  Copyright (c) 2015 Esri. All rights reserved.
//

import UIKit
import ArcGIS

class USGSQuakeHeatMapDrawingOperation: NSOperation {
   
    var rect: CGRect!
    var envelope: AGSEnvelope!
    var layer: AGSDynamicLayer!
    var points: NSArray!

    func AGSMapPointToScreenPoint2(mapPoint: AGSPoint, env: AGSEnvelope, screenSize: CGSize) -> CGPoint {
        var xPct = (mapPoint.x - env.xmin) / env.width;
        var yPct = (env.ymax - mapPoint.y) / env.height;
        return CGPointMake(CGFloat(screenSize.width) * CGFloat(xPct), CGFloat(screenSize.height) * CGFloat(yPct));
    };

    override func main() {
        if self.isCancelled() {
            return
        }
        
        var pts = NSMutableArray()
        for pt in self.points {
            if self.isCancelled() {
                return
            }
            var point = pt as AGSPoint
            if self.envelope.containsPoint(point) {
                var p = AGSMapPointToScreenPoint2(point, env: self.envelope, screenSize: CGSizeMake(CGRectGetWidth(self.rect), CGRectGetHeight(self.rect)))
                pts.addObject(NSValue(CGPoint:p))
            }
        }
        
        var heatMapImg:UIImage = SHGeoUtils.heatMapWithRect(self.rect, boost:0.75, points: pts, weights:nil)
        if self.isCancelled() {
            return
        }
        
        self.layer.setImageData(UIImagePNGRepresentation(heatMapImg), forEnvelope: self.envelope)
    }
}
