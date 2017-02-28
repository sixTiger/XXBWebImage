//
//  UIView+webCache.h
//  XXBWebImage
//
//  Created by baidu on 17/1/19.
//  Copyright © 2017年 com.xiaoxiaobing. All rights reserved.
//

#import "XXBWebImageCompat.h"
#if XXB_UIKIT || XXB_MAC

#import "XXBWebImageManager.h"

typedef void(^XXBSetImageBlock)(UIImage * _Nullable image, NSData * _Nullable imageData);

@interface UIView (WebCache)

/**
 * Get the current image URL.
 *
 * Note that because of the limitations of categories this property can get out of sync
 * if you use setImage: directly.
 */
- (nullable NSURL *)xxb_imageURL;

/**
 * Set the imageView `image` with an `url` and optionally a placeholder image.
 *
 * The download is asynchronous and cached.
 *
 * @param url            The url for the image.
 * @param placeholder    The image to be set initially, until the image request finishes.
 * @param options        The options to use when downloading the image. @see SDWebImageOptions for the possible values.
 * @param operationKey   A string to be used as the operation key. If nil, will use the class name
 * @param setImageBlock  Block used for custom set image code
 * @param progressBlock  A block called while image is downloading
 *                       @note the progress block is executed on a background queue
 * @param completedBlock A block called when operation has been completed. This block has no return value
 *                       and takes the requested UIImage as first parameter. In case of error the image parameter
 *                       is nil and the second parameter may contain an NSError. The third parameter is a Boolean
 *                       indicating if the image was retrieved from the local cache or from the network.
 *                       The fourth parameter is the original image url.
 */
- (void)xxb_internalSetImageWithURL:(nullable NSURL *)url
                  placeholderImage:(nullable UIImage *)placeholder
                           options:(XXBWebImageOptions)options
                      operationKey:(nullable NSString *)operationKey
                     setImageBlock:(nullable XXBSetImageBlock)setImageBlock
                          progress:(nullable XXBWebImageDownloaderProgressBlock)progressBlock
                         completed:(nullable XXBExternalCompletionBlock)completedBlock;

/**
 * Cancel the current download
 */
- (void)xxb_cancelCurrentImageLoad;

#if xxb_UIKIT

#pragma mark - Activity indicator

/**
 *  Show activity UIActivityIndicatorView
 */
- (void)xxb_setShowActivityIndicatorView:(BOOL)show;

/**
 *  set desired UIActivityIndicatorViewStyle
 *
 *  @param style The style of the UIActivityIndicatorView
 */
- (void)xxb_setIndicatorStyle:(UIActivityIndicatorViewStyle)style;

- (BOOL)xxb_showActivityIndicatorView;
- (void)xxb_addActivityIndicator;
- (void)xxb_removeActivityIndicator;

#endif

@end

#endif

