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
@interface TLTextTag: NSURL
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSValue *rangeValue;
@end

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
    
    // 保存item用的数组
    __block NSMutableArray *items = [NSMutableArray array];
    
    
    NSMutableAttributedString *matt = attributedString.mutableCopy;
    
    __block int index = 0;
    [matt.string enumerateSubstringsInRange:NSMakeRange(0, [matt length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
//        NSLog(@"substring is %@", substring);
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
    
    NSAttributedString *attributedM = matt;
//    view.attributedText = matt;
    // 1、根据attstring 得到工厂类
    // 生成工厂类
//    CTFramesetterRef  framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedM);
//
//    // 2、得到ctframe
    static CGRect _pathRect;
    _pathRect = rect;
////    rect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeScale(1, -1));
//    CGPathRef path = CGPathCreateWithRect(rect, NULL);
//
//    CFRange range = CFRangeMake(0, CFAttributedStringGetLength((__bridge CFAttributedStringRef)attributedString));
//    CTFrameRef ctFrame = CTFramesetterCreateFrame(framesetter, range, path, NULL);

    // 3、得到lines
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedM);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,rect.size.width,100000));
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    
    // 根据lines获取每一行的原点信息
    CGPoint origins[lines.count];//the origins of each line at the baseline
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
   
    CGRect lineRects[lines.count];
    for (int i = 0; i<lines.count; i++) {
        CTLineRef lineRef = (__bridge CTLineRef )lines[i];
        CGFloat lineAscent = 0.0f, lineDescent = 0.0f, lineLeading = 0.0f;
        CGFloat lineWidth = CTLineGetTypographicBounds(lineRef, &lineAscent, &lineDescent, &lineLeading);
        lineRects[i] = CGRectMake(origins[i].x, 100000 - origins[i].y - lineAscent + lineLeading, lineWidth, lineAscent + fabs(lineDescent) + lineLeading);
        if (lineDescent < 0) {
            NSLog(@"dddddddddd");
        }
        
        if (lineAscent < 0) {
            NSLog(@"fffffffffffff");
        }
        
        if (lineLeading < 0) {
            NSLog(@"llllllllllllllll");
        }
        NSLog(@"%.2f %.2f %.2f", lineAscent, lineDescent, lineLeading);
        NSLog(@"lineRects %@ ", NSStringFromCGRect(lineRects[i]));
    }
    
    
    // 新建一个数组，保存每一行的一些基本信息
    NSMutableArray<TLCTLineLayoutModel*> *verticalLayoutArray = [NSMutableArray arrayWithCapacity:3];
    
    // 行下标
    NSUInteger lineIndex = 0;
    TLCTLineVerticalLayout layout;
    CGFloat maxDescent = 0;
    for (id lineObj in lines) {
        // 获取行
        CTLineRef line = (__bridge CTLineRef)lineObj;
        // 计算每一行的 ascent descent leading
        CGFloat lineAscent = 0.0f, lineDescent = 0.0f, lineLeading = 0.0f;
        CGRect AlineRect = CGRectZero;
        
        // 把上面的信息转化为model，记录起来
        layout = [self CJCTLineVerticalLayoutFromLine:line lineIndex:lineIndex origin:origins[lineIndex] lineAscent:lineAscent lineDescent:lineDescent lineLeading:lineLeading];
#if false // 之前的行高算法
        layout.lineRect.origin.y = origins[0].y - layout.lineRect.origin.y - layout.lineRect.size.height;
#else
        CGFloat AlineWidth = CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
        maxDescent = MAX(maxDescent, lineDescent);
        CGPoint AlineOrigin = origins[lineIndex];
        CGPoint AlinePoint;
        AlinePoint.y = _pathRect.size.height - AlineOrigin.y - lineAscent + lineDescent;
        if (lineIndex > 0) {
            AlinePoint.y += lineLeading + view.contentInset.top + view.textContainerInset.top;
        }
        if (lineIndex == 0) {
            AlinePoint.y = 0 + view.contentInset.top + view.textContainerInset.top;
        }
        AlinePoint.x = _pathRect.origin.x + AlineOrigin.x;
        AlineRect = CGRectMake(AlinePoint.x, AlinePoint.y, AlineWidth, CTLineGetBoundsWithOptions(line, 0).size.height);
        NSLog(@"height: %.2f maxRunAscent %.2f maxRunHeight %.2f", AlineRect.size.height, layout.maxRunAscent, layout.maxRunHeight);
        AlineRect.size.height = layout.maxRunHeight;
        layout.lineRect = lineRects[lineIndex];
#endif
        TLCTLineLayoutModel *model = [[TLCTLineLayoutModel alloc] init];
        model.lineIndex = lineIndex;
        model.lineVerticalLayout = layout;
        model.selectCopyBackY = layout.lineRect.origin.y;
        model.selectCopyBackHeight = layout.lineRect.size.height;
        
        // 保存line信息
        [verticalLayoutArray addObject:model];
        
        NSLog(@"xxxxxx \n%@\n%@", NSStringFromCGRect(layout.lineRect),NSStringFromCGRect(AlineRect));
        
        // 得到每一行中的所有的CTRunRef对象，从而计算得到每个字符的位置大小
        NSArray *runs = ((NSArray *)CTLineGetGlyphRuns(line));
        for (int idx = 0; idx < runs.count; idx++) {
            // 得到run
            CTRunRef run = (__bridge CTRunRef)(runs[idx]);
            // 获取字符的range
//            CFRange runRange = CTRunGetStringRange(run);

            // 用来保存run的大小位置
            CGRect runBounds;

            // 每个字符的ascent desecnt leading
            CGFloat ascent;// height above the baseline
            CGFloat descent;// height below the baseline
            CGFloat leading;
            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
            runBounds.size.height = ascent + descent;

            // 计算x的偏移量
            CGFloat xOffset = 0;
            CFRange glyphRange = CTRunGetStringRange(run);
            switch (CTRunGetStatus(run)) {
                case kCTRunStatusRightToLeft:
                    xOffset = CTLineGetOffsetForStringIndex(line, glyphRange.location + glyphRange.length, NULL);
                    break;
                default:
                    xOffset = CTLineGetOffsetForStringIndex(line, glyphRange.location, NULL);
                    break;
            }
            
            // 计算y坐标
            runBounds.origin.x = origins[lineIndex].x + rect.origin.x + xOffset;
            runBounds.origin.y = origins[lineIndex].y + rect.origin.y;
            runBounds.origin.y -= descent;
            
//            NSLog(@"每一个runitem的信息 %@", NSStringFromCGRect(runBounds));
            
            // 把CTRunRef转化为model保存起来
            TLRunItem *item = [[TLRunItem alloc] init];
            item.lineVerticalLayout = layout;
            item.selectCopyBackY = item.lineVerticalLayout.lineRect.origin.y;
            item.selectCopyBackHeight = item.lineVerticalLayout.lineRect.size.height;
            
            //转换为UIKit坐标系统
            CGRect locBounds = [TLRunItem convertRectFromLoc:runBounds view:view];
            
            
            CGFloat withOutMergeBoundsY = item.lineVerticalLayout.lineRect.origin.y - (MAX(item.lineVerticalLayout.maxRunAscent, item.lineVerticalLayout.maxImageAscent) - item.lineVerticalLayout.lineRect.size.height);
            item.withOutMergeBounds =
            CGRectMake(locBounds.origin.x,
                       withOutMergeBoundsY,
                       locBounds.size.width,
                       MAX(item.lineVerticalLayout.maxRunHeight, item.lineVerticalLayout.maxImageHeight));
            
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
            [items addObject:item];
        };
        lineIndex++;
    }
    
    // 释放资源
    CGPathRelease(path);
    CFRelease(framesetter);
    
    // 存储到单例中
    [TLSelectRangManager instance].verticalLayoutArray = verticalLayoutArray.mutableCopy;
    
    // 返回已经计算完的模型数组
    return items;
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

