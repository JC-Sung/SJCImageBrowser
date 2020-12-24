//
//  SJCImageBrowser.h
//  Yehwang
//
//  Created by Yehwang on 2020/11/2.
//  Copyright © 2020 Yehwang. All rights reserved.
//

///基于HXPhotoPicker而打造的图片浏览器，是为了更好的自定义，比如照片浏览时可以下方带文字的这种，类似今日头条

#import <UIKit/UIKit.h>
#import <PhotosUI/PhotosUI.h>

#import "HXPhotoPreviewImageViewCell.h"
#import "HXPhotoPreviewVideoViewCell.h"
#import "HXPhotoPreviewLivePhotoCell.h"


@interface SJCImageBrowser : UIViewController<UIViewControllerTransitioningDelegate,UINavigationControllerDelegate>

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithImages:(NSArray <NSString*>*)images
               andCurrentIndex:(NSInteger)currenIndex;

@property (strong, nonatomic) NSMutableArray *modelArray;
@property (assign, nonatomic) NSInteger currentModelIndex;
@property (assign, nonatomic) BOOL outside;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (assign, nonatomic) BOOL hideOrginView;
@property (assign, nonatomic) BOOL transitionNeedPop;

@property (assign, nonatomic) BOOL stopCancel;
/**  预览大图时是否禁用手势返回  */
@property (assign, nonatomic) BOOL disableaPersentInteractiveTransition;

// 处理ios8 导航栏转场动画崩溃问题
@property (strong, nonatomic) UIViewController *photoViewController;
@property (copy, nonatomic) void (^ currentCellScrollViewDidScroll)(UIScrollView *scrollView);




@property (copy, nonatomic) void (^ previewRespondsToLongPress)(NSInteger currentIndex);
@property (copy, nonatomic) void (^previewDidScrollToIndex)(NSInteger currentIndex);
@property (copy, nonatomic) UIView * (^customPreviewFromView)(NSInteger currentIndex);
@property (copy, nonatomic) UIImage * (^customPreviewFromImage)(NSInteger currentIndex);
@property (copy, nonatomic) UIView * (^customPreviewToView)(NSInteger currentIndex);


- (HXPhotoPreviewViewCell *)currentPreviewCell:(HXPhotoModel *)model;
- (void)changeStatusBarWithHidden:(BOOL)hidden;
- (void)setupDarkBtnAlpha:(CGFloat)alpha;

@end


