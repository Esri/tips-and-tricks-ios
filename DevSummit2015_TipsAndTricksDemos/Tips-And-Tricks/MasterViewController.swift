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

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    
    //tuples of (title, VC)
    var objects = [("1.Coordinate Conversion", "CoordinateConversionViewController"),
        ("2.Geodesic Operations", "GeodesicOpsVC"),
        ("3a.Simulate Location GPX", "SimulatedLocationVC"),
        ("3b.Simulate Location Route", "RoutePolylineVC"),
        ("4.Override GPS Symbol", "OverrideGPSVC"),
        ("5.Custom Dynamic Layer", "CustomDynamicLayerVC"),
        ("6.Web Tiled Layers", "WebTiledLayerVC"),
        ("7.Custom Map Background", "CustomGridColorVC"),
        ("8.Prefetch Tiles", "PrefetchTilesVC"),
        ("9.Set Max Envelope", "SetMaxEnvVC"),
        ("10.Zoom Beyond Basemap", "ZoomBeyondVC"),
        ("11.Map View Snapshot", "MapViewSnapshotVC"),
        ("12.Request Op - Download File", "RequestOpVC"),
        ("13.Request Op - Web Service", "RequestOpWebServiceVC"),
        ("14.Resume Jobs", "ResumeDownloadVC"),
        ("15.Background Fetch", "BackgroundFetchVC"),
        ("16.GL Rendering Modes", "GLRenderModesVC"),
        ("17.Graphic Offset and Leader Point", "SymbolAlignmentVC"),
        ("18.Custom Callout", "CustomCalloutVC"),
        ("19.Save To Keychain", "SaveToKeychainVC"),
        ("20.KVO", "KVOVC")]
    
    let appName = "tips_and_tricks_ios"


    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let (title, vcName) = objects[indexPath.row]
                let controller = (segue.destinationViewController as UINavigationController).topViewController as DetailViewController
                
                // this will get the name of the VC to instantiate and then create it and push onto the navigation stack
                var className = self.appName + "." + vcName
                let c = NSClassFromString(className) as UIViewController.Type
                let object = c(nibName: vcName, bundle: nil) as UIViewController
                
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
                controller.navigationItem.title = title
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        let (title, VC) = objects[indexPath.row]
        cell.textLabel!.text = title
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

//    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if editingStyle == .Delete {
//            objects.removeObjectAtIndex(indexPath.row)
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//        } else if editingStyle == .Insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//        }
//    }


}

