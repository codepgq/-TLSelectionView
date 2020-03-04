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

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype) initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
//        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//        [paragraphStyle setLineSpacing:3];
//        NSDictionary *attributes = @{
//            NSFontAttributeName:[UIFont systemFontOfSize:15],
//            NSParagraphStyleAttributeName:paragraphStyle
//        };
//        self.typingAttributes = attributes;
        
        self.isCanBecomeFirstResponder = true;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    self = [super initWithFrame:frame textContainer:textContainer];
    self.isCanBecomeFirstResponder = true;
    return self;
}

- (BOOL)isSelectAll {
    return [[TLSelectRangManager instance] isSelectAll];
}

#pragma mark - 公开的方法
/// 添加长按事件
- (void)addLongPressEvent {
    // 添加长按手势
    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureDidFire:)];
    [self addGestureRecognizer:_longPressGestureRecognizer];
}

/// 移除长按事件
- (void)removeLongPressEvent {
    [_longPressGestureRecognizer removeTarget:self action:@selector(longPressGestureDidFire:)];
    _longPressGestureRecognizer = nil;
}

///  选中全部内容
- (void)selectAllText {
     [self hideSelectionView];
    [self longPressGestureDidFire:_longPressGestureRecognizer];
}

/// 隐藏选中视图
- (void)hideSelectionView {
    [[TLSelectRangManager instance] hideSelectTextRangeView];
}

/// 选中的富文本
- (NSAttributedString *)selectionAttributedString {
    return [[TLSelectRangManager instance] selectArrtibutedString];
}

/// 选中的文本
- (NSString *)selectionStringWithisCopyToPasteboard:(BOOL)isCopy {
    return [[TLSelectRangManager instance] selectStringWithIsCopy:isCopy];
}

/// 监听是否正在移动选择区域
/// @param movingBlock 移动中
/// @param endMoveBlock 停止移动了
- (void)selectionMoving:(MTTextViewBlock)movingBlock endMove:(MTTextViewBlock)endMoveBlock {
    __weak typeof(self) _weakSelf = self;
    [TLSelectRangManager instance].movingBlock = ^() {
        __strong typeof(_weakSelf) _strongSelf = _weakSelf;
        if (movingBlock) {
            movingBlock(_strongSelf);
        }
    };
    
    [TLSelectRangManager instance].endMoveBlock = ^() {
        __strong typeof(_weakSelf) _strongSelf = _weakSelf;
        if (endMoveBlock) {
            endMoveBlock(_strongSelf);
        }
    };
}

#pragma mark - 长按事件
- (void)longPressGestureDidFire:(UILongPressGestureRecognizer *)sender {
    
    if ([[TLSelectRangManager instance] isShow]) { return; }
   
    _isLongPress = true;
   
    CGPoint point = [sender locationInView:self];
    
    CGRect textRect = UIEdgeInsetsInsetRect(CGRectMake(0, 0, self.contentSize.width, self.contentSize.height), self.contentInset);
    textRect = CGRectStandardize(textRect);
    
    
    NSArray *allItems = [TLRunItem getItemsWith:self.attributedText textRect:textRect view:self];
    TLRunItem *currentItem = [TLSelectRangManager currentItem:point allRunItemArray:allItems inset:0.5];
    
   
//    UIViewController *topVC = [self topViewController];
//    UINavigationController *navCtr = nil;
//    BOOL popGestureEnable = NO;
//    if (topVC.navigationController) {
//        navCtr = topVC.navigationController;
//        popGestureEnable = navCtr.interactivePopGestureRecognizer.enabled;
//        navCtr.interactivePopGestureRecognizer.enabled = NO;
//    }
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
    return _isCanBecomeFirstResponder;
}

/// 不允许成为第一响应者
- (BOOL)canBecomeFirstResponder {
    return _isCanBecomeFirstResponder;
}

#pragma mark - 私有方法
//- (UIViewController *)topViewController {
//
//    UIViewController *resultVC = nil;
//    resultVC = [self _topViewController:[[TLSelectRangManager keyWindow] rootViewController]];
//    while (resultVC.presentedViewController) {
//        resultVC = [self _topViewController:resultVC.presentedViewController];
//    }
//    return resultVC;
//}
//
//- (UIViewController *)_topViewController:(UIViewController *)vc {
//    if ([vc isKindOfClass:[UINavigationController class]]) {
//        return [self _topViewController:[(UINavigationController *)vc topViewController]];
//    } else if ([vc isKindOfClass:[UITabBarController class]]) {
//        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
//    } else {
//        return vc;
//    }
//    return nil;
//}

#pragma mark - 以前的旧代码

//- (CGRect)caretRectForPosition:(UITextPosition *)position {
//    CGRect originalRect = [super caretRectForPosition:position];
//
//
//
//    return originalRect;
//}
//
//- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
//    if (self.isCloseCopy) {
//        UIMenuController *menuController = [UIMenuController sharedMenuController];
//        if (menuController)
//        {
//            [UIMenuController sharedMenuController].menuVisible = NO;
//        }
//        return NO;
//    }
//    return [super canPerformAction:action withSender:sender];
//}
//
//- (void)addInteraction:(id<UIInteraction>)interaction {
//    if ([interaction isKindOfClass: UIDragInteraction.class]) {
//        UIDragInteraction *drag = (UIDragInteraction *) interaction;
//        drag.enabled = NO;
//    }
//}

@end




