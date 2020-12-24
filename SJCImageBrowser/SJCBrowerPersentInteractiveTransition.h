//
//  SJCBrowerPersentInteractiveTransition.h
//  Yehwang
//
//  Created by Yehwang on 2020/11/3.
//  Copyright © 2020 Yehwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJCBrowerPersentInteractiveTransition : UIPercentDrivenInteractiveTransition
@property (nonatomic, assign) BOOL interation;
@property (assign, nonatomic) BOOL atFirstPan;
- (void)addPanGestureForViewController:(UIViewController *)viewController;
@end

