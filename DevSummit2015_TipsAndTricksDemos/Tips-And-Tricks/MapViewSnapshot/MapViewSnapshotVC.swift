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
import Photos
import Social

class MapViewSnapshotVC: UIViewController {

    @IBOutlet var mapView: AGSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let mapUrl = NSURL(string: "http://services.arcgisonline.com/arcgis/rest/services/World_Imagery/MapServer")
        let tiledLyr = AGSTiledMapServiceLayer(URL: mapUrl);

        self.mapView.addMapLayer(tiledLyr, withName:"Tiled Layer")
        
        self.mapView.zoomToGeometry(AGSGeometryEngine.defaultGeometryEngine().projectGeometry(AGSPoint(fromDecimalDegreesString: "36.0156 N, 114.7378 W", withSpatialReference: AGSSpatialReference.wgs84SpatialReference()), toSpatialReference: AGSSpatialReference.webMercatorSpatialReference()), withPadding: 0, animated: true);
        
    }

    @IBAction func takeSnapshot(sender: AnyObject) {

        
        var snapshot:UIImage = self.snapShot()

        //If user is logged into Twitter on the device, display the image in a tweet sheet
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            let tweetSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            tweetSheet.setInitialText("Can you guess what this is?")
            tweetSheet.addImage(snapshot)
            self.presentViewController(tweetSheet, animated: true, completion: nil)
        }
        
        
        
        
        //need to request authorization for accessing the photo library first
        //If the user has already granted or denied access, this will call
        //the completion handler immediately
        self.saveToPhotos(snapshot)
    }
    
    func snapShot() -> UIImage
    {
        var scale : CGFloat = self.view.window!.screen.scale
        UIGraphicsBeginImageContextWithOptions(self.mapView.bounds.size, false, scale)
        
        self.view.drawViewHierarchyInRect(self.mapView.bounds, afterScreenUpdates: false)
        
        var snapShotImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return snapShotImage
    }
    
    
    func saveToPhotos(snapshot:UIImage){
        PHPhotoLibrary.requestAuthorization { (status) -> Void in
            
            //Make sure the user authorized us to make changes
            if status == .Authorized {
                
                PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                    
                    let changeRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(snapshot)
                    
                    }, completionHandler: { success, error in
                        NSLog("Finished adding asset. %@", (success ? "Success" : error))
                })
            }
        }

    }

    // MARK: - Navigation
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
