//
//  SJCImageBrowser.h
//  Yehwang
//
//  Created by Yehwang on 2020/11/2.
//  Copyright © 2020 Yehwang. All rights reserved.
//

#import "SJCImageBrowser.h"
#import "UIImage+HXExtension.h"
#import "UIButton+HXExtension.h"

#import "SJCBrowerNavTransition.h"
#import "SJCBrowerNavInteractiveTransition.h"
#import "SJCBrowerPresentTransition.h"
#import "SJCBrowerPersentInteractiveTransition.h"


#import "HXCircleProgressView.h"
#import "HX_PhotoEditViewController.h"
#import "UIViewController+HXExtension.h"

#import "UIImageView+HXExtension.h"
#import "UIColor+HXExtension.h"

@interface SJCImageBrowser ()
<
UICollectionViewDataSource,
UICollectionViewDelegate
>
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) HXPhotoModel *currentModel;
@property (strong, nonatomic) HXPhotoPreviewViewCell *tempCell;
@property (assign, nonatomic) BOOL orientationDidChange;
@property (assign, nonatomic) BOOL firstChangeFrame;
@property (assign, nonatomic) NSInteger beforeOrientationIndex;
@property (strong, nonatomic) SJCBrowerNavInteractiveTransition *interactiveTransition;
@property (strong, nonatomic) SJCBrowerPersentInteractiveTransition *persentInteractiveTransition;

@property (assign, nonatomic) BOOL isAddInteractiveTransition;
@property (strong, nonatomic) UIPageControl *bottomPageControl;
@property (strong, nonatomic) UIButton *darkCancelBtn;
@property (assign, nonatomic) BOOL statusBarShouldBeHidden;
@property (assign, nonatomic) BOOL layoutSubviewsCompletion;

@end

@implementation SJCImageBrowser

#pragma mark - < transition delegate >
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
    if (operation == UINavigationControllerOperationPush) {
        if (![toVC isKindOfClass:[self class]]) {
            return nil;
        }
        return [SJCBrowerNavTransition transitionWithType:HXPhotoViewTransitionTypePush];
    }else {
        if (![fromVC isKindOfClass:[self class]]) {
            return nil;
        }
        return [SJCBrowerNavTransition transitionWithType:HXPhotoViewTransitionTypePop];
    }
}
- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController{
    return self.interactiveTransition.interation ? self.interactiveTransition : nil;
}
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [SJCBrowerPresentTransition transitionWithTransitionType:SJCBrowserPresentTransitionTypePresent photoView:nil];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [SJCBrowerPresentTransition transitionWithTransitionType:SJCBrowserPresentTransitionTypeDismiss photoView:nil];
}
- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    return self.persentInteractiveTransition.interation ? self.persentInteractiveTransition : nil;
}
#pragma mark - < life cycle >

- (instancetype)initWithImages:(NSArray <NSString*>*)images
               andCurrentIndex:(NSInteger)currenIndex {
    self = [super init];
    if (self) {
        //初始化以及一些设置
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        self.modalPresentationCapturesStatusBarAppearance = YES;
        _disableaPersentInteractiveTransition = NO;
        _outside = YES;
        _hideOrginView = NO;
        _transitionNeedPop = NO;
        
        NSAssert(images, @"images: is nil!");
        
        NSMutableArray *temp = [NSMutableArray new];
        for (NSString *img in images) {
            HXCustomAssetModel *model = [HXCustomAssetModel assetWithNetworkImageURL:[NSURL URLWithString:img] selected:YES];
            [temp addObject:model];
        }
        HXPhotoManager *photoManager = [HXPhotoManager managerWithType:HXPhotoManagerSelectedTypePhoto];
        photoManager.configuration.maxNum = temp.count;
        [photoManager addCustomAssetModel:temp];
        
        self.modelArray = [NSMutableArray arrayWithArray:photoManager.afterSelectedArray];;
        self.currentModelIndex = currenIndex;
    }
    return self;
}

