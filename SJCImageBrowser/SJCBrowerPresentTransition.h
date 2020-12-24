//
//  SJCBrowerPresentTransition.h
//  Yehwang
//
//  Created by Yehwang on 2020/11/3.
//  Copyright © 2020 Yehwang. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum : NSUInteger {
    SJCBrowserPresentTransitionTypePresent = 0,
    SJCBrowserPresentTransitionTypeDismiss = 1,
} SJCBrowserPresentTransitionType;
@class HXPhotoView;
@interface SJCBrowerPresentTransition : NSObject<UIViewControllerAnimatedTransitioning>
+ (instancetype)transitionWithTransitionType:(SJCBrowserPresentTransitionType)type photoView:(HXPhotoView *)photoView;

- (instancetype)initWithTransitionType:(SJCBrowserPresentTransitionType)type photoView:(HXPhotoView *)photoView;
@end

