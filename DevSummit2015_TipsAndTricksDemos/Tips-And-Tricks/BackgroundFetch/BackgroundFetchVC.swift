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

import Foundation
import UIKit
import ArcGIS

class BackgroundFetchVC: UIViewController {
    
    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var downloadButton: UIBarButtonItem!
    var exportTileLayer: AGSTiledMapServiceLayer!
    var exportTileCacheTask: AGSExportTileCacheTask!
    var resumableJob: AGSResumableTaskJob!
    var exportTopoURL: NSURL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // add tiled layer to map
        // pass the credential cache from the portal so it can handle generating a credential
        // for the exportable tile layer
        self.exportTopoURL = NSURL(string: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/World_Street_Map/MapServer")
        self.exportTileLayer = AGSTiledMapServiceLayer(URL: self.exportTopoURL);
        self.mapView.addMapLayer(self.exportTileLayer, withName:"Tiled Layer")
        
        // zoom to envelope
        let envelope = AGSEnvelope.envelopeWithXmin(-14405800.682625, ymin:-1221611.989964, xmax:-7030030.629509, ymax:11870379.854318, spatialReference: AGSSpatialReference.webMercatorSpatialReference()) as AGSEnvelope
        self.mapView.zoomToEnvelope(envelope, animated: true)
    }
    
    @IBAction func downloadBtnClicked() {
        
        var levels = [UInt]()
        
        for index in 0...self.exportTileLayer.tileInfo.lods.count-1 {
            let lod =  self.exportTileLayer.tileInfo.lods[index] as AGSLOD
            levels.append(lod.level as UInt)
        }
        
        // create params using levels
        let params = AGSExportTileCacheParams(levelsOfDetail: levels, areaOfInterest: self.mapView.visibleAreaEnvelope)
        
        // set some compression on our tiles to save space
        params.recompressionQuality = 0.06
        
        // kick off our download
        self.kickoffOrResumeDownloadWithParams(params)
    }
    
    func kickoffOrResumeDownloadWithParams(params: AGSExportTileCacheParams!) {
        //
        // init export tile cache task
        self.exportTileCacheTask = AGSExportTileCacheTask(URL: self.exportTopoURL)
        
        // create a block to handle status callbacks
        var statusBlock: ((AGSResumableTaskJobStatus, [NSObject : AnyObject]!) -> Void)! = { (status, userInfo) -> Void in
            //
            // create a string value from the status enum
            let statusString = AGSResumableTaskJobStatusAsString(status)
            
            // print status
            println("export status: \(statusString)")
            
            // if we are downloading, log the bytes down and bytes expected
            // we can get those from the userInfo dictionary using the string constant keys
            if status == AGSResumableTaskJobStatus.FetchingResult {
                
                if userInfo != nil {
                    var bytesDownloaded: CLong = userInfo[AGSDownloadProgressTotalBytesDownloadedKey] as CLong
                    var bytesExpected: CLong = userInfo[AGSDownloadProgressTotalBytesExpectedKey] as CLong
                    println("downloading: \(bytesDownloaded)/\(bytesExpected)")
                }
            }
        }
        
        // create a completion block to reset our map and add our TPK to the map
        var completionBlock: ((AGSLocalTiledLayer!, NSError!) -> Void)! = { (localTiledLayer, error) -> Void in
            
            // reset map and add layer
            self.mapView.reset()
            self.mapView.addMapLayer(localTiledLayer)
            
            // enable download button
            self.downloadButton.enabled = true
            
            //Tell the user we're done
            UIAlertView(title: "Download Complete", message: "The tile cache has been added to the map", delegate: nil, cancelButtonTitle: "Ok").show()
            
            BackgroundHelper.postLocalNotificationIfAppNotActive("Tile cache downloaded.")
        }
        
        // disable download button
        self.downloadButton.enabled = false
        
        // starting new download
        println("starting a new download")
        self.resumableJob = self.exportTileCacheTask.exportTileCacheWithParameters(params, downloadFolderPath: nil, useExisting: false, status: statusBlock, completion: completionBlock)
    }
}