+ (NSArray*)getLines:(NSAttributedString*)attStr width:(CGFloat)width{
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attStr);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,width,100000));
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    return lines;
}

/**
 将系统坐标转换为屏幕坐标
 
 @param rect 坐标原点在左下角的 rect
 @return 坐标原点在左上角的 rect
 */
+ (CGRect)convertRectFromLoc:(CGRect)rect view:(UIView *)view {
    
    CGRect resultRect = CGRectZero;
    CGFloat labelRectHeight = view.bounds.size.height; //- view.textInsets.top - self.textInsets.bottom - _translateCTMty;
    CGFloat y = labelRectHeight - rect.origin.y - rect.size.height;
    
    resultRect = CGRectMake(rect.origin.x, y, rect.size.width, rect.size.height);
    return resultRect;
}

/*
+ (NSMutableArray<TLRunItem*>*)ItemsWith:(NSAttributedString *)attributedString size:(CGSize)size view:(UIView *)view  {
    
    // 保存item用的数组
    __block NSMutableArray *items = [NSMutableArray array];
    
    
    NSMutableAttributedString *matt = attributedString.mutableCopy;
    
    __block int index = 0;
    [matt.string enumerateSubstringsInRange:NSMakeRange(0, [matt length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        
        TextTag *runUrl = nil;
        if (!runUrl) {
            NSString *urlStr = [NSString stringWithFormat:@"https://www.CJLabel%@",@(index)];
            runUrl = [TextTag URLWithString:urlStr];
        }
        runUrl.index = index;
        runUrl.rangeValue = [NSValue valueWithRange:substringRange];
        [matt addAttribute:NSLinkAttributeName
                     value:runUrl
                     range:substringRange];
        index++;
    }];
    
    NSAttributedString *attributedM = matt;
    // 1、根据attstring 得到工厂类
    // 生成工厂类
    CTFramesetterRef  framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedM);
    
    // 2、得到ctframe
    CGRect rect = (CGRect){CGPointZero, size};
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, rect);
    
    CFRange range = CFRangeMake(0, CFAttributedStringGetLength((__bridge CFAttributedStringRef)attributedM));
    CTFrameRef ctFrame = CTFramesetterCreateFrame(framesetter, range, path, NULL);

    NSArray *lines = (NSArray *)CTFrameGetLines(ctFrame);

    __block CGPoint *origins;//the origins of each line at the baseline
    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), origins);

    NSMutableArray <TLCTLineLayoutModel*>*verticalLayoutArray = [NSMutableArray arrayWithCapacity:3];
    NSUInteger lineIndex = 0;
    TLCTLineVerticalLayout layout;
    for (id lineObj in lines) {
        CTLineRef line = (__bridge CTLineRef)lineObj;
        
        CGFloat lineAscent = 0.0f, lineDescent = 0.0f, lineLeading = 0.0f;
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
        layout = [self CJCTLineVerticalLayoutFromLine:line lineIndex:lineIndex origin:origins[lineIndex] lineAscent:lineAscent lineDescent:lineDescent lineLeading:lineLeading];
        layout.lineRect.origin.y = origins[0].y - layout.lineRect.origin.y - layout.lineRect.size.height;
        TLCTLineLayoutModel *model = [[TLCTLineLayoutModel alloc] init];
        model.lineIndex = lineIndex;
        model.lineVerticalLayout = layout;
        model.selectCopyBackY = layout.lineRect.origin.y;
        model.selectCopyBackHeight = layout.lineRect.size.height;
        [verticalLayoutArray addObject:model];
        NSLog(@"xxxxxx %@", NSStringFromCGRect(layout.lineRect));
        
        NSArray *runs = ((NSArray *)CTLineGetGlyphRuns(line));
        for (int idx = 0; runs.count; idx++) {
            CTRunRef run = (__bridge CTRunRef)(runs[idx]);
            CFRange runRange = CTRunGetStringRange(run);

            CGRect runBounds;

            CGFloat ascent;//height above the baseline
            CGFloat descent;//height below the baseline
            CGFloat leading;
            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
            runBounds.size.height = ascent + descent;

            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
            runBounds.origin.x = origins[lineIndex].x + rect.origin.x + xOffset;
            runBounds.origin.y = origins[lineIndex].y + rect.origin.y;
            runBounds.origin.y -= descent;

            //do something with runBounds
            
            NSLog(@"每一个runitem的信息 %@", NSStringFromCGRect(runBounds));
            
            
            TLRunItem *item = [[TLRunItem alloc] init];
            [item setLineVerticalLayout:[verticalLayoutArray[lineIndex] lineVerticalLayout]];
            item.selectCopyBackY = item.lineVerticalLayout.lineRect.origin.y;
            item.selectCopyBackHeight = item.lineVerticalLayout.lineRect.size.height;
            
            //转换为UIKit坐标系统
            CGRect locBounds = [TLRunItem convertRectFromLoc:runBounds view:view];
            
            
            CGFloat withOutMergeBoundsY = item.lineVerticalLayout.lineRect.origin.y - (MAX(item.lineVerticalLayout.maxRunAscent, item.lineVerticalLayout.maxImageAscent) - item.lineVerticalLayout.lineRect.size.height);
            item.withOutMergeBounds =
            CGRectMake(locBounds.origin.x,
                       withOutMergeBoundsY,
                       locBounds.size.width,
                       MAX(item.lineVerticalLayout.maxRunHeight, item.lineVerticalLayout.maxImageHeight));
            [items addObject:item];
        };
        lineIndex++;
    }
    
    [TLSelectRangManager instance].verticalLayoutArray = verticalLayoutArray.mutableCopy;
    return items;
}
*/
@end
