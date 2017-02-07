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
import AlamofireImage
import SwiftyJSON

class ViewController: UIViewController {

    let notificationIdentifier = "myNotification"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchNotificationGIF()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func notificationButtonTapped(_ sender: Any) {
        self.fetchNotificationGIF()
    }
    
    func fetchNotificationGIF() {
        
        print("YO")
        let imageLimit:UInt32 = 50
        
        Alamofire.request("https://api.giphy.com/v1/gifs/search", parameters: ["api_key": "dc6zaTOxFJmzC", "q": "beer", "limit": "\(imageLimit)"])
            .responseJSON { response in
                if let result = response.result.value {
                    let json = JSON(result)
                    let randomNum:Int = Int(arc4random_uniform(imageLimit))
                    
                    if let imageURLString = json["data"][randomNum]["images"]["downsized"]["url"].string {
                        print(imageURLString)
                        self.handleAttachmentImage(forImageURL: imageURLString)
                    }
                    
                }
        }
    }
    
    func handleAttachmentImage(forImageURL imageURLString: String) {
        Alamofire.request(imageURLString).responseData { response in
            if let data = response.result.value {
                print("image downloaded: \(data)")
                
                let fm = FileManager.default
                let docsurl = try! fm.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let fileURL = docsurl.appendingPathComponent("img.gif")
                
                // try! UIImageJPEGRepresentation(image, 1.0)?.write(to: fileURL)
                try! data.write(to: fileURL)
                self.scheduleNotification(inSeconds: 5, attachmentURL: fileURL, completion: { success in
                    if success {
                        print("Successfully scheduled notification")
                    } else {
                        print("Error scheduling notification")
                    }
                })
            }
        }
    }
    
    func scheduleNotification(inSeconds: TimeInterval, attachmentURL: URL, completion: @escaping (Bool) -> ()) {
        
        // Create an attachment for the notification
        var attachment: UNNotificationAttachment
        
        attachment = try! UNNotificationAttachment(identifier: notificationIdentifier, url: attachmentURL, options: .none)
        
        // Create Notification content
        let notificationContent = UNMutableNotificationContent()
        
        notificationContent.title = "Check this out"
        notificationContent.subtitle = "It's a notification"
        notificationContent.body = "WHOA COOL"
        
        notificationContent.attachments = [attachment]
        
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

