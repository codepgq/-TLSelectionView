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
 
 
 
 如果把MMTextView的继承改为UILabel，就没有这个问题
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
    
    
    tView = [[MTTextView alloc] initWithFrame:CGRectMake(0, 88, 414, 200)];
    tView.backgroundColor = [UIColor redColor];
    [self.view addSubview:tView];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 0;// 字体的行间距
//    paragraphStyle.firstLineHeadIndent = 20.0f;//首行缩进
    paragraphStyle.alignment = NSTextAlignmentLeft;//（两端对齐的）文本对齐方式：（左，中，右，两端对齐，自然）
//    paragraphStyle.lineBreakMode = NSLineBreakByClipping;//结尾部分的内容以……方式省略 ( "...wxyz" ,"abcd..." ,"ab...yz")
//    paragraphStyle.headIndent = 20;//整体缩进(首行除外)
//    paragraphStyle.tailIndent = 20;//
//    paragraphStyle.minimumLineHeight = 10;//最低行高
//    paragraphStyle.maximumLineHeight = 20;//最大行高
//    paragraphStyle.paragraphSpacing = 15;//段与段之间的间距
//    paragraphStyle.paragraphSpacingBefore = 22.0f;//段首行空白空间/* Distance between the bottom of the previous paragraph (or the end of its paragraphSpacing, if any) and the top of this paragraph. */
//    paragraphStyle.baseWritingDirection = NSWritingDirectionLeftToRight;//从左到右的书写方向（一共➡️三种）
//    paragraphStyle.lineHeightMultiple = 15;/* Natural line height is multiplied by this factor (if positive) before being constrained by minimum and maximum line height. */
    paragraphStyle.hyphenationFactor = 0;//连字属性 在iOS，唯一支持的值分别为0和1

    
    
//    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:[self content1] attributes:@{NSFontAttributeName: ([UIFont systemFontOfSize:17]), NSParagraphStyleAttributeName: paragraphStyle}];
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:[self content1] attributes:nil];
//
    
    ttView = [[UITextView alloc] initWithFrame:(CGRectMake(0, 300, 414, 200))];
    ttView.backgroundColor = UIColor.yellowColor;
    ttView.attributedText = attString;
    ttView.backgroundColor = [UIColor redColor];
    [self.view addSubview:ttView];
//
    tView.contentInset = UIEdgeInsetsZero;
    tView.backgroundColor = [UIColor greenColor];
    tView.attributedText = attString;
    tView.scrollEnabled = false;
    tView.font = [UIFont systemFontOfSize:20];
    tView.selectable = false;
    tView.textContainerInset = UIEdgeInsetsZero;
    tView.textContainer.lineFragmentPadding = 0;
    tView.contentOffset = CGPointZero;
    tView.userInteractionEnabled = true;
    tView.editable = false;
    tView.selectable = false;
    tView.scrollEnabled = false;
    
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

    
    
}


- (NSString  *)content1 {
//    return @"也比不也比不也比不也比不也比不也比不也比不spancer 🏀👨‍👩‍👧‍👦👨‍👩‍👧‍👦@张三";
//    return @"示例三：选择复制支持复制，双击或者长按可唤起UIMenuController进行选择复制文本操作。设置`CJLabel`为可点击链点，并指定其字体大小粗体15，字体颜色蓝色，边框线颜色为橙黄色，边框线粗细为1，边框线圆角取默认值5，背景填充颜色为浅灰色；👻点击高亮时字体颜色红色，边框线为红色，点击背景色橘黄色👏。";
    return @"示例三：选择复制支持复制，😆双击或者长按可唤起😁UIMenuController进行选择复制文本操作。设置`CJLabel`为可点击链点，并指定其字体大小粗体15，字体颜色蓝色，边框线颜色为橙黄色，边框线粗细为1，边框线圆角取默认值5，背景填充颜色为浅灰色；👻点击高亮时字体颜色红色，边框线为红色，点击背景色橘黄色👏。";
//    return @"⛹🏼‍♀️👨‍👩‍👧‍👦👨‍👩‍👧‍👦👨‍👩‍👧‍👦👨‍👩‍👧‍👦👨‍👩‍👧‍👦👨‍👩‍👧‍👦👨‍👩‍👧‍👦 spancer✨”❤️[哭笑不得]🐶🏀不上陆[大便]@张三 ，也比不[大便]上陆@张三 @ @[呕吐]👻👑👑[哭笑不得]🐶不上陆@张三 @倍，也比不上陆@张三不上陆@张三 @李四客减少一个月的量，难以倍👑[哭笑不得]🐶🏀[呕吐]🐶🏀[吓]🐶🏀❤️[哭笑不得]🐶🏀[呕# 春天在他的眼 [干杯]aa ";
}

- (void)getInfo {
    
//    NSMutableArray<TLRunItem *> *items = [TLRunItem getItemsWith:ttView.attributedText textRect:CGRectMake(0, 0, 0, 0) view:ttView];
//
//    NSLog(@"%zd", items.count);
}


@end
