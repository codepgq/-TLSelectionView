//
//  SelectTextRangeView.h
//  hh
//
//  Created by 盘国权 on 2020/2/27.
//  Copyright © 2020 pgq. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TLSelectTextRangeView : UIView
/**
 前半部分选中区域
 */
@property (nonatomic, assign) CGRect headRect;
/**
 中间部分选中区域
 */
@property (nonatomic, assign) CGRect middleRect;
/**
 后半部分选中区域
 */
@property (nonatomic, assign) CGRect tailRect;
/**
 选择内容是否包含不同行
 */
@property (nonatomic, assign) BOOL differentLine;


/// 更新已选中区域
/// @param frame 大小
/// @param headRect 头部位置
/// @param middleRect 中间位置
/// @param tailRect 尾部位置
/// @param differentLine 是不是跨行
- (void)updateFrame:(CGRect)frame headRect:(CGRect)headRect middleRect:(CGRect)middleRect tailRect:(CGRect)tailRect differentLine:(BOOL)differentLine;
@end

NS_ASSUME_NONNULL_END
