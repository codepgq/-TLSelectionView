//
//  MTTextView.m
//  Pods
//
//  Created by chenhuan on 2018/7/5.
//

#import "MTTextView.h"
#import "TLRunItem.h"
#import "TLSelectRangManager.h"
#import "TLCTLineLayoutModel.h"

@interface MTTextView()<UIGestureRecognizerDelegate>

@end

@implementation MTTextView {
    UILongPressGestureRecognizer *_longPressGestureRecognizer;
    BOOL _isLongPress;
    
}

- (instancetype) initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:3];
        NSDictionary *attributes = @{
            NSFontAttributeName:[UIFont systemFontOfSize:15],
            NSParagraphStyleAttributeName:paragraphStyle
        };
        self.typingAttributes = attributes;
        
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureDidFire:)];
        [self addGestureRecognizer:_longPressGestureRecognizer];

     
        self.showsVerticalScrollIndicator = false;
        self.showsHorizontalScrollIndicator = false;
        
    }
    return self;
}

#pragma mark - 长按事件
- (void)longPressGestureDidFire:(UILongPressGestureRecognizer *)sender {
    
    if ([[TLSelectRangManager instance] isShow]) { return; }
    _isLongPress = true;
   
    CGPoint point = [sender locationInView:self];
    
    NSArray *allItems = [TLRunItem getItemsWith:self.attributedText size:self.contentSize view:self];
    TLRunItem *currentItem = [TLSelectRangManager currentItem:point allRunItemArray:allItems inset:0.5];
    
   
    UIViewController *topVC = [self topViewController];
    UINavigationController *navCtr = nil;
    BOOL popGestureEnable = NO;
    if (topVC.navigationController) {
        navCtr = topVC.navigationController;
        popGestureEnable = navCtr.interactivePopGestureRecognizer.enabled;
        navCtr.interactivePopGestureRecognizer.enabled = NO;
    }
    [[TLSelectRangManager instance] showSelectViewInCJLabel:self
                                                    atPoint:point
                                                    runItem:currentItem
                                               maxLineWidth:self.frame.size.width
                                            allRunItemArray:allItems
                                              hideViewBlock:^() {
        self->_isLongPress = false;
    }];
    
}
- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    return false;
}

#pragma mark - 系统方法
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return NO;
}

- (BOOL)canBecomeFirstResponder {
    return false;
}

- (UIViewController *)topViewController {
    UIViewController *resultVC = nil;
    resultVC = [self _topViewController:[TLkeyWindow() rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

- (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

@end




