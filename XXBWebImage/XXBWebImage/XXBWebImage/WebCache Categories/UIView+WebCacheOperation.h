//
//  UIView+WebCacheOperation.h
//  XXBWebImage
//
//  Created by baidu on 17/1/19.
//  Copyright © 2017年 com.xiaoxiaobing. All rights reserved.
//

#import "XXBWebImageCompat.h"

#if XXB_UIKIT || XXB_MAC

#import "XXBWebImageManager.h"

@interface UIView (WebCacheOperation)

/**
 *  Set the image load operation (storage in a UIView based dictionary)
 *
 *  @param operation the operation
 *  @param key       key for storing the operation
 */
- (void)xxb_setImageLoadOperation:(nullable id)operation forKey:(nullable NSString *)key;

/**
 *  Cancel all operations for the current UIView and key
 *
 *  @param key key for identifying the operations
 */
- (void)xxb_cancelImageLoadOperationWithKey:(nullable NSString *)key;

/**
 *  Just remove the operations corresponding to the current UIView and key without cancelling them
 *
 *  @param key key for identifying the operations
 */
- (void)xxb_removeImageLoadOperationWithKey:(nullable NSString *)key;

@end

#endif

