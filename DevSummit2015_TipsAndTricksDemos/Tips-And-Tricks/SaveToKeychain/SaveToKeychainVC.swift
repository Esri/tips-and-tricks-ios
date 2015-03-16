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

class SaveToKeychainVC: UIViewController, AGSPortalDelegate {

    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var portalTextField: UILabel!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var logoutButton: UIButton!
    
    var portal:AGSPortal?
    var oAuthVC: AGSOAuthLoginViewController!
    var loginNavVC: OAuthLoginNavVC!
    var portalURL: NSURL!

    let keychainIdentifier = "com.esri.devsummit2015.tipsAndTricks"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set portal url
        self.portalURL = NSURL(string: "https://www.arcgis.com")

        let keychainItem = AGSKeychainItemWrapper(identifier: keychainIdentifier, accessGroup: nil)
        if let cred = keychainItem.keychainObject() as? AGSCredential {
            self.loadPortalWithCredential(cred)
        }
        
        // Do any additional setup after loading the view.
        self.updateControls()
    }
    
    // MARK: - Portal

    func portalDidLoad(portal: AGSPortal!) {
        //portal loaded, save credential to keychain
        let keychainItem = AGSKeychainItemWrapper(identifier: keychainIdentifier, accessGroup: nil)
        keychainItem.setKeychainObject(portal.credential)
        
        self.updateControls()
    }
    
    func portal(portal: AGSPortal!, didFailToLoadWithError error: NSError!) {
        println("portal failed to load!" + error.localizedDescription)
        self.updateControls()
    }
    
    func loadPortalWithCredential(credential: AGSCredential) {
        self.portal = AGSPortal(URL: self.portalURL, credential: credential)
        self.portal!.delegate = self
    }
    
    // MARK: - OAuth

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
        
        // present Login VC to user
        self.presentViewController(self.loginNavVC, animated: true, completion: nil)
    }
    
    func cancelLogin() {
        self.loginNavVC.dismissViewControllerAnimated(true, completion: nil)
        self.updateControls()
    }

    func clientID() -> String! {
        //TODO: Insert client id
        return "<insert_your_clientid_here>"
    }
    
    // MARK: - internal

    func updateControls() {
        var enabled = false
        var loggedInString = "Not logged in"
        var portalString = "No Portal"
        if let cred = self.portal?.credential {
            if (self.portal?.portalInfo != nil) {
                enabled = true
                loggedInString = "Logged in as: " + cred.username
                if let portal = self.portal {
                    portalString = "Portal: " + portal.portalInfo.portalName
                }
            }
        }
        self.statusLabel.text = loggedInString
        self.portalTextField.text = portalString

        self.loginButton.enabled = self.portal == nil
        self.logoutButton.enabled = self.portal != nil
    }
    
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        self.setupAndDisplayLogin()
    }
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        let keychainItem = AGSKeychainItemWrapper(identifier: keychainIdentifier, accessGroup: nil)
        keychainItem.reset()
        
        self.portal = nil
        
        self.updateControls()
    }

}
