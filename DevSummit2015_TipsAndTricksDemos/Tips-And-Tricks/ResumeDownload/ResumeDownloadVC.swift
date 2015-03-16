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

/*
1. Shows off resume download
2. Shows login to portal
3. Shows storing credential
*/

class ResumeDownloadVC: UIViewController, AGSPortalDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var mapView: AGSMapView!
    var promptedOnce: Bool = false
    var resumeID: String!
    var portal: AGSPortal!
    var exportTileLayer: AGSTiledMapServiceLayer!
    var exportTileCacheTask: AGSExportTileCacheTask!
    var oAuthVC: AGSOAuthLoginViewController!
    var loginNavVC: OAuthLoginNavVC!
    var resumableJob: AGSResumableTaskJob!
    var keychainWrapper: AGSKeychainItemWrapper!
    var portalURL: NSURL!
    var exportTopoURL: NSURL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create our keychain wrapper so we can store/retrieve stuff from the keychain
        self.keychainWrapper = AGSKeychainItemWrapper(identifier: "TipsAndTricksDevSummit2015", accessGroup: nil)
        
        // set portal url
        self.portalURL = NSURL(string: "https://www.arcgis.com")
        
        // set export url
        self.exportTopoURL = NSURL(string: "http://tiledbasemaps.arcgis.com/arcgis/rest/services/World_Topo_Map/MapServer")
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //
        // check if we have a stored credential
        // and attempt to load the portal if so
        let savedCredential = self.keychainWrapper.keychainObject() as AGSCredential!
        if savedCredential != nil {
            println("loading with saved credential")
            self.loadPortalWithCredential(savedCredential)
            return
        }
        
        // we want to require login, so keep showing page until
        // the user successfully logs in
        if !self.promptedOnce {
            self.setupAndDisplayLogin()
        }
    }
    
    func loadPortalWithCredential(credential: AGSCredential) {
        self.portal = AGSPortal(URL: self.portalURL, credential: credential)
        self.portal.delegate = self
    }
    
    func setupAndDisplayLogin() {
        //
        // create OAuth view controller
        self.oAuthVC = AGSOAuthLoginViewController(portalURL: self.portalURL, clientID: self.clientID())
        
        // give vc a title
        self.oAuthVC.title = "Login to Portal"
        
        // setup 'cancle' button
        self.oAuthVC.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: Selector("cancelLogin"))
        
        // create our container to put the OAuth skeleton vc inside
        self.loginNavVC = OAuthLoginNavVC(rootViewController: self.oAuthVC)
        
        // dismiss our login
        self.oAuthVC.completion = { [weak self]  credential, error in
            self?.loginNavVC.dismissViewControllerAnimated(true, completion: nil)
            self?.loadPortalWithCredential(credential)
        }
        
        // set prompted once to true
        self.promptedOnce = true
        
        // present Login VC to user
        self.presentViewController(self.loginNavVC, animated: true, completion: nil)
    }
    
    func cancelLogin() {
        self.loginNavVC.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func clientID() -> String! {
        //TODO: Insert client id 
       return "<insert_your_clientid_here>"
    }
    
    func portalDidLoad(portal: AGSPortal!) {
        //
        // save our portal credential in the keychain
        self.keychainWrapper.setKeychainObject(portal.credential)
        
        // unhide the map now that our portal is loaded
        self.mapView.hidden = false
        
        // add tiled layer to map
        // pass the credential cache from the portal so it can handle generating a credential
        // for the exportable tile layer
        self.exportTileLayer = AGSTiledMapServiceLayer(URL: self.exportTopoURL);
        self.exportTileLayer.credentialCache = portal.credentialCache
        self.mapView.addMapLayer(self.exportTileLayer, withName:"Tiled Layer")
        
        // zoom to envelope
        let envelope = AGSEnvelope.envelopeWithXmin(-12973339.119440766, ymin:4004738.947715673, xmax:-12972574.749157893, ymax:4006095.704967771, spatialReference: AGSSpatialReference.webMercatorSpatialReference()) as AGSEnvelope
        self.mapView.zoomToEnvelope(envelope, animated: true)
        
        // check if we can resume a previous download
        self.resumeID = NSUserDefaults.standardUserDefaults().valueForKey("resumeID") as String!
        if self.resumeID != nil {
            let av = UIAlertView(title: "Resume Job?", message: "A previous job was detected, do you wish to resume?", delegate: self, cancelButtonTitle: "NO", otherButtonTitles: "YES")
            av.show()
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        //
        // buttonIndex
        // 0 - NO
        // 1 - YES
        
        // call method to resume with resume ID
        if buttonIndex == 1 {
            self.kickoffOrResumeDownloadWithParams(nil, resumeID: self.resumeID)
        }
        else {
            // remove old resumeID
            NSUserDefaults.standardUserDefaults().setValue(nil, forKey: "resumeID")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func kickoffOrResumeDownloadWithParams(params: AGSExportTileCacheParams!, resumeID: String!) {
        //
        // init export tile cache task
        self.exportTileCacheTask = AGSExportTileCacheTask(URL: self.exportTopoURL)
        self.exportTileCacheTask.credentialCache = self.portal.credentialCache
        
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
            
            // new at 10.2.2 - override minScale/maxScale in case you have
            // operational data that is more detailed than your basemap
            self.mapView.minScale = 100000;
            
            // remove our resume ID since job completed
            NSUserDefaults.standardUserDefaults().setValue(nil, forKey: "resumeID")
            
            // call synchronize so we write out the values
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        if resumeID != nil {
            println("resuming a previous download")
            self.resumableJob = self.exportTileCacheTask.exportTileCacheWithResumeID(resumeID, status: statusBlock, completion: completionBlock)
            if (self.resumableJob == nil) {
                println("could not resume download...")
                let av = UIAlertView(title: "Failed to Resume Job", message: "Unable to resume download. Please start new download", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK")
                av.show()
            }
        }
        else {
            // starting new download
            println("starting a new download")
            self.resumableJob = self.exportTileCacheTask.exportTileCacheWithParameters(params, downloadFolderPath: nil, useExisting: false, status: statusBlock, completion: completionBlock)
        }
        
        // store our resume ID in case app is killed
        NSUserDefaults.standardUserDefaults().setValue(self.resumableJob.resumeID, forKey: "resumeID")
        NSUserDefaults.standardUserDefaults().synchronize()
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
        
        // kick off our download (no resumeID yet)
        self.kickoffOrResumeDownloadWithParams(params, resumeID: nil)
    }
    
    @IBAction func logoutClicked() {
        //
        // if user logs out, cancel our job
        self.resumableJob?.cancel()

        // remove any resumeIDs
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: "resumeID")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        // remove user's credential from keychain since they explicitly logged out
        self.keychainWrapper.reset()

        // clear out portal
        self.portal = nil
        
        // reset the map view
        self.mapView.reset()
        
        // hide map view
        self.mapView.hidden = true
        
        // re-prompt for login
        self.setupAndDisplayLogin()
    }
}
