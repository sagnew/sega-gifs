import UIKit
import UserNotifications

import Alamofire
import SwiftyJSON
import PromiseKit

class NotificationManager: NSObject {
    
    static let sharedInstance = NotificationManager()
    
    let notificationIdentifier = "myNotification"
    
    func createNotification() {
        let giphy = GiphyManager()
        
        giphy.fetchRandomGifUrl(forSearchQuery: "SEGA Genesis").then { imageUrlString in
            NotificationManager.sharedInstance.handleAttachmentImage(forImageUrl: imageUrlString)
        }.then { attachmentUrl in
            NotificationManager.sharedInstance.scheduleNotification(inSeconds: 5, attachmentUrl: attachmentUrl) { success in
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
        
        notificationContent.title = "SEGA does what Ninten-DON'T"
        notificationContent.subtitle = "Blast Processing!"
        notificationContent.body = "Did you know the SEGA Genesis' Yamaha YM2612 sound chip had six FM channels?"
        
        notificationContent.attachments = [attachment]
        
        // Add a category
        notificationContent.categoryIdentifier = "moreNotificationsOptions"
        
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