- (void)dealloc {
    if (self.photoViewController && HX_IOS9Earlier) {
        // 处理ios8 导航栏转场动画崩溃问题
        self.photoViewController.navigationController.delegate = nil;
        self.photoViewController = nil;
    }
    if (_collectionView) {
        HXPhotoPreviewViewCell *cell = (HXPhotoPreviewViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentModelIndex inSection:0]];
        [cell cancelRequest];
    }
    if ([UIApplication sharedApplication].statusBarHidden) {
        [self changeStatusBarWithHidden:NO];
        [self.navigationController setNavigationBarHidden:NO animated:NO];
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
#pragma clang diagnostic pop
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}
- (BOOL)prefersStatusBarHidden {
    if (!self) {
        return [super prefersStatusBarHidden];
    }
    return self.statusBarShouldBeHidden;
}
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!CGRectEqualToRect(self.view.frame, [UIScreen mainScreen].bounds)) {
        self.view.frame = [UIScreen mainScreen].bounds;
    }
    if (self.orientationDidChange || self.firstChangeFrame) {
        [self changeSubviewFrame];
        self.orientationDidChange = NO;
        self.firstChangeFrame = NO;
    }
    
    self.layoutSubviewsCompletion = YES;
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
- (void)changeStatusBarStyle {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self changeStatusBarStyle];
    [self changeStatusBarWithHidden:YES];
    if (![UIApplication sharedApplication].statusBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
}
#pragma clang diagnostic pop
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    HXPhotoModel *model = self.modelArray[self.currentModelIndex];
    self.currentModel = model;
    HXPhotoPreviewViewCell *cell = (HXPhotoPreviewViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentModelIndex inSection:0]];
    if (!cell) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            HXPhotoPreviewViewCell *tempCell = (HXPhotoPreviewViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentModelIndex inSection:0]];
            self.tempCell = tempCell;
            [tempCell requestHDImage];
        });
    }else {
        self.tempCell = cell;
        [cell requestHDImage];
    }
    if (!self.isAddInteractiveTransition) {
        if (!self.outside) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //初始化手势过渡的代理
                self.interactiveTransition = [[SJCBrowerNavInteractiveTransition alloc] init];
                //给当前控制器的视图添加手势
                [self.interactiveTransition addPanGestureForViewController:self];
            });
        }else if (!self.disableaPersentInteractiveTransition) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //初始化手势过渡的代理
                self.persentInteractiveTransition = [[SJCBrowerPersentInteractiveTransition alloc] init];
                //给当前控制器的视图添加手势
                [self.persentInteractiveTransition addPanGestureForViewController:self];
            });
        }
        self.isAddInteractiveTransition = YES;
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([UIApplication sharedApplication].statusBarHidden) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
#pragma clang diagnostic pop
    }
    [self changeStatusBarWithHidden:NO];
    HXPhotoPreviewViewCell *cell = (HXPhotoPreviewViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentModelIndex inSection:0]];
    cell.stopCancel = self.stopCancel;
    [cell cancelRequest];
    self.stopCancel = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    [self setupUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationWillChanged:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    
    [self addGesture];
    
}
#pragma mark - < private >

- (void)addGesture {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToLongPress:)];
    [self.view addGestureRecognizer:longPress];
}
- (void)respondsToLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        if (self.previewRespondsToLongPress) {
            HXPhotoModel *model;
            if (self.modelArray.count) model = self.modelArray[self.currentModelIndex];
            self.previewRespondsToLongPress(self.currentModelIndex);
        }
    }
}
- (void)deviceOrientationChanged:(NSNotification *)notify {
    self.orientationDidChange = YES;
}
- (void)deviceOrientationWillChanged:(NSNotification *)notify {
    self.beforeOrientationIndex = self.currentModelIndex;
}
- (void)changeSubviewFrame {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    HXPhotoModel *model = self.modelArray[self.currentModelIndex];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
        [self changeStatusBarWithHidden:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
#pragma clang diagnostic pop
    }else if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft){
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
        [self changeStatusBarWithHidden:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
#pragma clang diagnostic pop

    }
    CGFloat bottomMargin = hxBottomMargin;
    CGFloat width = self.view.hx_w;
    CGFloat itemMargin = 20;
    if (HX_IS_IPhoneX_All && (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)) {
        bottomMargin = 21;
    }
    
    self.flowLayout.itemSize = CGSizeMake(width, self.view.hx_h);
    self.flowLayout.minimumLineSpacing = itemMargin;
    [self.collectionView setCollectionViewLayout:self.flowLayout];
    
    self.collectionView.frame = CGRectMake(-(itemMargin / 2), 0,self.view.hx_w + itemMargin, self.view.hx_h);
    
    self.collectionView.contentSize = CGSizeMake(self.modelArray.count * (self.view.hx_w + itemMargin), self.view.hx_h);
    
    
    [self.collectionView setContentOffset:CGPointMake(self.beforeOrientationIndex * (self.view.hx_w + itemMargin), 0)];
    model.previewContentOffsetX = self.collectionView.contentOffset.x;
    
    if (self.orientationDidChange) {
        dispatch_async(dispatch_get_main_queue(), ^{
            HXPhotoPreviewViewCell *cell = [self currentPreviewCellWithIndex:self.currentModelIndex];
            [UIView animateWithDuration:0.25 animations:^{
                [cell refreshImageSize];
            }];
        });
    }
    
    CGFloat topMargin = HX_IS_IPhoneX_All ? 45 : 30;
    self.darkCancelBtn.frame = CGRectMake(18, topMargin, 26, 26);
    CGFloat pageControlY = HX_IS_IPhoneX_All ? self.view.hx_h - 40 : self.view.hx_h - 30;
    self.bottomPageControl.frame = CGRectMake(0, pageControlY, self.view.hx_w, 10);
    

    self.navigationController.navigationBar.translucent = NO;
    
}
- (void)changeColor {
    self.collectionView.backgroundColor = [UIColor blackColor];
    self.view.backgroundColor = [UIColor blackColor];

}
- (void)setupUI {
    [self.view addSubview:self.collectionView];
    self.beforeOrientationIndex = self.currentModelIndex;
    
    HXPhotoModel *model = self.modelArray[self.currentModelIndex];
    self.currentModel = model;
    

    
    [self.view addSubview:self.darkCancelBtn];
    
    if ([self.modelArray containsObject:model]) {
        self.bottomPageControl.currentPage = [self.modelArray indexOfObject:model];
    }
    
    BOOL canAddBottomPageControl =  (self.modelArray.count<=1) ? NO : (HX_IOS14_Later ? YES : (self.modelArray.count <= 15));
    if (canAddBottomPageControl) {
        [self.view addSubview:self.bottomPageControl];
    }
    
    [self changeColor];
    self.firstChangeFrame = YES;
}

