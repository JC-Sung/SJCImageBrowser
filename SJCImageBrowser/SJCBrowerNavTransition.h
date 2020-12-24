//
//  SJCBrowerNavTransition.h
//  Yehwang
//
//  Created by Yehwang on 2020/11/3.
//  Copyright © 2020 Yehwang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    HXPhotoViewTransitionTypePush = 0,
    HXPhotoViewTransitionTypePop = 1,
} HXPhotoViewTransitionType;

@interface SJCBrowerNavTransition : NSObject<UIViewControllerAnimatedTransitioning>
+ (instancetype)transitionWithType:(HXPhotoViewTransitionType)type;
- (instancetype)initWithTransitionType:(HXPhotoViewTransitionType)type;
@end

