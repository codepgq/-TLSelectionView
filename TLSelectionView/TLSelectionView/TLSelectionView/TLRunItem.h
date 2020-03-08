//
//  RunItem.h
//  hh
//
//  Created by 盘国权 on 2020/2/27.
//  Copyright © 2020 pgq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define TLLabelIsNull(a) ((a)==nil || (a)==NULL || (NSNull *)(a)==[NSNull null])


extern NSString * const kTLImageAttributeName;
extern NSString * const kTLImageLineVerticalAlignment;

NS_ASSUME_NONNULL_BEGIN

/**
 当text bounds小于label bounds时，文本的垂直对齐方式
 */
typedef NS_ENUM(NSInteger, TLLabelVerticalAlignment) {
    CJVerticalAlignmentCenter   = 0,//垂直居中
    CJVerticalAlignmentTop      = 1,//居上
    CJVerticalAlignmentBottom   = 2,//靠下
};

/**
 当CTLine包含插入图片时，描述当前行文字在垂直方向的对齐方式
 */
struct TLCTLineVerticalLayout {
    CFIndex line;//第几行
    CGFloat lineAscentAndDescent;//上行高和下行高之和
    CGRect  lineRect;//当前行对应的CGRect
    
    CGFloat maxRunHeight;//当前行run的最大高度（不包括图片）
    CGFloat maxRunAscent;//CTRun的最大上行高
    
    CGFloat maxImageHeight;//图片的最大高度
    CGFloat maxImageAscent;//图片的最大上行高
    
    TLLabelVerticalAlignment verticalAlignment;//对齐方式（默认底部对齐）
};
typedef struct TLCTLineVerticalLayout TLCTLineVerticalLayout;

@interface TLTextTag: NSURL
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSValue *rangeValue;
@end

@interface TLRunItem : NSObject<NSCopying>
/// 所在CTLine的行高信息结构体
@property (nonatomic, assign) TLCTLineVerticalLayout lineVerticalLayout;
/// 选中后被填充背景色的复制视图的Y坐标
@property (nonatomic, assign) CGFloat selectCopyBackY;
/// 选中后被填充背景色的复制视图的高度
@property (nonatomic, assign) CGFloat selectCopyBackHeight;
///每个字符对应的CTRun 在屏幕坐标下的rect（原点在左上角），没有发生合并
@property (nonatomic, assign) CGRect withOutMergeBounds;


//与选择复制相关的属性
/// 字符在整段文本中的index值
@property (nonatomic, assign) NSInteger characterIndex;
// 字符在整段文本中的range值
@property (nonatomic, assign) NSRange characterRange;


/// 根据富文本计算得出信息，用于绘制选择区域
/// @param attributedString attributedString
/// @param rect rect
/// @param view view
+ (NSMutableArray<TLRunItem*>*)getItemsWith:(NSAttributedString *)attributedString textRect:(CGRect)rect view:(UITextView *)view;
@end

NS_ASSUME_NONNULL_END
