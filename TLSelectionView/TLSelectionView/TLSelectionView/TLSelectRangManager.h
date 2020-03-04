//
//  TLSelectRangManager.h
//  hh
//
//  Created by 盘国权 on 2020/2/27.
//  Copyright © 2020 pgq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class MTTextView;
#import "TLRunItem.h"
@class TLSelectTextRangeView;
@class TLCTLineLayoutModel;

typedef void(^TLSelectRangManagerMoveBlock)();

NS_ASSUME_NONNULL_BEGIN

@interface TLSelectRangManager : UIView
/// 输入视图
@property (nonatomic,weak) MTTextView *view;
@property (nonatomic, strong) TLSelectTextRangeView *textRangeView;//选中复制填充背景色的view
@property (nonatomic, strong) NSMutableArray<TLCTLineLayoutModel*> *verticalLayoutArray;
/// 是否已经显示
@property (nonatomic,assign) BOOL isShow;

/// 移动中的block
@property (nonatomic,copy) TLSelectRangManagerMoveBlock beginMoveBlock;
/// 移动中的block
@property (nonatomic,copy) TLSelectRangManagerMoveBlock movingBlock;
/// 停止移动的block
@property (nonatomic,copy) TLSelectRangManagerMoveBlock endMoveBlock;

+ (UIWindow*)keyWindow;

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

/// 判断是否全选
- (BOOL)isSelectAll;

// 根据point获取当前的currentRunItem
+ (TLRunItem *)currentItem:(CGPoint)point allRunItemArray:(NSArray <TLRunItem *>*)allRunItemArray inset:(CGFloat)inset;


/// 获取选中的文字 富文本
- (NSAttributedString *)selectArrtibutedString;

/// 获取选中的文字 
- (NSString *)selectStringWithIsCopy:(BOOL)isCopyToPasteboard;

@end

NS_ASSUME_NONNULL_END


