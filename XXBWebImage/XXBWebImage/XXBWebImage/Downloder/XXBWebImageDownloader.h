//
//  XXBWebImageDownloder.h
//  XXBWebImage
//
//  Created by baidu on 17/1/19.
//  Copyright © 2017年 com.xiaoxiaobing. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XXBWebImageCompat.h"
#import "XXBWebImageOperation.h"

typedef NS_OPTIONS(NSUInteger, XXBWebImageDownloaderOptions) {
    XXBWebImageDownloaderLowPriority = 1 << 0,
    XXBWebImageDownloaderProgressiveDownload = 1 << 1,
    
    /**
     * By default, request prevent the use of NSURLCache. With this flag, NSURLCache
     * is used with default policies.
     */
    XXBWebImageDownloaderUseNSURLCache = 1 << 2,
    
    /**
     * Call completion block with nil image/imageData if the image was read from NSURLCache
     * (to be combined with `XXBWebImageDownloaderUseNSURLCache`).
     */
    
    XXBWebImageDownloaderIgnoreCachedResponse = 1 << 3,
    /**
     * In iOS 4+, continue the download of the image if the app goes to background. This is achieved by asking the system for
     * extra time in background to let the request finish. If the background task expires the operation will be cancelled.
     */
    
    XXBWebImageDownloaderContinueInBackground = 1 << 4,
    
    /**
     * Handles cookies stored in NSHTTPCookieStore by setting
     * NSMutableURLRequest.HTTPShouldHandleCookies = YES;
     */
    XXBWebImageDownloaderHandleCookies = 1 << 5,
    
    /**
     * Enable to allow untrusted SSL certificates.
     * Useful for testing purposes. Use with caution in production.
     */
    XXBWebImageDownloaderAllowInvalidSSLCertificates = 1 << 6,
    
    /**
     * Put the image in the high priority queue.
     */
    XXBWebImageDownloaderHighPriority = 1 << 7,
    
    /**
     * Scale down the image
     */
    XXBWebImageDownloaderScaleDownLargeImages = 1 << 8,
};

typedef NS_ENUM(NSInteger, XXBWebImageDownloaderExecutionOrder) {
    /**
     * Default value. All download operations will execute in queue style (first-in-first-out).
     */
    XXBWebImageDownloaderFIFOExecutionOrder,
    
    /**
     * All download operations will execute in stack style (last-in-first-out).
     */
    XXBWebImageDownloaderLIFOExecutionOrder
};

extern NSString * _Nonnull const XXBWebImageDownloadStartNotification;
extern NSString * _Nonnull const XXBWebImageDownloadStopNotification;

typedef void(^XXBWebImageDownloaderProgressBlock)(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL);

typedef void(^XXBWebImageDownloaderCompletedBlock)(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished);

typedef NSDictionary<NSString *, NSString *> XXBHTTPHeaderXXBictionary;
typedef NSMutableDictionary<NSString *, NSString *> XXBHTTPHeadersMutableDictionary;

typedef XXBHTTPHeaderXXBictionary * _Nullable (^XXBWebImageDownloaderHeadersFilterBlock)(NSURL * _Nullable url, XXBHTTPHeaderXXBictionary * _Nullable headers);

@interface XXBWebImageDownloader : NSObject

@end
