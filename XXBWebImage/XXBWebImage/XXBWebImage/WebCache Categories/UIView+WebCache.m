//
//  UIView+webCache.m
//  XXBWebImage
//
//  Created by baidu on 17/1/19.
//  Copyright © 2017年 com.xiaoxiaobing. All rights reserved.
//

#import "UIView+WebCache.h"

#if XXB_UIKIT || XXB_MAC

#import "objc/runtime.h"
#import "UIView+WebCacheOperation.h"

static char imageURLKey;

#if XXB_UIKIT
static char TAG_ACTIVITY_INDICATOR;
static char TAG_ACTIVITY_STYLE;
#endif
static char TAG_ACTIVITY_SHOW;


@implementation UIView(WebCache)
- (nullable NSURL *)xxb_imageURL {
    return objc_getAssociatedObject(self, &imageURLKey);
}

- (void)xxb_internalSetImageWithURL:(nullable NSURL *)url
                  placeholderImage:(nullable UIImage *)placeholder
                           options:(XXBWebImageOptions)options
                      operationKey:(nullable NSString *)operationKey
                     setImageBlock:(nullable XXBSetImageBlock)setImageBlock
                          progress:(nullable XXBWebImageDownloaderProgressBlock)progressBlock
                         completed:(nullable XXBExternalCompletionBlock)completedBlock {
    NSString *validOperationKey = operationKey ?: NSStringFromClass([self class]);
    [self xxb_cancelImageLoadOperationWithKey:validOperationKey];
    objc_setAssociatedObject(self, &imageURLKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (!(options & XXBWebImageDelayPlaceholder)) {
        dispatch_main_async_safe(^{
            [self xxb_setImage:placeholder imageData:nil basedOnClassOrViaCustomSetImageBlock:setImageBlock];
        });
    }
    
    if (url) {
        // check if activityView is enabled or not
        if ([self xxb_showActivityIndicatorView]) {
            [self xxb_addActivityIndicator];
        }
        
        __weak __typeof(self)wself = self;
        id <XXBWebImageOperation> operation = [XXBWebImageManager.sharedManager loadImageWithURL:url options:options progress:progressBlock completed:^(UIImage *image, NSData *data, NSError *error, XXBImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            __strong __typeof (wself) sself = wself;
            [sself xxb_removeActivityIndicator];
            if (!sself) {
                return;
            }
            dispatch_main_async_safe(^{
                if (!sself) {
                    return;
                }
                if (image && (options & XXBWebImageAvoidAutoSetImage) && completedBlock) {
                    completedBlock(image, error, cacheType, url);
                    return;
                } else if (image) {
                    [sself xxb_setImage:image imageData:data basedOnClassOrViaCustomSetImageBlock:setImageBlock];
                    [sself xxb_setNeedsLayout];
                } else {
                    if ((options & XXBWebImageDelayPlaceholder)) {
                        [sself xxb_setImage:placeholder imageData:nil basedOnClassOrViaCustomSetImageBlock:setImageBlock];
                        [sself xxb_setNeedsLayout];
                    }
                }
                if (completedBlock && finished) {
                    completedBlock(image, error, cacheType, url);
                }
            });
        }];
        [self xxb_setImageLoadOperation:operation forKey:validOperationKey];
    } else {
        dispatch_main_async_safe(^{
            [self xxb_removeActivityIndicator];
            if (completedBlock) {
                NSError *error = [NSError errorWithDomain:XXBWebImageErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
                completedBlock(nil, error, XXBImageCacheTypeNone, url);
            }
        });
    }
}

- (void)xxb_cancelCurrentImageLoad {
    [self xxb_cancelImageLoadOperationWithKey:NSStringFromClass([self class])];
}

- (void)xxb_setImage:(UIImage *)image imageData:(NSData *)imageData basedOnClassOrViaCustomSetImageBlock:(XXBSetImageBlock)setImageBlock {
    if (setImageBlock) {
        setImageBlock(image, imageData);
        return;
    }
    
#if XXB_UIKIT || XXB_MAC
    if ([self isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)self;
        imageView.image = image;
    }
#endif
    
#if XXB_UIKIT
    if ([self isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)self;
        [button setImage:image forState:UIControlStateNormal];
    }
#endif
}

- (void)xxb_setNeedsLayout {
#if XXB_UIKIT
    [self setNeedsLayout];
#elif XXB_MAC
    [self setNeedsLayout:YES];
#endif
}

#pragma mark - Activity indicator

#pragma mark -
#if XXB_UIKIT
- (UIActivityIndicatorView *)activityIndicator {
    return (UIActivityIndicatorView *)objc_getAssociatedObject(self, &TAG_ACTIVITY_INDICATOR);
}

- (void)setActivityIndicator:(UIActivityIndicatorView *)activityIndicator {
    objc_setAssociatedObject(self, &TAG_ACTIVITY_INDICATOR, activityIndicator, OBJC_ASSOCIATION_RETAIN);
}
#endif

- (void)xxb_setShowActivityIndicatorView:(BOOL)show {
    objc_setAssociatedObject(self, &TAG_ACTIVITY_SHOW, @(show), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)xxb_showActivityIndicatorView {
    return [objc_getAssociatedObject(self, &TAG_ACTIVITY_SHOW) boolValue];
}

#if XXB_UIKIT
- (void)xxb_setIndicatorStyle:(UIActivityIndicatorViewStyle)style{
    objc_setAssociatedObject(self, &TAG_ACTIVITY_STYLE, [NSNumber numberWithInt:style], OBJC_ASSOCIATION_RETAIN);
}

- (int)xxb_getIndicatorStyle{
    return [objc_getAssociatedObject(self, &TAG_ACTIVITY_STYLE) intValue];
}
#endif

- (void)xxb_addActivityIndicator {
#if XXB_UIKIT
    if (!self.activityIndicator) {
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:[self xxb_getIndicatorStyle]];
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        
        dispatch_main_async_safe(^{
            [self addSubview:self.activityIndicator];
            
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeCenterX
                                                            multiplier:1.0
                                                              constant:0.0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                             attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeCenterY
                                                            multiplier:1.0
                                                              constant:0.0]];
        });
    }
    
    dispatch_main_async_safe(^{
        [self.activityIndicator startAnimating];
    });
#endif
}

- (void)xxb_removeActivityIndicator {
#if XXB_UIKIT
    if (self.activityIndicator) {
        [self.activityIndicator removeFromSuperview];
        self.activityIndicator = nil;
    }
#endif
}

@end

#endif

