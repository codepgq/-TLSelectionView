//
//  RunItem.m
//  hh
//
//  Created by 盘国权 on 2020/2/27.
//  Copyright © 2020 pgq. All rights reserved.
//

#import "TLRunItem.h"
#import <CoreText/CoreText.h>
#import "TLCTLineLayoutModel.h"
#import "TLSelectRangManager.h"

NSString * const kTLImageAttributeName = @"kCJImageAttributeName";
NSString * const kTLImageLineVerticalAlignment = @"kCJImageLineVerticalAlignment";

#pragma mark - 用于标记的类


@implementation TLTextTag

@end


#pragma mark - TLRunItem
@implementation TLRunItem


- (id)copyWithZone:(NSZone *)zone {
    TLRunItem *item = [[[self class] allocWithZone:zone] init];
    
    item.withOutMergeBounds = self.withOutMergeBounds;
    
    item.lineVerticalLayout = self.lineVerticalLayout;
    
    item.selectCopyBackHeight = self.selectCopyBackHeight;
    
    item.selectCopyBackY = self.selectCopyBackY;
    
    item.characterIndex = self.characterIndex;
    
    item.characterRange = self.characterRange;
    return item;
}

#pragma mark - 公开方法

/// 根据富文本计算得出信息，用于绘制选择区域
/// @param attributedString attributedString
/// @param rect rect
/// @param view view
+ (NSMutableArray<TLRunItem*>*)getItemsWith:(NSAttributedString *)attributedString textRect:(CGRect)rect view:(UITextView *)view {
    return [self newGetItems:attributedString textRect:rect view:view];
}

#pragma mark - 私有方法

/// 生成每一行的必要参数保存
+ (TLCTLineVerticalLayout)CJCTLineVerticalLayoutFromLine:(CTLineRef)line
                                               lineIndex:(CFIndex)lineIndex
                                                  origin:(CGPoint)origin
                                              lineAscent:(CGFloat)lineAscent
                                             lineDescent:(CGFloat)lineDescent
                                             lineLeading:(CGFloat)lineLeading
{
    //上下行高
    CGFloat lineAscentAndDescent = lineAscent + fabs(lineDescent);
    //默认底部对齐
    TLLabelVerticalAlignment verticalAlignment = CJVerticalAlignmentBottom;
    
    CFArrayRef runs = CTLineGetGlyphRuns(line);
    CGFloat maxRunHeight = 0;
    CGFloat maxRunAscent = 0;
    CGFloat maxImageHeight = 0;
    CGFloat maxImageAscent = 0;
    for (CFIndex j = 0; j < CFArrayGetCount(runs); ++j) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, j);
        CGFloat runAscent = 0.0f, runDescent = 0.0f, runLeading = 0.0f;
        CGFloat runWidth = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &runAscent, &runDescent, &runLeading);
        NSDictionary *attDic = (__bridge NSDictionary *)CTRunGetAttributes(run);
        NSDictionary *imgInfoDic = attDic[kTLImageAttributeName];
        if (TLLabelIsNull(imgInfoDic)) {
            if (maxRunHeight < runAscent + fabs(runDescent)) {
                maxRunHeight = runAscent + fabs(runDescent);
                maxRunAscent = runAscent;
            }
        }else{
            if (maxImageHeight < runAscent + fabs(runDescent)) {
                maxImageHeight = runAscent + fabs(runDescent);
                maxImageAscent = runAscent;
                verticalAlignment = [imgInfoDic[kTLImageLineVerticalAlignment] integerValue];
            }
        }
    }
    
    //    CGRect lineBounds = CTLineGetBoundsWithOptions(line, 0);
    
    CGRect lineBounds = CTLineGetImageBounds(line, NULL);
    //每一行的起始点（相对于context）加上相对于本身基线原点的偏移量
    lineBounds.origin.x += origin.x;
    lineBounds.origin.y += origin.y;
    lineBounds.origin.y = lineBounds.origin.y - lineBounds.size.height;
    //        lineBounds.size.width = lineBounds.size.width + self.textInsets.left + self.textInsets.right;
    
    TLCTLineVerticalLayout lineVerticalLayout;
    lineVerticalLayout.line = lineIndex;
    lineVerticalLayout.lineAscentAndDescent = lineAscentAndDescent;
    lineVerticalLayout.lineRect = lineBounds;
    lineVerticalLayout.verticalAlignment = verticalAlignment;
    lineVerticalLayout.maxRunHeight = maxRunHeight;
    lineVerticalLayout.maxRunAscent = maxRunAscent;
    lineVerticalLayout.maxImageHeight = maxImageHeight;
    lineVerticalLayout.maxImageAscent = maxImageAscent;
    
    return lineVerticalLayout;
}


