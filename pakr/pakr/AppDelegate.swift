//
//  AppDelegate.swift
//  pakr
//
//  Created by Huynh Quang Thao on 4/5/16.
//  Copyright © 2016 Pakr. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Google
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var authenService: AuthService!
    var currentUser: User!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject:AnyObject]?) -> Bool {
        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window = window
        
        setUpParse()
        configureAWS()
        
        authenService = WebServiceFactory.getAuthService()
        
       if authenService.isLogin() {
            let rootViewController = PakrTabBarController()
            window.rootViewController = rootViewController
        } else {
            let rootViewController = LoginController(nibName: "LoginController", bundle: nil)
            window.rootViewController = rootViewController
        }
        
        window.makeKeyAndVisible()
        return true
    }
   
    func setUpParse() {
        User.registerSubclass()
        let config = ParseClientConfiguration(block: {
            (ParseMutableClientConfiguration) -> Void in
            ParseMutableClientConfiguration.applicationId = Constants.Parse.APP_ID
            ParseMutableClientConfiguration.clientKey = Constants.Parse.MASTER_KEY
            ParseMutableClientConfiguration.server = Constants.Parse.HOST
        });
        
        Parse.initializeWithConfiguration(config);
    }
    
    func configureAWS() {
        let credentialsProvider = AWSCognitoCredentialsProvider(
                regionType: Constants.AWS.CognitoRegionType,
                identityPoolId: Constants.AWS.CognitoIdentityPoolId)
        
        let configuration = AWSServiceConfiguration(
                region: Constants.AWS.DefaultServiceRegionType,
                credentialsProvider: credentialsProvider)
        
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
    }
    
    @available(iOS 9.0, *)
    func application(application: UIApplication, openURL url: NSURL, options: [String: AnyObject]) -> Bool {
        print("step 2 of OAuth2. Url: \(url)")
        
        // url from google
        if GoogleAuth.isValidatedWithUrl(url) {
            return GIDSignIn.sharedInstance().handleURL(
                    url,
                    sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String,
                    annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
        }
        // url from facebook
         else if FacebookAuth.isValidatedWithUrl(url) {
             return FBSDKApplicationDelegate.sharedInstance().application(application,
                    openURL: url,
                    sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as! String,
                    annotation: options [UIApplicationOpenURLOptionsAnnotationKey])
        }
        // application hasn't supported this url yet
        else {
              return false
        }
    }
    
    // from ios 9. this method isn't called anymore. must be called manually from above method
    @available(iOS, introduced=8.0, deprecated=9.0)
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if FacebookAuth.isValidatedWithUrl(url) {
            print("AppDelegate. FacebookURL: \(url)")
            return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        }
        return false
    }
}

