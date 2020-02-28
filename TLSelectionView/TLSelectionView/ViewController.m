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
    
    
    tView = [[MTTextView alloc] initWithFrame:CGRectMake(0, 88, 414, 200)];
    tView.backgroundColor = [UIColor redColor];
    [self.view addSubview:tView];
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:[self content1] attributes:@{NSFontAttributeName: ([UIFont systemFontOfSize:17])}];
//
//    ttView = [[UITextView alloc] initWithFrame:(CGRectMake(0, 300, 414, 200))];
//    ttView.backgroundColor = UIColor.yellowColor;
//    ttView.attributedText = attString;
//    [self.view addSubview:ttView];
//
//    tView.contentInset = UIEdgeInsetsZero;
    tView.backgroundColor = [UIColor greenColor];
    tView.attributedText = attString;
//    tView.scrollEnabled = false;
}

//
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [[TLSelectRangManager instance] hideSelectTextRangeView];
//
//    CGPoint point = CGPointZero;
//    // 计算每个ctrunref的信息
//
//    NSArray *allItems = [TLRunItem getItemsWith:tView.attributedText size:tView.contentSize view:tView];
//    TLRunItem *currentItem = [TLSelectRangManager currentItem:point allRunItemArray:allItems inset:0.5];
//
//    [[TLSelectRangManager instance] showSelectViewInCJLabel:tView
//                                                    atPoint:point
//                                                    runItem:currentItem
//                                               maxLineWidth:tView.frame.size.width
//                                            allRunItemArray:allItems
//                                              hideViewBlock:^() {
//    }];
//
//}


- (NSString  *)content1 {
//    return @"也比不也比不也比不也比不也比不也比不也比不spancer 🏀👨‍👩‍👧‍👦👨‍👩‍👧‍👦@张三";
    return @"示例三：选择复制\n\n支持复制，😆双击或者长按可唤起😁UIMenuController进行选择复制文本操作。\n设置`CJLabel`为可点击链点，并指定其字体大小粗体15，字体颜色蓝色，边框线颜色为橙黄色，边框线粗细为1，边框线圆角取默认值5，背景填充颜色为浅灰色；👻点击高亮时字体颜色红色，边框线为红色，点击背景色橘黄色👏。";
    return @"⛹🏼‍♀️👨‍👩‍👧‍👦👨‍👩‍👧‍👦👨‍👩‍👧‍👦👨‍👩‍👧‍👦👨‍👩‍👧‍👦👨‍👩‍👧‍👦👨‍👩‍👧‍👦 spancer✨”❤️[哭笑不得]🐶🏀不上陆[大便]@张三 ，也比不[大便]上陆@张三 @ @[呕吐]👻👑👑[哭笑不得]🐶不上陆@张三 @倍，也比不上陆@张三不上陆@张三 @李四客减少一个月的量，难以倍👑[哭笑不得]🐶🏀[呕吐]🐶🏀[吓]🐶🏀❤️[哭笑不得]🐶🏀[呕# 春天在他的眼 [干杯]aa ";
}

- (void)getInfo {
    
    NSMutableArray<TLRunItem *> *items = [TLRunItem getItemsWith:ttView.attributedText size:ttView.contentSize view:ttView];
    
    NSLog(@"%zd", items.count);
}


@end
