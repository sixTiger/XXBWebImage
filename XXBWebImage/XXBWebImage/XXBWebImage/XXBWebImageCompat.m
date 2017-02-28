//
//  XXBWebImageCompat.m
//  XXBWebImage
//
//  Created by baidu on 17/1/19.
//  Copyright © 2017年 com.xiaoxiaobing. All rights reserved.
//

#import "XXBWebImageCompat.h"

#if !__has_feature(objc_arc)
#error XXBWebImage is ARC only. Either turn on ARC for the project or use -fobjc-arc flag
#endif

inline UIImage *XXBScaledImageForKey(NSString * _Nullable key, UIImage * _Nullable image) {
    if (!image) {
        return nil;
    }
    
#if XXB_MAC
    return image;
#elif XXB_UIKIT || XXB_WATCH
    if ((image.images).count > 0) {
        NSMutableArray<UIImage *> *scaledImages = [NSMutableArray array];
        
        for (UIImage *tempImage in image.images) {
            [scaledImages addObject:XXBScaledImageForKey(key, tempImage)];
        }
        
        return [UIImage animatedImageWithImages:scaledImages duration:image.duration];
    }
    else {
#if XXB_WATCH
        if ([[WKInterfaceDevice currentDevice] respondsToSelector:@selector(screenScale)]) {
#elif XXB_UIKIT
            if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
#endif
                CGFloat scale = 1;
                if (key.length >= 8) {
                    NSRange range = [key rangeOfString:@"@2x."];
                    if (range.location != NSNotFound) {
                        scale = 2.0;
                    }
                    
                    range = [key rangeOfString:@"@3x."];
                    if (range.location != NSNotFound) {
                        scale = 3.0;
                    }
                }
                
                UIImage *scaledImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:scale orientation:image.imageOrientation];
                image = scaledImage;
            }
            return image;
        }
#endif
    }
    
    NSString *const XXBWebImageErrorDomain = @"XXBWebImageErrorDomain";
