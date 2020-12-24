# SJCImageBrowser
类似于微信的照片浏览器，UICollectionView+转场动画，支持手势拖拽消失，基于HXPhotoPicker（一个非常nice的照片选择器，感觉已经就是当前的微信照片选择器了，功能非常强大）

原文传送门 https://github.com/SilenceLove/HXPhotoPicker
这个也是模仿HXPhotoPicker写的，也是项目中需要单独定制的大图浏览器，便于拓展，例如自定义大图浏览下的UI，每个大图下方会自带一段详情描述等，浏览大图不隐藏源视图等，自己的项目可以基于SJCImageBrowser这个控制器完全自定义
后期准备把我的另一个照片选择库https://github.com/Lovezysong/SJCMediaPicker 基于此框架继续优化一番

# 使用

你需要先下载HXPhotoPicker导入，然后#import "SJCImageBrowser.h"



```objective-c
SJCImageBrowser *previewVC = [[SJCImageBrowser alloc] initWithImages:imagesArry andCurrentIndex:index];
    previewVC.hideOrginView = YES;//预览大图时，是否隐藏源视图
    previewVC.transitionNeedPop = YES;//预览大图时，师傅需要pop动画
    previewVC.disableaPersentInteractiveTransition = NO;//预览大图时，是禁用手势返回
    
    // 跳转预览界面时动画起始的view
    previewVC.customPreviewFromView = ^UIView *(NSInteger currentIndex) {
       
    };
    // 跳转预览界面时展现动画的image
    previewVC.customPreviewFromImage = ^UIImage *(NSInteger currentIndex) {
        
    };
    // 退出预览界面时终点view
    previewVC.customPreviewToView = ^UIView *(NSInteger currentIndex) {
        
    };
    [self presentViewController:previewVC animated:YES completion:nil];
