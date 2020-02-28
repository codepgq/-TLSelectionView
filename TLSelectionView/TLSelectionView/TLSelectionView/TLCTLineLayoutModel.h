//
//  TLCTLineLayoutModel.h
//  hh
//
//  Created by 盘国权 on 2020/2/27.
//  Copyright © 2020 pgq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TLRunItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface TLCTLineLayoutModel : NSObject
@property (nonatomic, assign) CFIndex lineIndex;//第几行
@property (nonatomic, assign) TLCTLineVerticalLayout lineVerticalLayout;//所在CTLine的行高信息结构体

@property (nonatomic, assign) CGFloat selectCopyBackY;//选中后被填充背景色的复制视图的Y坐标
@property (nonatomic, assign) CGFloat selectCopyBackHeight;//选中后被填充背景色的复制视图的高度
@end

NS_ASSUME_NONNULL_END
