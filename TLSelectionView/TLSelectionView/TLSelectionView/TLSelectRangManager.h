//
//  TLSelectRangManager.h
//  hh
//
//  Created by 盘国权 on 2020/2/27.
//  Copyright © 2020 pgq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "TLRunItem.h"
@class TLSelectTextRangeView;
@class TLCTLineLayoutModel;

NS_ASSUME_NONNULL_BEGIN

@interface TLSelectRangManager : UIView
@property (nonatomic, strong) TLSelectTextRangeView *textRangeView;//选中复制填充背景色的view
@property (nonatomic, strong) NSMutableArray<TLCTLineLayoutModel*> *verticalLayoutArray;
/// 是否已经显示
@property (nonatomic,assign) BOOL isShow;


/// 单例
+ (instancetype)instance;

/// 显示选中区域
- (void)showSelectViewInCJLabel:(UITextView *)view
                        atPoint:(CGPoint)point
                        runItem:(TLRunItem *)item
                   maxLineWidth:(CGFloat)maxLineWidth
                allRunItemArray:(NSArray <TLRunItem *>*)allRunItemArray
                  hideViewBlock:(void(^)(void))hideViewBlock;

/**
 更新选中复制的背景填充色
 */
- (void)updateSelectTextRangeViewStartCopyRunItem:(TLRunItem *)startCopyRunItem
                                   endCopyRunItem:(TLRunItem *)endCopyRunItem
                                             view:(UIView *) view;

/// 隐藏选择区域视图
- (void)hideSelectTextRangeView;

/**
 移动的方法
 */
- (void)move:(CGPoint)point;
/**
 更新操作模式
 */
- (void)updateSelectAction:(CGPoint)point;

// 根据point获取当前的currentRunItem
+ (TLRunItem *)currentItem:(CGPoint)point allRunItemArray:(NSArray <TLRunItem *>*)allRunItemArray inset:(CGFloat)inset;


/// 获取选中的文字 富文本
- (NSAttributedString *)selectArrtibutedString;

/// 获取选中的文字 
- (NSString *)selectStringWithIsCopy:(BOOL)isCopyToPasteboard;

@end

NS_ASSUME_NONNULL_END


static inline UIWindow * TLkeyWindow() {
    UIApplication *app = [UIApplication sharedApplication];
    if ([app.delegate respondsToSelector:@selector(window)]) {
        return [app.delegate window];
    } else {
        return [app keyWindow];
    }
}