+ (NSMutableArray<TLRunItem*>*)newGetItems:(NSAttributedString *)attributedString textRect:(CGRect)rect view:(UITextView *)view {
    
    NSMutableArray *items = [NSMutableArray array];
    
    // 对attributedString进行设置
    NSMutableAttributedString *matt = [attributedString mutableCopy];
    
    __block int index = 0;
    [matt.string enumerateSubstringsInRange:NSMakeRange(0, [matt length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                NSLog(@"substring is %@", substring);
        TLTextTag *runUrl = nil;
        if (!runUrl) {
            NSString *urlStr = [NSString stringWithFormat:@"https://www.CJLabel%@",@(index)];
            runUrl = [TLTextTag URLWithString:urlStr];
        }
        runUrl.index = index;
        runUrl.rangeValue = [NSValue valueWithRange:substringRange];
        [matt addAttribute:NSLinkAttributeName
                     value:runUrl
                     range:substringRange];
        index++;
    }];
    
    
    // 1 拿到富文本
    NSAttributedString *attr = matt;
    
    // 2 得到ctframe
    
    // 2.1 通过NSAttributedString得到CTFramesetter
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attr);
    // 2.2 设置大小（如果这里填写的是实际大小，那么一定要足够是行数的高度的两倍，否则可能会导致获取行数的时候少一行）
    CGSize size = CGSizeMake(rect.size.width, 100000);
    // 2.3 创建一个path，相当于给他的绘制区域
    CGMutablePathRef path = CGPathCreateMutable();
    // 2.4 把size添加到path中
    CGPathAddRect(path, NULL, CGRectMake(0, 0, size.width, size.height));
    // 2.5 得到ctFrame
    CTFrameRef ctFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0, attr.length), path, NULL);
    
    // 3 获取行
    NSArray *lines = (NSArray *)CTFrameGetLines(ctFrame);
    
    // 4 获取每一行的起点（原点）坐标
    CGPoint origins[lines.count];
    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), origins);
    
    
    // 5 遍历每一行，得到每一行的数据信息
    // 5.1 新建一个数组，保存每一行的一些基本信息
    NSMutableArray<TLCTLineLayoutModel*> *verticalLayoutArray = [NSMutableArray arrayWithCapacity:3];
    
    for (int i = 0; i < lines.count; i++) {
        @autoreleasepool {
            // 得到line
            CTLineRef line = (__bridge CTLineRef)lines[i];
            
            // 得到行的bounds
            CGRect lineBounds = CTLineGetBoundsWithOptions(line, 0);
            // 新建 ascent descent leading
            CGFloat lineAscent = 0.0f, lineDescent = 0.0f, lineLeading = 0.0f;
            // 得到行款和上面的三个属性
            CGFloat lineWidth = CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
            
            // 计算每一行的rect
            CGRect lineFrame = CGRectMake(origins[i].x, 100000 - origins[i].y - lineAscent, lineWidth, MAX(lineBounds.size.height + lineLeading,(lineAscent + lineDescent + lineLeading)));
            
            // 把行的信息结构器化
            TLCTLineVerticalLayout layout = [self CJCTLineVerticalLayoutFromLine:line lineIndex:i origin:origins[i] lineAscent:lineAscent lineDescent:lineDescent lineLeading:lineLeading];
            layout.lineRect = lineFrame;
            
            // 把行的信息模型化
            TLCTLineLayoutModel *model = [[TLCTLineLayoutModel alloc] init];
            model.lineIndex = i;
            model.lineVerticalLayout = layout;
            model.selectCopyBackY = layout.lineRect.origin.y;
            model.selectCopyBackHeight = layout.lineRect.size.height;
            
            // 保存line信息
            [verticalLayoutArray addObject:model];
            
            // 得到每一行中的所有字符
            NSArray *runItems = [self getRuns:line lineFrame:lineFrame layout:layout];
            // 保存得到的字符信息
            [items addObjectsFromArray:runItems];
        }
    }
    
    // 释放资源
    CGPathRelease(path);
    CFRelease(framesetter);
    
    // 存储到单例中
    [TLSelectRangManager instance].verticalLayoutArray = verticalLayoutArray.mutableCopy;
    
    return items;
}

+ (NSMutableArray<TLRunItem*>*)getRuns:(CTLineRef)line lineFrame:(CGRect)lineFrame layout:(TLCTLineVerticalLayout)layout {
    // 新建数组保存每个字符的一些信息
    NSMutableArray *runItems = [NSMutableArray array];
    // 通过行得到每一行的字符数组
    NSArray *runs = (NSArray*)CTLineGetGlyphRuns(line);
    
    // 遍历数组，并且把得到的数据模型化
    for (int i = 0; i < runs.count; i++) {
        @autoreleasepool {
            // 得到每一个run
            CTRunRef run = (__bridge CTRunRef)runs[i];
            // 新建每个run的 ascent descent leading
            CGFloat runAscent = 0.0f, runDescent = 0.0f, runLeading = 0.0f;
            // 计算run的一些信息 宽度和上面的三个属性
            CGFloat runWidth = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &runAscent, &runDescent, &runLeading);
            // 得到run的bounds
            CGRect runBounds = CTRunGetImageBounds(run, NULL, CFRangeMake(0, 0));
            
            // 计算得出run的rect
            CGRect runFrame = CGRectMake(runBounds.origin.x + lineFrame.origin.x, lineFrame.origin.y, runWidth, lineFrame.size.height);
            
            // 把信息模型化
            TLRunItem *item = [[TLRunItem alloc] init];
            item.lineVerticalLayout = layout;
            item.selectCopyBackY = item.lineVerticalLayout.lineRect.origin.y;
            item.selectCopyBackHeight = item.lineVerticalLayout.lineRect.size.height;
            item.withOutMergeBounds = runFrame;
            
            // 计算字符位置和字符rang，复制/判断区域的时候使用
            NSInteger characterIndex = 0;
            NSRange substringRange = NSMakeRange(0, 0);
            
            NSDictionary *attributes = (__bridge NSDictionary *)CTRunGetAttributes(run);
            TLTextTag *runUrl = attributes[NSLinkAttributeName];
            if ([runUrl isKindOfClass:[TLTextTag class]]) {
                characterIndex = runUrl.index;
                substringRange = [runUrl.rangeValue rangeValue];
            }
            item.characterIndex = characterIndex;
            item.characterRange = substringRange;
            
            // 保存模型
            [runItems addObject:item];
        }
        
    }
    
    return  runItems;
}


@end
