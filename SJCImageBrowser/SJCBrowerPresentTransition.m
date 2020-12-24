//
//  SJCBrowerPresentTransition.m
//  Yehwang
//
//  Created by Yehwang on 2020/11/3.
//  Copyright © 2020 Yehwang. All rights reserved.
//

#import "SJCBrowerPresentTransition.h"

#import "HXPhotoSubViewCell.h"
#import "HXPhotoView.h"
#import "SJCImageBrowser.h"
#import "HXPhotoPreviewBottomView.h"
#import "HXPhotoEdit.h"

@interface SJCBrowerPresentTransition ()
@property (strong, nonatomic) HXPhotoView *photoView ;
@property (assign, nonatomic) SJCBrowserPresentTransitionType type;
@property (weak , nonatomic) UIImageView *tempView;
@end

@implementation SJCBrowerPresentTransition
+ (instancetype)transitionWithTransitionType:(SJCBrowserPresentTransitionType)type photoView:(HXPhotoView *)photoView {
    return [[self alloc] initWithTransitionType:type photoView:photoView];
}

- (instancetype)initWithTransitionType:(SJCBrowserPresentTransitionType)type photoView:(HXPhotoView *)photoView {
    self = [super init];
    if (self) {
        self.type = type;
        self.photoView = photoView;
    }
    return self;
}
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    if (self.type == SJCBrowserPresentTransitionTypePresent) {
        return 0.45f;
    }else {
        return 0.25f;
    }
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    switch (self.type) {
        case SJCBrowserPresentTransitionTypePresent:
            [self presentAnimation:transitionContext];
            break;
            
        case SJCBrowserPresentTransitionTypeDismiss:
            [self dismissAnimation:transitionContext];
            break;
    }
}
- (void)presentAnim:(id<UIViewControllerContextTransitioning>)transitionContext Image:(UIImage *)image Model:(HXPhotoModel *)model FromVC:(UIViewController *)fromVC ToVC:(SJCImageBrowser *)toVC {
    
    if (toVC.customPreviewFromImage) {
        image = toVC.customPreviewFromImage(toVC.currentModelIndex);
    }
    UIView *containerView = [transitionContext containerView];
    UIImageView *tempView = [[UIImageView alloc] initWithImage:image];
    UIView *tempBgView = [[UIView alloc] initWithFrame:containerView.bounds];
    tempView.clipsToBounds = YES;
    tempView.contentMode = UIViewContentModeScaleAspectFill;
    
    
    UIView *cell;
    
    if (toVC.customPreviewFromView) {
        cell = (id)toVC.customPreviewFromView(toVC.currentModelIndex);
    }
    
    tempView.frame = [cell convertRect:cell.bounds toView:containerView];
    
    [tempBgView addSubview:tempView];
    self.tempView = tempView;
    
    [containerView addSubview:toVC.view];
    [toVC.view insertSubview:tempBgView atIndex:0];
    toVC.collectionView.hidden = YES;
    
    model.endImageSize = CGSizeZero;
    CGFloat imgWidht = model.endImageSize.width;
    CGFloat imgHeight = model.endImageSize.height;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    toVC.navigationController.navigationBar.userInteractionEnabled = NO;
    UIColor *tempColor = toVC.view.backgroundColor;
    toVC.view.backgroundColor = [tempColor colorWithAlphaComponent:0];
    cell.hidden = toVC.hideOrginView;
    [toVC setupDarkBtnAlpha:0.f];
    [UIView animateWithDuration:0.2 animations:^{
        toVC.view.backgroundColor = [tempColor colorWithAlphaComponent:1.f];
        [toVC setupDarkBtnAlpha:1.f];
    }];
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.75f initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (imgHeight <= height) {
            tempView.frame = CGRectMake((width - imgWidht) / 2, (height - imgHeight) / 2, imgWidht, imgHeight);
        }else {
            tempView.frame = CGRectMake(0, 0, imgWidht, imgHeight);
        }
    } completion:^(BOOL finished) {
        cell.hidden = NO;
        toVC.collectionView.hidden = NO;
        [tempBgView removeFromSuperview];
        [tempView removeFromSuperview];
        toVC.navigationController.navigationBar.userInteractionEnabled = YES;
        [transitionContext completeTransition:YES];
    }];
}
/**
 *  实现present动画
 */
- (void)presentAnimation:(id<UIViewControllerContextTransitioning>)transitionContext{
    SJCImageBrowser *toVC = (SJCImageBrowser *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

    if ([fromVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)fromVC;
        fromVC = nav.viewControllers.lastObject;
    }else if ([fromVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBar = (UITabBarController *)fromVC;
        if ([tabBar.selectedViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)tabBar.selectedViewController;
            fromVC = nav.viewControllers.lastObject;
        }else {
            fromVC = tabBar.selectedViewController;
        }
    }
    HXPhotoModel *model = toVC.modelArray[toVC.currentModelIndex];
    [self presentAnim:transitionContext Image:nil Model:model FromVC:fromVC ToVC:toVC];
}

/**
 *  实现dimiss动画
 */
- (void)dismissAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    SJCImageBrowser *fromVC = (SJCImageBrowser *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    HXPhotoModel *model = [fromVC.modelArray objectAtIndex:fromVC.currentModelIndex];
    HXPhotoPreviewViewCell *fromCell = [fromVC currentPreviewCell:model];
    UIImageView *tempView;
    tempView = [[UIImageView alloc] initWithImage:fromCell.previewContentView.image];
    
    UIView *cell ;
    
    tempView.clipsToBounds = YES;
    tempView.contentMode = UIViewContentModeScaleAspectFill;
    
    
    UIView *containerView = [transitionContext containerView];
    tempView.frame = [fromCell.previewContentView convertRect:fromCell.previewContentView.bounds toView:containerView];
    [containerView addSubview:tempView];
    
    CGRect rect = [cell convertRect:cell.bounds toView:containerView];
    if (fromVC.customPreviewToView) {
        cell = (id)fromVC.customPreviewToView(fromVC.currentModelIndex);
    }
    rect = [cell convertRect:cell.bounds toView:containerView];
    cell.hidden = fromVC.hideOrginView;
    fromVC.collectionView.hidden = YES;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromVC.view.alpha = 0;
        if (cell) {
            tempView.frame = rect;
        }else {
            tempView.alpha = 0;
            tempView.transform = CGAffineTransformMakeScale(1.3, 1.3);
        }
    } completion:^(BOOL finished) {
        cell.hidden = NO;
        [tempView removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
}
@end