- (void)cancelDismissClick {
    [self dismissViewControllerAnimated:YES completion:^{}];
}
- (void)dismissClick {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - < public >
- (HXPhotoPreviewViewCell *)currentPreviewCellWithIndex:(NSInteger)index {
    if (index < 0) {
        index = 0;
    }
    if (index > self.modelArray.count - 1) {
        index = self.modelArray.count - 1;
    }
    return (HXPhotoPreviewViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
}
- (HXPhotoPreviewViewCell *)currentPreviewCell:(HXPhotoModel *)model {
    if (!model) {
        return nil;
    }
    return (HXPhotoPreviewViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentModelIndex inSection:0]];
}
- (void)changeStatusBarWithHidden:(BOOL)hidden {
    self.statusBarShouldBeHidden = hidden;
    [self preferredStatusBarUpdateAnimation];
}


- (void)setupDarkBtnAlpha:(CGFloat)alpha {
    self.darkCancelBtn.alpha = alpha;
    self.bottomPageControl.alpha = alpha;
}

#pragma mark - < UICollectionViewDataSource >
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.modelArray count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HXPhotoModel *model = self.modelArray[indexPath.item];
    HXPhotoPreviewViewCell *cell;
    HXWeakSelf
    if (model.subType == HXPhotoModelMediaSubTypePhoto) {
        if (model.type == HXPhotoModelMediaTypeLivePhoto) {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HXPhotoPreviewLivePhotoCell" forIndexPath:indexPath];
        }else {
            if (model.type == HXPhotoModelMediaTypeCameraPhoto &&
               ( model.cameraPhotoType == HXPhotoModelMediaTypeCameraPhotoTypeLocalLivePhoto ||
                 model.cameraPhotoType == HXPhotoModelMediaTypeCameraPhotoTypeNetWorkLivePhoto)) {
                    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HXPhotoPreviewLivePhotoCell" forIndexPath:indexPath];
            }else {
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HXPhotoPreviewImageViewCell" forIndexPath:indexPath];
            }
        }
    }else if (model.subType == HXPhotoModelMediaSubTypeVideo) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HXPhotoPreviewVideoViewCell" forIndexPath:indexPath];
        HXPhotoPreviewVideoViewCell *viewCell = (HXPhotoPreviewVideoViewCell *)cell;
        viewCell.bottomSliderView.alpha = 1;
        viewCell.bottomSliderView.hidden = NO;
    }else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HXPhotoPreviewImageViewCell" forIndexPath:indexPath];
    }
    cell.cellViewLongPressGestureRecognizerBlock = ^(UILongPressGestureRecognizer * _Nonnull longPress) {
        [weakSelf respondsToLongPress:longPress];
    };
    cell.scrollViewDidScroll = ^(UIScrollView *scrollView) {
        if (weakSelf.currentCellScrollViewDidScroll) {
            weakSelf.currentCellScrollViewDidScroll(scrollView);
        }
    };
    [cell setCellDidPlayVideoBtn:^(BOOL play) {
        return;
    }];
    [cell setCellDownloadICloudAssetComplete:^(HXPhotoPreviewViewCell *myCell) {
        
    }];
    cell.cellDownloadImageComplete = ^(HXPhotoPreviewViewCell *myCell) {
        
    };
    [cell setCellTapClick:^(HXPhotoModel *model, HXPhotoPreviewViewCell *myCell) {
        if (weakSelf.outside) {
            if (model.subType == HXPhotoModelMediaSubTypeVideo) {
                HXPhotoPreviewVideoViewCell *videoCell = (HXPhotoPreviewVideoViewCell *)myCell;
                BOOL hidden = YES;
                if (videoCell.bottomSliderView.hidden || videoCell.bottomSliderView.alpha == 0) {
                    hidden = NO;
                }
                [weakSelf setCurrentCellBottomSliderViewHidden:hidden animation:YES];
            }else {
                [weakSelf dismissClick];
            }
        }
    }];
    cell.model = model;
    return cell;
}

