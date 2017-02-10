//
//  ViewController.swift
//  PlayingWithUserNotifications
//
//  Created by Sam Agnew on 2/6/17.
//  Copyright © 2017 Sam Agnew. All rights reserved.
//

import UIKit
import UserNotifications
import Alamofire
import SwiftyJSON
import PromiseKit

class ViewController: UIViewController {

    let notificationIdentifier = "myNotification"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func notificationButtonTapped(_ sender: Any) {
        let giphy = GiphyManager()
        
        giphy.fetchRandomGifUrl(forSearchQuery: "beer").then { imageUrlString in
                self.handleAttachmentImage(forImageUrl: imageUrlString)
            }.then { attachmentUrl in
                self.scheduleNotification(inSeconds: 5, attachmentUrl: attachmentUrl) { success in
                    print(success)
                }
            }.catch { error in
                print(error)
            }
    }
    
    func handleAttachmentImage(forImageUrl imageUrlString: String) -> Promise<URL> {
        return Promise { fulfill, reject in
            Alamofire.request(imageUrlString).responseData { response in
                if let data = response.result.value {
                    print("image downloaded: \(data)")
                    
                    let fm = FileManager.default
                    let docsUrl = try! fm.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                    let fileUrl = docsUrl.appendingPathComponent("img.gif")
                    
                    do {
                        try data.write(to: fileUrl)
                        fulfill(fileUrl)
                    } catch {
                        reject(error)
                    }
                    
                }
            }
        }
    }
    
    func scheduleNotification(inSeconds: TimeInterval, attachmentUrl: URL, completion: @escaping (Bool) -> ()) {
        
        // Create an attachment for the notification
        var attachment: UNNotificationAttachment
        
        attachment = try! UNNotificationAttachment(identifier: notificationIdentifier, url: attachmentUrl, options: .none)
        
        // Create Notification content
        let notificationContent = UNMutableNotificationContent()
        
        notificationContent.title = "I hope you're having a rad time!"
        notificationContent.subtitle = "Be responsible and don't drive :)"
        notificationContent.body = "Are you still drinking and want more beer GIFs?"
        
        notificationContent.attachments = [attachment]
        
        // Add a category
        notificationContent.categoryIdentifier = "stillDrinkingOptions"
        
        // Create Notification trigger
        // Note that 60 seconds is the smallest repeating interval.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: inSeconds, repeats: false)
        
        // Create a notification request with the above components
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: notificationContent, trigger: trigger)
        
        // Add this notification to the UserNotificationCenter
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            if error != nil {
                print("\(error)")
                completion(false)
            } else {
                completion(true)
            }
        })
    }

}

