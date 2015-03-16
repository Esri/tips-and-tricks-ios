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

class RequestOpVC: UIViewController {
    
    @IBOutlet weak var progressView:UIProgressView!
    @IBOutlet weak var progressLabel:UILabel!
    @IBOutlet weak var bytesLabel:UILabel!
    
    var _opQueue: NSOperationQueue!
    
    @IBAction func startDownload(sender:AnyObject){
        
        
        // find our documents directory for this application
        let documentsDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        
        // create operation
        let op = AGSRequestOperation(URL: NSURL(string: "http://mirror.internode.on.net/pub/test/1meg.test"))
        
        // specify an output path so the data is written to a file
        
        op.outputPath = String(format:"%@/test.download", documentsDir)
        
        // remove existing version of file
        if NSFileManager.defaultManager().fileExistsAtPath(op.outputPath) {
            NSFileManager.defaultManager().removeItemAtPath(op.outputPath, error: nil)
        }
        
        // just log the completion
        op.completionBlock =  { obj in
            println("Download file to \(op.outputPath)")
        }
        
        // log the error
        op.errorHandler = { error in
            println("uh oh! error:\(error)")
        }

        // update the UI when progress is updated.
        // note, bytesE can be -1 when a contentLength is not set by the server
        op.progressHandler = { (bytesD:Int64, bytesE:Int64) in
            let pct =  Double(bytesD) / Double(bytesE)
            self.progressLabel.text = String(format:"%.2f%%", 100*pct)
            self.bytesLabel.text = String(format:"%lld/%lld", bytesD, bytesE)
            self.progressView.progress = Float(pct);
        }
        
        // add the operation to queue to be started
        AGSRequestOperation.sharedOperationQueue().addOperation(op)
    }
}