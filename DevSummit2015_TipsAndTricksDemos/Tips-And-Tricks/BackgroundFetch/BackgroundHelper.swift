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

class BackgroundHelper {
   
    class func checkJobStatusInBackground(completionHandler:(UIBackgroundFetchResult) -> Void) {
        if AGSTask.activeResumeIDs().count > 0  {
            //
            // this allow AGSExportTileCacheTask to trigger status checks for any active jobs. If a job is done
            // and a download is available, a download will be kicked off
            AGSTask.checkStatusForAllResumableTaskJobsWithCompletion(completionHandler)
        }
        else {
            //
            // we should call this right away so the OS sees us as a good citizen.
            completionHandler(UIBackgroundFetchResult.NoData)
        }
    }
    
    class func downloadJobResultInBackgroundWithURLSession(identifier:String, completionHandler:() -> ()) {
        //
        // this will allow the AGSGDBSyncTask to monitor status of background download and invoke its own
        // completion block when the download is done.
        AGSURLSessionManager.sharedManager().setBackgroundURLSessionCompletionHandler(completionHandler, forIdentifier: identifier)
    }
    
    class func postLocalNotificationIfAppNotActive(message:String) {
        //Only post notification if app not active
        var state = UIApplication.sharedApplication().applicationState
        
        if state != .Active
        {
            var localNotification = UILocalNotification()
            localNotification.alertBody = message
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        }
    }
}