- (void)setCurrentCellBottomSliderViewHidden:(BOOL)hidden animation:(BOOL)animation {
    HXPhotoPreviewVideoViewCell *cell = (HXPhotoPreviewVideoViewCell *)[self currentPreviewCell:self.currentModel];
    if (cell.bottomSliderView.hidden == hidden && cell.bottomSliderView.alpha == !hidden) {
        return;
    }
    if (animation) {
        if (!hidden) {
            if (cell.previewContentView.videoView.playBtnDidPlay) {
                cell.bottomSliderView.hidden = hidden;
            }
            self.darkCancelBtn.hidden = hidden;
        }
        [UIView animateWithDuration:0.25 animations:^{
            if (cell.previewContentView.videoView.playBtnDidPlay) {
                cell.bottomSliderView.alpha = !hidden;
            }
            self.darkCancelBtn.alpha = !hidden;
        } completion:^(BOOL finished) {
            if (cell.previewContentView.videoView.playBtnDidPlay) {
                cell.bottomSliderView.hidden = hidden;
            }
            self.darkCancelBtn.hidden = hidden;
        }];
    }else {
        self.darkCancelBtn.alpha = !hidden;
        self.darkCancelBtn.hidden = hidden;
        if (cell.previewContentView.videoView.playBtnDidPlay) {
            cell.bottomSliderView.hidden = hidden;
            cell.bottomSliderView.alpha = !hidden;
        }
    }
}

#pragma mark - < UICollectionViewDelegate >
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    self.persentInteractiveTransition.atFirstPan = NO;
    self.interactiveTransition.atFirstPan = NO;
    [(HXPhotoPreviewViewCell *)cell resetScale:NO];
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    HXPhotoPreviewViewCell *myCell = (HXPhotoPreviewViewCell *)cell;
    [myCell cancelRequest];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != self.collectionView) {
        return;
    }
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat offsetx = self.collectionView.contentOffset.x;
    NSInteger currentIndex = (offsetx + (width + 20) * 0.5) / (width + 20);
    if (currentIndex > self.modelArray.count - 1) {
        currentIndex = self.modelArray.count - 1;
    }
    if (currentIndex < 0) {
        currentIndex = 0;
    }
    if (self.modelArray.count > 0) {
        self.bottomPageControl.currentPage = currentIndex;
    
    self.currentModelIndex = currentIndex;
    if (currentIndex >= 0 && currentIndex < self.modelArray.count) {
        HXPhotoModel *nextModel;
        if (self.currentModel.previewContentOffsetX > offsetx) {
            NSInteger index = [self.modelArray indexOfObject:self.currentModel] - 1;
            if (index >= 0 && index < self.modelArray.count) {
                nextModel = self.modelArray[index];
            }
        }else if (self.currentModel.previewContentOffsetX < offsetx){
            NSInteger index = [self.modelArray indexOfObject:self.currentModel] + 1;
            if (index >= 0 && index < self.modelArray.count) {
                nextModel = self.modelArray[index];
            }
        }
        if (nextModel && !self.orientationDidChange) {
            [self scrollDidScrollHiddenBottomSliderViewWithOffsetX:offsetx nextModel:nextModel];
        }
    }
    }
    
}
- (void)scrollDidScrollHiddenBottomSliderViewWithOffsetX:(CGFloat)offsetx nextModel:(HXPhotoModel *)nextModel {
    if (self.currentModel == nextModel) {
        return;
    }
    float difference = fabs(offsetx - self.currentModel.previewContentOffsetX);
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    if (difference > width) {
        difference = width;
    }
    CGFloat scale = difference / width;
    
    self.darkCancelBtn.hidden = NO;
    if (self.darkCancelBtn.alpha < 1) {
        self.darkCancelBtn.alpha = scale;
    }
    if (nextModel.subType == HXPhotoModelMediaSubTypeVideo) {
        HXPhotoPreviewVideoViewCell *nextCell = (HXPhotoPreviewVideoViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:[self.modelArray indexOfObject:nextModel] inSection:0]];
        if (!nextCell.bottomSliderView.hidden || nextCell.bottomSliderView.alpha < 1) {
            nextCell.bottomSliderView.alpha = 1;
            nextCell.bottomSliderView.hidden = NO;
        }
    }
}

