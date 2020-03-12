//
//  ViewController.m
//  TLSelectionView
//
//  Created by 盘国权 on 2020/2/28.
//  Copyright © 2020 pgq. All rights reserved.
//
/**
 http://blog.cnbang.net/tech/2729/?utm_source=tuicool CoreText 渲染介绍
 
 https://www.jianshu.com/u/a97f1b616991 CJLabel的简书地址、
 https://www.jianshu.com/p/7de3e6d19e31 CJLabel富文本三 —— UILabel支持选择复制以及实现原理
 https://www.jianshu.com/p/9a70533d217e CJLabel图文混排二 —— UILabel插入图片以及精确链点点击
 https://www.jianshu.com/p/b15455d7d30d CJLabel图文混排一 ——UILabel富文本显示以及任意字符的点击响应
 
 https://github.com/GIKICoder/GRichLabel 这个也是富文本框架，也是View，有类似微信的效果。已经封装好了 但是依赖其他库
 

 */


#import "ViewController.h"
#import "MTTextView.h"
#import <CoreText/CoreText.h>
#import "TLRunItem.h"
#import "TLCTLineLayoutModel.h"
#import "TLSelectRangManager.h"



@interface ViewController ()

@end

@implementation ViewController {
    MTTextView *tView ;
    UITextView *ttView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    tView = [[MTTextView alloc] initWithFrame:CGRectMake(0, 88, 300, 200)];
//    tView.backgroundColor = [UIColor redColor];
    [self.view addSubview:tView];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 3;// 字体的行间距
//    paragraphStyle.firstLineHeadIndent = 20.0f;//首行缩进
    paragraphStyle.alignment = NSTextAlignmentNatural;//（两端对齐的）文本对齐方式：（左，中，右，两端对齐，自然）
//    paragraphStyle.lineBreakMode = NSLineBreakByClipping;//结尾部分的内容以……方式省略 ( "...wxyz" ,"abcd..." ,"ab...yz")
//    paragraphStyle.headIndent = 20;//整体缩进(首行除外)
//    paragraphStyle.tailIndent = 20;//
//    paragraphStyle.minimumLineHeight = 10;//最低行高
//    paragraphStyle.maximumLineHeight = 20;//最大行高
//    paragraphStyle.paragraphSpacing = 15;//段与段之间的间距
//    paragraphStyle.paragraphSpacingBefore = 22.0f;//段首行空白空间/* Distance between the bottom of the previous paragraph (or the end of its paragraphSpacing, if any) and the top of this paragraph. */
//    paragraphStyle.baseWritingDirection = NSWritingDirectionLeftToRight;//从左到右的书写方向（一共➡️三种）
//    paragraphStyle.lineHeightMultiple = 15;/* Natural line height is multiplied by this factor (if positive) before being constrained by minimum and maximum line height. */
//    paragraphStyle.hyphenationFactor = 1;//连字属性 在iOS，唯一支持的值分别为0和1

    
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:[self content1] attributes:@{NSFontAttributeName: ([UIFont systemFontOfSize:15]), NSParagraphStyleAttributeName: paragraphStyle}];
    
//    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:[self content1] attributes:nil];
//
    
//    ttView = [[UITextView alloc] initWithFrame:(CGRectMake(0, 400, 414, 200))];
//    ttView.backgroundColor = UIColor.yellowColor;
//    ttView.attributedText = attString;
//    ttView.backgroundColor = [UIColor redColor];
//    [self.view addSubview:ttView];
//
    tView.contentInset = UIEdgeInsetsZero;
    tView.attributedText = attString;
    tView.font = [UIFont systemFontOfSize:15];
    tView.textContainerInset = UIEdgeInsetsZero;
    tView.textContainer.lineFragmentPadding = 0;
    tView.contentOffset = CGPointZero;
    tView.userInteractionEnabled = true;
    tView.editable = false;
    tView.selectable = false;
    tView.scrollEnabled = false;
    tView.clipsToBounds  =false;
    
    [tView addLongPressEvent];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGSize constraintSize = CGSizeMake(tView.frame.size.width, MAXFLOAT);

    CGSize size = [tView sizeThatFits:constraintSize];
//    CGSize size = tView.contentSize;
    CGRect rect = tView.frame;
    rect.size.width = size.width;
    rect.size.height = size.height;
    tView.frame = rect;

}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    NSAttributedString *attStr = [[TLSelectRangManager instance] selectArrtibutedString];
//    NSString *str = [[TLSelectRangManager instance] selectStringWithIsCopy:true];
//    
//    NSLog(@"att %@  \nstr %@", attStr, str);

    
    [self getInfo];
    
    
}


