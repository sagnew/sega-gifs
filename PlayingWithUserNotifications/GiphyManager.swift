//
//  GiphyManager.swift
//  PlayingWithUserNotifications
//
//  Created by Sam Agnew on 2/7/17.
//  Copyright © 2017 Sam Agnew. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class GiphyManager: NSObject {
    
    let giphyBaseURL = "https://api.giphy.com/v1/gifs/search"
    let apiKey: String
    let imageLimit: UInt32
    
    override init() {
        self.apiKey = "dc6zaTOxFJmzC"
        self.imageLimit = 50
        super.init()
    }
    
    init(apiKey: String, imageLimit: UInt32) {
        self.apiKey = apiKey
        self.imageLimit = imageLimit
        super.init()
    }
    
    func fetchRandomGifUrl(forSearchQuery query: String, completionHandler: @escaping (_ forImageUrl: String) -> Void) {
        
        Alamofire.request(self.giphyBaseURL, parameters: ["api_key": self.apiKey, "q": query, "limit": "\(self.imageLimit)"])
            .responseJSON { response in
                if let result = response.result.value {
                    let json = JSON(result)
                    let randomNum:Int = Int(arc4random_uniform(self.imageLimit))
                    
                    if let imageUrlString = json["data"][randomNum]["images"]["downsized"]["url"].string {
                        print(imageUrlString)
                        completionHandler(imageUrlString)
                    }
                    
                }
        }
    }
}