/**
 *  滚动完毕就会调用（如果是人为拖拽scrollView导致滚动完毕，才会调用这个方法）
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewDidEndScrollingAnimation:self.collectionView];
    if (self.modelArray.count > 0) {
        HXPhotoPreviewViewCell *cell = (HXPhotoPreviewViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentModelIndex inSection:0]];
        HXPhotoModel *model = self.modelArray[self.currentModelIndex];
        model.previewContentOffsetX = scrollView.contentOffset.x;
        
        self.currentModel = model;
        [cell requestHDImage];
    }
}

/**
 *  滚动完毕就会调用（如果不是人为拖拽scrollView导致滚动完毕，才会调用这个方法）
 */
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView != self.collectionView) {
        return;
    }
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat offsetx = self.collectionView.contentOffset.x;
    NSInteger currentIndex = (offsetx + (width + 20) * 0.5) / (width + 20);
    if (currentIndex > self.modelArray.count - 1) {
        currentIndex = self.modelArray.count - 1;
    }
    if (currentIndex < 0) {
        currentIndex = 0;
    }
    if (self.modelArray.count) {
        if (self.previewDidScrollToIndex) {
            HXPhotoModel *model;
            if (self.modelArray.count) model = self.modelArray[self.currentModelIndex];
            self.previewDidScrollToIndex(self.currentModelIndex);
        }
    }
}

#pragma mark - < 懒加载 >
- (UIPageControl *)bottomPageControl {
    if (!_bottomPageControl) {
        _bottomPageControl = [[UIPageControl alloc] init];
        _bottomPageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        _bottomPageControl.pageIndicatorTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f];
        _bottomPageControl.numberOfPages = self.modelArray.count;
        _bottomPageControl.enabled = NO;
#ifdef __IPHONE_14_0
        if (@available(iOS 14, *)) {
            _bottomPageControl.backgroundStyle = UIPageControlBackgroundStyleProminent;
            _bottomPageControl.allowsContinuousInteraction = NO;
        }
#endif
    }
    return _bottomPageControl;
}

- (UIButton *)darkCancelBtn {
    if (!_darkCancelBtn) {
        _darkCancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_darkCancelBtn setBackgroundImage:[UIImage hx_imageNamed:@"hx_faceu_cancel"] forState:UIControlStateNormal];
        _darkCancelBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _darkCancelBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        [_darkCancelBtn addTarget:self action:@selector(cancelDismissClick) forControlEvents:UIControlEventTouchUpInside];
        _darkCancelBtn.touchAreaInsets = UIEdgeInsetsMake(30, 22, 30, 30);
    }
    return _darkCancelBtn;
}


- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-10, 0,self.view.hx_w + 20, [UIScreen mainScreen].bounds.size.height) collectionViewLayout:self.flowLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        
        [_collectionView registerClass:[HXPhotoPreviewImageViewCell class] forCellWithReuseIdentifier:@"HXPhotoPreviewImageViewCell"];
        [_collectionView registerClass:[HXPhotoPreviewLivePhotoCell class] forCellWithReuseIdentifier:@"HXPhotoPreviewLivePhotoCell"];
        [_collectionView registerClass:[HXPhotoPreviewVideoViewCell class] forCellWithReuseIdentifier:@"HXPhotoPreviewVideoViewCell"];
#ifdef __IPHONE_11_0
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
#else
            if ((NO)) {
#endif
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _collectionView;
}
- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
    _flowLayout = [[UICollectionViewFlowLayout alloc] init];
    _flowLayout.minimumInteritemSpacing = 0;
    _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    }
    return _flowLayout;
}
    
- (NSMutableArray *)modelArray {
    if (!_modelArray) {
        _modelArray = [NSMutableArray array];
    }
    return _modelArray;
}
@end
            
