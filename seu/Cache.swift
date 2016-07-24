//
//  Cache.swift
//  WEME
//
//  Created by liewli on 1/25/16.
//  Copyright © 2016 li liew. All rights reserved.
//

import Foundation

let CARD_SETTING_KEY = "CARD_SETTING_KEY"
let PROFILE_CACHE_FILE = "profile_cache"
let ACTIVITY_CACHE_FILE = "activity_cache"
let ACTIVITY_BOARD_CACHE_FILE = "activity_board_cache"
let TOPIC_CACHE_FILE = "topic_cache"
let TOPIC_BOARD_CACHE_FILE = "topic_board_cache"


class ActivityBoardCache {
    private init() {}
    
    static let sharedCache = ActivityBoardCache()
    typealias completionBlock = [ActivityBoardModel]? -> Void
    
    func loadActivitiesWithCompletionBlock(block:completionBlock){
        dispatch_async(fileQueue) { () -> Void in
            let a = NSKeyedUnarchiver.unarchiveObjectWithFile(self.cacheFilePath()) as? [ActivityBoardModel]
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                block(a)
            })
        }
    }
    
    private lazy var fileQueue:dispatch_queue_t = {
        let q = dispatch_queue_create("weme.activityboard", DISPATCH_QUEUE_SERIAL)
        return q
    }()
    
    
    func saveActivities(activities:[ActivityBoardModel]?) {
        if let a = activities where a.count > 0 {
            dispatch_async(fileQueue) { () -> Void in
                let data = NSKeyedArchiver.archivedDataWithRootObject(a)
                data.writeToFile(self.cacheFilePath(), atomically: true)
            }
        }
    }
    
    private func cacheFilePath() -> String {
        let cacheDir = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0]
        return "\(cacheDir)/\(ACTIVITY_BOARD_CACHE_FILE)"
    }
    
}

class ActivityCache {
    private init() {}
    
    static let sharedCache = ActivityCache()
    typealias completionBlock = [ActivityModel]? -> Void
    
    func loadActivitiesWithCompletionBlock(block:completionBlock){
        dispatch_async(fileQueue) { () -> Void in
            let a = NSKeyedUnarchiver.unarchiveObjectWithFile(self.cacheFilePath()) as? [ActivityModel]
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                block(a)
            })
        }
    }
    
    private lazy var fileQueue:dispatch_queue_t = {
        let q = dispatch_queue_create("weme.activity", DISPATCH_QUEUE_SERIAL)
        return q
    }()
    
    
    func saveActivities(activities:[ActivityModel]?) {
        if let a = activities where a.count > 0 {
            dispatch_async(fileQueue) { () -> Void in
                let data = NSKeyedArchiver.archivedDataWithRootObject(a)
                data.writeToFile(self.cacheFilePath(), atomically: true)
            }
        }
    }
    
    private func cacheFilePath() -> String {
        let cacheDir = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0]
        return "\(cacheDir)/\(ACTIVITY_CACHE_FILE)"
    }

}

class ProfileCache {
    
    private init() {}
    
    static let sharedCache = ProfileCache()
    typealias completionBlock = PersonModel? -> Void
    
    func loadProfileWithCompletionBlock(block:completionBlock){
        dispatch_async(fileQueue) { () -> Void in
            let t = NSKeyedUnarchiver.unarchiveObjectWithFile(self.cacheFilePath()) as? PersonModel
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                block(t)
            })
        }
    }
    
    private lazy var fileQueue:dispatch_queue_t = {
        let q = dispatch_queue_create("weme.profile", DISPATCH_QUEUE_SERIAL)
        return q
    }()
    
    
    func saveProfile(profile: PersonModel?) {
        if let p = profile {
            dispatch_async(fileQueue) { () -> Void in
                let data = NSKeyedArchiver.archivedDataWithRootObject(p)
                data.writeToFile(self.cacheFilePath(), atomically: true)
            }
        }
    }
    
    private func cacheFilePath() -> String {
        let cacheDir = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0]
        return "\(cacheDir)/\(PROFILE_CACHE_FILE)"
    }
}

class TopicCache {
    private init() {}
    static let sharedCache = TopicCache()
    
    typealias completionBlock = [TopicModel]? -> Void
    
    func loadTopicsWithCompletionBlock(block:completionBlock) {
        
        dispatch_async(fileQueue) { () -> Void in
            let t = NSKeyedUnarchiver.unarchiveObjectWithFile(self.cacheFilePath()) as? [TopicModel]
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                block(t)
            })
        }
                
    }
    
    func saveTopics(topics:[TopicModel]?) {
        if let t = topics where t.count > 0 {
            dispatch_async(fileQueue) { () -> Void in
                let data = NSKeyedArchiver.archivedDataWithRootObject(t)
                data.writeToFile(self.cacheFilePath(), atomically: true)
            }
        }
    }
    
    func cacheFilePath() -> String {
        let cacheDir = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0]
        return "\(cacheDir)/\(TOPIC_CACHE_FILE)"
    }
    
    private lazy var fileQueue:dispatch_queue_t = {
        let q = dispatch_queue_create("weme.topic", DISPATCH_QUEUE_SERIAL)
        return q
    }()
}

class TopicBoardCache {
    private init() {}
    static let sharedCache = TopicBoardCache()
    
    typealias completionBlock = [TopicBoardModel]? -> Void
    
    func loadTopicsWithCompletionBlock(block : completionBlock){
        dispatch_async(fileQueue) { () -> Void in
            let t = NSKeyedUnarchiver.unarchiveObjectWithFile(self.cacheFilePath()) as? [TopicBoardModel]
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                block(t)
            })
            
        }
        
    }
    
    func saveTopics(topics:[TopicBoardModel]?) {
        if let t = topics where t.count > 0 {
            dispatch_async(fileQueue) { () -> Void in
                let data = NSKeyedArchiver.archivedDataWithRootObject(t)
                data.writeToFile(self.cacheFilePath(), atomically: true)
            }
        }
    }
    
    func cacheFilePath() -> String {
        let cacheDir = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0]
        return "\(cacheDir)/\(TOPIC_BOARD_CACHE_FILE)"
    }
    
    private lazy var fileQueue:dispatch_queue_t = {
        let q = dispatch_queue_create("weme.topicboard", DISPATCH_QUEUE_SERIAL)
        return q
    }()

}