- (NSString  *)content1 {
    return @"🚗大风大浪考试啊江东父老；阿三等奖大量的副科级拉萨地方拉上看到飞机撒短发🚕阿隆索飞机撒发达上的粉丝短发撒放撒短发撒短发师大撒放撒短发撒的撒短发撒短发师大🚗大风大浪考试啊江东父老；阿三等奖大量的副科级拉萨地方拉上看到飞机撒短发🚕阿隆索飞机撒发达上的粉丝短发撒放撒短发撒短发师大撒放撒短发撒的撒短发撒短发师大🚗大风大浪考试啊江东父老；阿三等奖大量的副科级拉萨地方拉上看到飞机撒短发🚕阿隆索飞机撒发达上的粉丝短发撒放撒短发撒短发师大撒放撒短发撒的撒短发撒短发师大🚗大风大浪考试大撒放撒短发撒的撒短发撒短发师大🚗大风大浪考试啊江东父老；阿三等奖大量的副科级拉萨地方拉上看到飞机撒短发🚕阿隆索飞机撒发达上的粉丝短发撒放撒短发撒短发师大撒放撒短发撒的撒短发撒短发师大🚗大风大浪考试啊江东父老；阿三等奖大量的副科级拉萨地方拉上看到飞机撒短发🚕阿隆索飞机撒发达上的粉丝短发撒放撒短发撒短发师大撒放撒短发撒的撒短发撒短发师大🚗大风大浪考试啊江东父老；阿三等奖大量的副科级拉萨地方拉上看到飞机撒短发🚕阿隆索飞机撒发达上的粉丝短发撒放撒短发撒短发师大撒放撒短发撒的撒短发撒短发师大";
    return @"Conclusion: in today\'s rapid development of society, the network is not difficult, want to go to query history rewriting history doesn\'t have any meaning, the Japanese government not only is there no silver three hundred and twenty, for our own, we can do is to remember at the beginning that history, if not the dark ages, courage to stand up and patriotic hero, there would be no we now peaceful s happy life. What do you have to say to the Japanese who would rather be tricked into pretending to sleep? Welcome to share the discussion in the comment area, the progress of The Times and the changes of history, I will be with you! Conclusion: in today\'s rapid development of society, the network is not difficult, want to go to query history rewriting history doesn\'t have any meaning, the Japanese government not only is there no silver three hundred and twenty, for our own, we can do is to remember at the beginning that history, if not the dark ages, courage to stand up and patriotic hero, there would be no we now peaceful s happy life. What do you have to say to the Japanese who would rather be tricked into pretending to sleep? Welcome to share the discussion in the comment area, the progress of The Times and the changes of history, I will be with you!";
//    return @"@李四客减少一个月的量，难以倍🏀❤️[哭笑不得]🐶也比不上🏀[呕吐]👻👑@李四客减少一个月的量，难以倍，也比不上陆@张三不上陆@张三 @李四客减少一个月的量，难以倍👑[哭笑不得]🐶🏀[呕吐]🐶🏀[吓]🐶🏀❤️[哭笑不得]🐶🏀[呕吐]👻👑👑[哭笑不得]🐶🏀[呕吐]🐶🏀[吓]🐶也比不上🏀也比不上❤️也比不上[哭笑不得]🐶🏀也比不上[呕吐]👻也比不上👑👑[哭笑不得]🐶🏀[呕吐]🐶🏀也比不上[吓]🐶也比不上🏀倍，也比不上陆@张三 @王金11🐶[干杯]🐶春天在哪里，🐶[哭笑不得]🐶春/n天@在你的眼睛里，oh, myaa god, @张三:18\n900126257 @李四 @巩柯 #王五# 春天在他的眼 [干杯]aa 睛里，春天在你aa我的眼睛里你的两岸观光进入寒冬，陆客赴bb台人数持续缩减。据台湾《经济日报》23日报道，民\n党当局转向冲刺“新南向”的bb客源，[哭笑不得]锁定菲律宾、越南、文莱、泰国、印度尼西亚和印度等，积极宣传及放宽来台“签证”措施。统计显示，蔡英文上任前一年de我，这些地区来台旅客数为65.我9万人次放宽后这一年增加到9";
//    return @"也比不也比不也比不也比不也比不也比不也比不spancer 🏀👨‍👩‍👧‍👦👨‍👩‍👧‍👦@张三";
    return @"示例三：选择复制支持复制，双击或者长按可唤起UIMenuController进行选择复制文本操作。设置`CJLabel`为可点击链点，并指定其字体大小粗体15，字体颜色蓝色，边框线颜色为橙黄色，边框线粗细为1，边框线圆角取默认值5，背景填充颜色为浅灰色；👻点击高亮时字体颜色红色，边框线为红色，点击背景色橘黄色👏。";
    return @"示例三：选择复制\n\n支持复制，😆双击或者长按可唤起😁UIMenuController进行选择复制文本操作。\n设置`CJLabel`为可点击链点，并指定其字体大小粗体15，字体颜色蓝色，边框线颜色为橙黄色，边框线粗细为1，边框线圆角取默认值5，背景填充颜色为浅灰色；👻点击高亮时字体颜色红色，边框线为红色，点击背景色橘黄色👏。";
//    return @"⛹🏼‍♀️👨‍👩‍👧‍👦👨‍👩‍👧‍👦👨‍👩‍👧‍👦👨‍👩‍👧‍👦👨‍👩‍👧‍👦👨‍👩‍👧‍👦👨‍👩‍👧‍👦 spancer✨”❤️[哭笑不得]🐶🏀不上陆[大便]@张三 ，也比不[大便]上陆@张三 @ @[呕吐]👻👑👑[哭笑不得]🐶不上陆@张三 @倍，也比不上陆@张三不上陆@张三 @李四客减少一个月的量，难以倍👑[哭笑不得]🐶🏀[呕吐]🐶🏀[吓]🐶🏀❤️[哭笑不得]🐶🏀[呕# 春天在他的眼 [干杯]aa ";
}

