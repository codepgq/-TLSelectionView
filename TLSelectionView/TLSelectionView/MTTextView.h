//
//  MTTextView.h
//  Pods
//
//  Created by chenhuan on 2018/7/5.
//

/**
 如果要在底部的一行也显示小圆点，要把这个设置为self.clipsToBounds = false
 */

#import <UIKit/UIKit.h>
@class MTTextView;
typedef void(^MTTextViewBlock)(MTTextView *view);

@interface MTTextView : UITextView

@property (nonatomic,assign) BOOL isCloseCopy;
/// default is true
@property (nonatomic,assign) BOOL isCanBecomeFirstResponder;
@property (nonatomic,assign, readonly) BOOL isSelectAll;


/// 添加长按事件
- (void)addLongPressEvent;

/// 移除长按事件
- (void)removeLongPressEvent;

/// 直接选中
- (void)selectAllText;

/// 隐藏选中视图
- (void)hideSelectionView;

/// 选中的富文本
- (NSAttributedString *)selectionAttributedString;

/// 选中的文本
- (NSString *)selectionStringWithisCopyToPasteboard:(BOOL)isCopy;

/// 监听是否正在移动选择区域
/// @param movingBlock 移动中
/// @param endMoveBlock 停止移动了
- (void)selectionMoving:(MTTextViewBlock)movingBlock endMove:(MTTextViewBlock)endMoveBlock;
@end

