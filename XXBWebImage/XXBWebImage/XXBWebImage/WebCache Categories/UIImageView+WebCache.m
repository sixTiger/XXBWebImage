//
//  UIImageView+WebCache.m
//  XXBWebImage
//
//  Created by baidu on 17/1/19.
//  Copyright © 2017年 com.xiaoxiaobing. All rights reserved.
//

#import "UIImageView+WebCache.h"

#if XXB_UIKIT || XXB_MAC
#import "objc/runtime.h"
#import "UIView+WebCacheOperation.h"
#import "UIView+WebCache.h"

@implementation UIImageView (WebCache)

- (void)xxb_setImageWithURL:(nullable NSURL *)url {
    [self xxb_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)xxb_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder {
    [self xxb_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)xxb_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(XXBWebImageOptions)options {
    [self xxb_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)xxb_setImageWithURL:(nullable NSURL *)url completed:(nullable XXBExternalCompletionBlock)completedBlock {
    [self xxb_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)xxb_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder completed:(nullable XXBExternalCompletionBlock)completedBlock {
    [self xxb_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)xxb_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(XXBWebImageOptions)options completed:(nullable XXBExternalCompletionBlock)completedBlock {
    [self xxb_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)xxb_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(XXBWebImageOptions)options
                  progress:(nullable XXBWebImageDownloaderProgressBlock)progressBlock
                 completed:(nullable XXBExternalCompletionBlock)completedBlock {
    [self xxb_internalSetImageWithURL:url
                    placeholderImage:placeholder
                             options:options
                        operationKey:nil
                       setImageBlock:nil
                            progress:progressBlock
                           completed:completedBlock];
}

- (void)xxb_setImageWithPreviousCachedImageWithURL:(nullable NSURL *)url
                                 placeholderImage:(nullable UIImage *)placeholder
                                          options:(XXBWebImageOptions)options
                                         progress:(nullable XXBWebImageDownloaderProgressBlock)progressBlock
                                        completed:(nullable XXBExternalCompletionBlock)completedBlock {
    NSString *key = [[XXBWebImageManager sharedManager] cacheKeyForURL:url];
    UIImage *lastPreviousCachedImage = [[XXBImageCache sharedImageCache] imageFromCacheForKey:key];
    
    [self xxb_setImageWithURL:url placeholderImage:lastPreviousCachedImage ?: placeholder options:options progress:progressBlock completed:completedBlock];
}

#if XXB_UIKIT

#pragma mark - Animation of multiple images

- (void)xxb_setAnimationImagesWithURLs:(nonnull NSArray<NSURL *> *)arrayOfURLs {
    [self xxb_cancelCurrentAnimationImagesLoad];
    __weak __typeof(self)wself = self;
    
    NSMutableArray<id<XXBWebImageOperation>> *operationsArray = [[NSMutableArray alloc] init];
    
    for (NSURL *logoImageURL in arrayOfURLs) {
        id <XXBWebImageOperation> operation = [XXBWebImageManager.sharedManager loadImageWithURL:logoImageURL options:0 progress:nil completed:^(UIImage *image, NSData *data, NSError *error, XXBImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (!wself) return;
            dispatch_main_async_safe(^{
                __strong UIImageView *sself = wself;
                [sself stopAnimating];
                if (sself && image) {
                    NSMutableArray<UIImage *> *currentImages = [[sself animationImages] mutableCopy];
                    if (!currentImages) {
                        currentImages = [[NSMutableArray alloc] init];
                    }
                    [currentImages addObject:image];
                    
                    sself.animationImages = currentImages;
                    [sself setNeedsLayout];
                }
                [sself startAnimating];
            });
        }];
        [operationsArray addObject:operation];
    }
    
    [self xxb_setImageLoadOperation:[operationsArray copy] forKey:@"UIImageViewAnimationImages"];
}

- (void)xxb_cancelCurrentAnimationImagesLoad {
    [self xxb_cancelImageLoadOperationWithKey:@"UIImageViewAnimationImages"];
}
#endif

@end

#endif