- (void)getInfo {
    
    NSMutableAttributedString *matt = [tView.attributedText mutableCopy];
        
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
    
    
    // 1 拿到富文本
    NSAttributedString *attr = matt;
    
    // 2 得到ctframe
     
    // 2.1 通过NSAttributedString得到CTFramesetter
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attr);
    // 2.2 设置大小（如果这里填写的是实际大小，那么一定要足够是行数的高度的两倍，否则可能会导致获取行数的时候少一行）
    CGSize size = CGSizeMake(tView.frame.size.width, 100000);
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
    
    [tView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == 1001) {
            [obj removeFromSuperview];
        }
    }];
    
    // 5 遍历每一行，得到每一行的数据信息
    CGFloat lastLineHeight = 0;
    CGFloat offsetY = 0;
    for (int i = 0; i < lines.count; i++) {
        CTLineRef line = (__bridge CTLineRef)lines[i];
        
        CGRect lineBounds = CTLineGetBoundsWithOptions(line, 0);
        CGFloat lineAscent = 0.0f, lineDescent = 0.0f, lineLeading = 0.0f;
        CGFloat lineWidth = CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
        
        // 计算每一行的rect，测试ok
        CGRect lineFrame = CGRectMake(origins[i].x, 100000 - origins[i].y - lineAscent + offsetY, lineWidth, MAX(lineBounds.size.height + lineLeading,(lineAscent + lineDescent + lineLeading)));
        
        if ((100000 - origins[i].y - lineAscent) != lineFrame.origin.y) {
            origins[i].y = lineFrame.origin.y;
        }
        
//        lineFrame.origin.y += offsetY;
//        lastLineHeight = MAX(lineFrame.size.height, lastLineHeight);
        UIView *lineView = [[UIView alloc] initWithFrame:lineFrame];
        lineView.tag = 1001;
        lineView.backgroundColor = (i % 2 == 0)
            ? [[UIColor blueColor] colorWithAlphaComponent:0.5]
            : [[UIColor redColor] colorWithAlphaComponent:0.5];
        [tView addSubview:lineView];
//
//        if (i == 5) {
//            NSLog(@"出问题了");
//        }
//        NSLog(@"aaa %@", NSStringFromCGRect(lineBounds));
//        NSLog(@"bbb %@", NSStringFromCGRect(CGRectMake(origins[i].x, 100000 - origins[i].y - lineAscent, lineWidth, lineAscent + lineDescent)));
//        NSLog(@"ccc %@", NSStringFromCGRect(lineFrame));
//        // 测试每一个字的rect
        
        
        [self getRuns:line lineFrame:lineFrame origins:origins lineIndex:i];
        
//
//        if (lineFrame.size.height < lastLineHeight) {
//            offsetY += (lastLineHeight - lineFrame.size.height);
//        }
//        if (lineFrame.size.height > lastLineHeight) {
//            offsetY += (lineFrame.size.height - lastLineHeight);
//        }
//        lastLineHeight = lineFrame.size.height;
    }
    
    
}

- (void)getRuns:(CTLineRef)line lineFrame:(CGRect)lineFrame origins:(CGPoint*)origins lineIndex:(int)lineIndex{
    NSArray *runs = (NSArray*)CTLineGetGlyphRuns(line);
    
    for (int i = 0; i < runs.count; i++) {
        CTRunRef run = (__bridge CTRunRef)runs[i];
        CGFloat runAscent = 0.0f, runDescent = 0.0f, runLeading = 0.0f;
        CGRect runBounds = CTRunGetImageBounds(run, NULL, CFRangeMake(0, 0));
        CGFloat runWidth = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &runAscent, &runDescent, &runLeading);
        
        NSLog(@"%@", NSStringFromCGRect(runBounds));
        NSLog(@"%@", NSStringFromCGRect(CGRectMake(origins[lineIndex].x, 100000 - origins[lineIndex].y - runAscent, runWidth, runAscent + runDescent)));
        
        CGRect runFrame = CGRectMake(runBounds.origin.x + lineFrame.origin.x, lineFrame.origin.y, runWidth, lineFrame.size.height);
//
//        UIView *runView = [[UIView alloc] initWithFrame:runFrame];
//        runView.tag = 1001;
//        runView.backgroundColor = (i % 2 == 0)
//        ? [[UIColor blueColor] colorWithAlphaComponent:0.5]
//        : [[UIColor redColor] colorWithAlphaComponent:0.5];
//        [tView addSubview:runView];
        
        
        
        
    }
}


@end
