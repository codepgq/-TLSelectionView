//
//  TLSelectRangManager.m
//  hh
//
//  Created by 盘国权 on 2020/2/27.
//  Copyright © 2020 pgq. All rights reserved.
//

#import "TLSelectRangManager.h"
#import "TLCTLineLayoutModel.h"
#import "TLSelectTextRangeView.h"

#pragma mark - 内部私有类 TLWindowView

/**
 添加在window层的view，用来检测点击任意view时隐藏CJSelectBackView
 */
@interface TLWindowView : UIView
@property (nonatomic, copy) void(^hitTestBlock)(BOOL hide);
@end
@implementation TLWindowView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!CGRectContainsPoint(self.bounds, point)) {
        self.hitTestBlock(YES);
    }
    return nil;
}
@end

/**
 大头针的显示类型
 */
typedef NS_ENUM(NSInteger, TLSelectViewAction) {
    ShowAllSelectView    = 0,//显示大头针（长按或者双击）
    MoveLeftSelectView   = 1,//移动左边大头针
    MoveRightSelectView  = 2 //移动右边大头针
};

typedef void(^TLSelectRangManagerBlock)(void);

@interface TLSelectRangManager()
/// 输入视图
@property (nonatomic,weak) UITextView *view;
/// 富文本
@property (nonatomic,strong) NSAttributedString *attributedText;
/// 字体
@property (nonatomic,strong) UIFont *font;
/// 大小
@property (nonatomic,assign) CGRect frame;
/// 选择类型
@property (nonatomic,assign) TLSelectViewAction selectViewAction;
/// 消失的block
@property (nonatomic,copy) TLSelectRangManagerBlock hideBlock;
/// 添加在window层的view，用来检测点击任意view时隐藏CJSelectBackView
@property (nonatomic, strong) TLWindowView *backWindView;
// 记录textview所属的superview数组
@property (nonatomic, strong) NSMutableArray *scrlooViewArray;
/// 长按手势
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@end

@implementation TLSelectRangManager {
    CGFloat _lineVerticalMaxWidth; // 当前行的最大宽度
    CGFloat _startCopyRunItemY;//_startCopyRunItem Y坐标 显示Menu（选择、全选、复制菜单时用到）
    
    TLRunItem *_firstRunItem;//第一个StrokeItem
    TLRunItem *_lastRunItem;//最后一个StrokeItem
    TLRunItem *_startCopyRunItem;//选中复制的第一个StrokeItem
    TLRunItem *_endCopyRunItem;//选中复制的最后一个StrokeItem
    
    NSArray <TLRunItem *>*_allRunItemArray;//CJLabel包含所有CTRun信息的数组
    
    BOOL _haveMove;
}

#pragma mark - Public Method
+ (instancetype)instance {
    static TLSelectRangManager *manager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[TLSelectRangManager alloc] initWithFrame:CGRectZero];
        manager.backgroundColor = [UIColor clearColor];

        manager.backWindView = [[TLWindowView alloc]initWithFrame:CGRectMake(0, 0, 1, 1)];
        __weak typeof(manager)wManager = manager;
        manager.backWindView.hitTestBlock = ^(BOOL hide) {
            [wManager hideSelectTextRangeView];
        };        /*
         *选择复制填充背景色视图
         */
        manager.textRangeView = [[TLSelectTextRangeView alloc]init];
        manager.textRangeView.hidden = YES;
        [manager addSubview:manager.textRangeView];
//        //放大镜
//        manager.magnifierView = [[CJMagnifierView alloc] initWithFrame:CGRectMake(0, 0, 120, 44)];

//        manager.singleTapGes =[[UITapGestureRecognizer alloc] initWithTarget:manager action:@selector(tapOneAct:)];
//        [manager addGestureRecognizer:manager.singleTapGes];

//        manager.doubleTapGes =[[UITapGestureRecognizer alloc] initWithTarget:manager action:@selector(tapTwoAct:)];
//        //双击时触发事件 ,默认值为1
//        manager.doubleTapGes.numberOfTapsRequired = 2;
//        manager.doubleTapGes.delegate = manager;
//        [manager addGestureRecognizer:manager.doubleTapGes];
        //当单击操作遇到了 双击 操作时，单击失效
//        [manager.singleTapGes requireGestureRecognizerToFail:manager.doubleTapGes];
//
//        manager.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:manager
//                                                                                    action:@selector(longPressGestureDidFire:)];
//        manager.longPressGestureRecognizer.delegate = manager;
//        [manager addGestureRecognizer:manager.longPressGestureRecognizer];

        [[NSNotificationCenter defaultCenter] addObserver:manager selector:@selector(applicationEnterBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];
//
        manager.scrlooViewArray = [NSMutableArray arrayWithCapacity:3];
    
        
        
    });
    return manager;
}

- (void)showSelectViewInCJLabel:(UITextView *)view
                        atPoint:(CGPoint)point
                        runItem:(TLRunItem *)item
                   maxLineWidth:(CGFloat)maxLineWidth
                allRunItemArray:(NSArray <TLRunItem *>*)allRunItemArray
                  hideViewBlock:(void(^)(void))hideViewBlock;
{
    if (_startCopyRunItem && CGRectEqualToRect(_startCopyRunItem.withOutMergeBounds, item.withOutMergeBounds) ) {
        return;
    }
    [self hideSelectTextRangeView];
    _hideBlock = hideViewBlock;
    
    self.view = view;
    self.attributedText = view.attributedText;
    self.font = view.font;
    CGRect labelFrame = view.bounds;
    self.frame = labelFrame;
    _lineVerticalMaxWidth = maxLineWidth;
    _allRunItemArray = allRunItemArray;
    _firstRunItem = [[allRunItemArray firstObject] copy];
    _lastRunItem = [[allRunItemArray lastObject] copy];
    
    _startCopyRunItem = [item copy];
    _endCopyRunItem = _startCopyRunItem;
    
    
    
//
    
//    [self showCJSelectViewWithPoint:point selectType:ShowAllSelectView item:_startCopyRunItem startCopyRunItem:_startCopyRunItem endCopyRunItem:_endCopyRunItem needShowMagnifyView:NO];
    


    CGRect windowFrame = [view.superview convertRect:view.frame toView:TLkeyWindow()];
    self.backWindView.frame = windowFrame;
    self.backWindView.hidden = NO;
    [TLkeyWindow() addSubview:self.backWindView];

    if (self.subviews.count == 0) {
        [self addSubview:self.textRangeView];
    }
    [view addSubview:self];
    [view bringSubviewToFront:self];
    
    // 不添加放大镜视图
//    [TLkeyWindow() addSubview:self.magnifierView];
    
    [self scrollViewUnable:NO];
    
    [self selectAll:nil];
}

/**
 更新选中复制的背景填充色
 */
- (void)updateSelectTextRangeViewStartCopyRunItem:(TLRunItem *)startCopyRunItem
                                   endCopyRunItem:(TLRunItem *)endCopyRunItem
                                             view:(UIView *) view
{
    
    CGRect frame = view.bounds;
    CGRect headRect = CGRectNull;
    CGRect middleRect = CGRectNull;
    CGRect tailRect = CGRectNull;
    
    TLCTLineLayoutModel *lineLayoutModel = nil;
    
    CGFloat maxWidth = _lineVerticalMaxWidth;
    
    //headRect 坐标
    lineLayoutModel = self.verticalLayoutArray[startCopyRunItem.lineVerticalLayout.line];
    _startCopyRunItemY = lineLayoutModel.selectCopyBackY;
    CGFloat headWidth = maxWidth - startCopyRunItem.withOutMergeBounds.origin.x;
    CGFloat headHeight = lineLayoutModel.selectCopyBackHeight;
    headRect = CGRectMake(startCopyRunItem.withOutMergeBounds.origin.x, _startCopyRunItemY, headWidth, headHeight);
    
    //tailRect 坐标
    lineLayoutModel = self.verticalLayoutArray[endCopyRunItem.lineVerticalLayout.line];
    CGFloat tailWidth = endCopyRunItem.withOutMergeBounds.origin.x+endCopyRunItem.withOutMergeBounds.size.width;
    CGFloat tailHeight = lineLayoutModel.selectCopyBackHeight;
    CGFloat tailY = lineLayoutModel.selectCopyBackY;
    if (endCopyRunItem.lineVerticalLayout.line - 1 >= 0) {
        TLCTLineLayoutModel *endLastlineLayoutModel = self.verticalLayoutArray[endCopyRunItem.lineVerticalLayout.line-1];
        tailY = endLastlineLayoutModel.selectCopyBackY + endLastlineLayoutModel.selectCopyBackHeight;
        tailHeight = tailHeight + lineLayoutModel.selectCopyBackY - tailY;
    }
    tailRect = CGRectMake(0, tailY, tailWidth, tailHeight);
    
    CGFloat maxHeight = tailY + tailHeight - _startCopyRunItemY;
    
    BOOL differentLine = YES;
    if (startCopyRunItem.lineVerticalLayout.line == endCopyRunItem.lineVerticalLayout.line) {
        differentLine = NO;
        headRect = CGRectNull;
        middleRect = CGRectMake(startCopyRunItem.withOutMergeBounds.origin.x,
                                _startCopyRunItemY,
                                endCopyRunItem.withOutMergeBounds.origin.x+endCopyRunItem.withOutMergeBounds.size.width-startCopyRunItem.withOutMergeBounds.origin.x,
                                headHeight);
        tailRect = CGRectNull;
    }else{
        //相差一行
        if (startCopyRunItem.lineVerticalLayout.line + 1 == endCopyRunItem.lineVerticalLayout.line) {
            middleRect = CGRectNull;
        }else{
            middleRect = CGRectMake(0, _startCopyRunItemY+headHeight, maxWidth, maxHeight-headHeight-tailHeight);
        }
    }
    
    [self.textRangeView updateFrame:frame headRect:headRect middleRect:middleRect tailRect:tailRect differentLine:differentLine];
    
    self.textRangeView.hidden = NO;
    [self bringSubviewToFront:self.textRangeView];
}

- (void)hideSelectTextRangeView {
    self.attributedText = nil;
    self.font = nil;
    _lineVerticalMaxWidth = 0;
    _allRunItemArray = nil;
    _firstRunItem = nil;
    _lastRunItem = nil;
    _startCopyRunItem = nil;
    _endCopyRunItem = nil;
    [self scrollViewUnable:YES];
    [self hideAllCopySelectView];
    if (self.hideBlock) {
        self.hideBlock();
    }
    self.hideBlock = nil;
}

/**
 隐藏所有与选择复制相关的视图
 */
- (void)hideAllCopySelectView {
    _startCopyRunItem = nil;
    _endCopyRunItem = nil;
    self.textRangeView.hidden = YES;
    self.backWindView.hidden = YES;
    [self.backWindView removeFromSuperview];
    [self removeFromSuperview];
}

- (BOOL)isShow {
    return !self.textRangeView.isHidden;
}

#pragma mark - UILongPressGestureRecognizer
- (void)longPressGestureDidFire:(UILongPressGestureRecognizer *)sender {
    
//    UITouch *touch = objc_getAssociatedObject(self.longPressGestureRecognizer, &kAssociatedUITouchKey);
    CGPoint point = [sender locationInView:self];
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
          
            break;
        }
        case UIGestureRecognizerStateEnded:{
            
            break;
        }
        case UIGestureRecognizerStateChanged:{
            NSLog(@"********** 响应到我了 ************ ");
        }
        default:
            break;
    }
}


#pragma mark - touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"xxxxx touchesBegan");
    _haveMove = NO;
    CGPoint point = [[touches anyObject] locationInView:self];
    //复制选择正在移动的大头针
    self.selectViewAction = [self choseSelectView:point];
    NSLog(@"selectViewAction %zd", self.selectViewAction);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"xxxxx touchesEnded");
//    self.magnifierView.hidden = YES;
    if (!self.textRangeView.hidden) {
//        [self showMenuView];
    }
    _haveMove = NO;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    NSLog(@"xxxxx touchesCancelled");
//    self.magnifierView.hidden = YES;
    if (!self.textRangeView.hidden) {
//        [self showMenuView];
    }
    _haveMove = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"xxxxx touchesMoved");
    _haveMove = YES;
    CGPoint point = [[touches anyObject] locationInView:self];
    
    TLRunItem *currentItem = nil;
    //最后一个CTRun选中判断
    CGFloat lastRunItemX = _lastRunItem.withOutMergeBounds.origin.x;
    CGFloat lastRunItemY = _lastRunItem.withOutMergeBounds.origin.y;
    CGFloat lastRunItemHeight = _lastRunItem.withOutMergeBounds.size.height;
    CGFloat lastRunItemWidth = _lastRunItem.withOutMergeBounds.size.width;
    
    if ((point.x >= lastRunItemX + lastRunItemWidth) && (point.y >= lastRunItemY)) {
        currentItem = [_lastRunItem copy];
    }
    else if (point.y > lastRunItemY + lastRunItemHeight + 1) {
        currentItem = [_lastRunItem copy];
    }
    
    if (!currentItem) {
        currentItem = [TLSelectRangManager currentItem:point allRunItemArray:_allRunItemArray inset:0.5];
    }
    
    if (currentItem && self.selectViewAction != ShowAllSelectView) {
        CGPoint selectPoint = CGPointMake(point.x, (currentItem.lineVerticalLayout.lineRect.size.height/2)+currentItem.lineVerticalLayout.lineRect.origin.y);
        if (self.selectViewAction == MoveLeftSelectView) {
            if (currentItem.characterIndex < _endCopyRunItem.characterIndex) {
                _startCopyRunItem = currentItem;

                [self showCJSelectViewWithPoint:selectPoint
                                     selectType:MoveLeftSelectView
                                           item:currentItem
                               startCopyRunItem:_startCopyRunItem
                                 endCopyRunItem:_endCopyRunItem
                            needShowMagnifyView:YES];
            }
            else if (currentItem.characterIndex == _endCopyRunItem.characterIndex){
                _startCopyRunItem = [currentItem copy];
                _endCopyRunItem = _startCopyRunItem;
                [self showCJSelectViewWithPoint:selectPoint
                                     selectType:ShowAllSelectView
                                           item:_startCopyRunItem
                               startCopyRunItem:_startCopyRunItem
                                 endCopyRunItem:_endCopyRunItem
                            needShowMagnifyView:YES];
            }
        }
        else if (self.selectViewAction == MoveRightSelectView) {
            
            NSLog(@"xxxxx MoveRightSelectView currentItem %zd _startCopyRunItem %zd", currentItem.characterIndex,  _startCopyRunItem.characterIndex);
            if (currentItem.characterIndex > _startCopyRunItem.characterIndex) {
                _endCopyRunItem = [currentItem copy];
                [self showCJSelectViewWithPoint:selectPoint
                                     selectType:MoveRightSelectView
                                           item:currentItem
                               startCopyRunItem:_startCopyRunItem
                                 endCopyRunItem:_endCopyRunItem
                            needShowMagnifyView:YES];
            }
            else if (currentItem.characterIndex == _startCopyRunItem.characterIndex){
                _startCopyRunItem = [currentItem copy];
                _endCopyRunItem = _startCopyRunItem;
                [self showCJSelectViewWithPoint:selectPoint
                                     selectType:ShowAllSelectView
                                           item:_startCopyRunItem
                               startCopyRunItem:_startCopyRunItem
                                 endCopyRunItem:_endCopyRunItem
                            needShowMagnifyView:YES];
            }
        }
    } else {
        NSLog(@"xxxxx current %@ selectViewAction %zd", currentItem, self.selectViewAction);
    }
}


+ (TLRunItem *)currentItem:(CGPoint)point allRunItemArray:(NSArray <TLRunItem *>*)allRunItemArray inset:(CGFloat)inset {
    __block TLRunItem *currentItem = nil;
    [allRunItemArray enumerateObjectsUsingBlock:^(TLRunItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectContainsPoint(CGRectInset(obj.withOutMergeBounds, -inset, -inset), point)) {
            currentItem = [obj copy];
            *stop = YES;
        }
    }];
    return currentItem;
}

#pragma mark - Private Method
- (void)showCJSelectViewWithPoint:(CGPoint)point
                       selectType:(TLSelectViewAction)type
                             item:(TLRunItem *)item
                 startCopyRunItem:(TLRunItem *)startCopyRunItem
                   endCopyRunItem:(TLRunItem *)endCopyRunItem
              needShowMagnifyView:(BOOL)needShowMagnifyView
{
    //选中部分填充背景色
    [self updateSelectTextRangeViewStartCopyRunItem:startCopyRunItem endCopyRunItem:endCopyRunItem view:self.view];
}

- (TLSelectViewAction)choseSelectView:(CGPoint)point {
    if (self.textRangeView.hidden) {
        return ShowAllSelectView;
    }
    
    
    TLCTLineLayoutModel *lineLayoutModel = nil;
    
    //headRect 坐标
    lineLayoutModel = _verticalLayoutArray[_startCopyRunItem.lineVerticalLayout.line];
    _startCopyRunItemY = lineLayoutModel.selectCopyBackY;
    CGFloat headHeight = lineLayoutModel.selectCopyBackHeight;
    CGRect leftRect = CGRectMake(_startCopyRunItem.withOutMergeBounds.origin.x-5, _startCopyRunItemY-10, 10, headHeight+30);
    
    
    //rightRect 坐标
    lineLayoutModel = _verticalLayoutArray[_endCopyRunItem.lineVerticalLayout.line];
    CGFloat tailWidth = _endCopyRunItem.withOutMergeBounds.origin.x+_endCopyRunItem.withOutMergeBounds.size.width;
    CGFloat tailHeight = lineLayoutModel.selectCopyBackHeight;
    CGFloat tailY = lineLayoutModel.selectCopyBackY;
    CGRect rightRect = CGRectMake(tailWidth-5, tailY, 10, tailHeight+20);
    
    TLSelectViewAction selectView = [self choseSelectView:point inset:1 leftRect:leftRect rightRect:rightRect time:0];
    return selectView;
}

- (TLSelectViewAction)choseSelectView:(CGPoint)point inset:(CGFloat)inset leftRect:(CGRect)leftRect rightRect:(CGRect)rightRect time:(NSInteger)time {
    TLSelectViewAction selectView = ShowAllSelectView;
    if (time > 15) {
        //超过15次还判断不到，那就退出
        return selectView;
    }
    time ++;
    
    BOOL inLeftView = CGRectContainsPoint(CGRectInset(leftRect, inset, inset), point);
    BOOL inRightView = CGRectContainsPoint(CGRectInset(rightRect, inset, inset), point);
    
    if (!inLeftView && !inRightView) {
        //加大点击区域判断
        return [self choseSelectView:point inset:inset+(-0.35) leftRect:leftRect rightRect:rightRect time:time];
    }
    else if (inLeftView && !inRightView) {
        selectView = MoveLeftSelectView;
        return selectView;
    }
    else if (!inLeftView && inRightView) {
        selectView = MoveRightSelectView;
        return selectView;
    }
    else if (inLeftView && inRightView) {
        //缩小点击区域判断
        return [self choseSelectView:point inset:inset+(0.25) leftRect:leftRect rightRect:rightRect time:time];
    }else{
        return selectView;
    }
}

- (void)applicationEnterBackground {
    [self hideSelectTextRangeView];
}

- (void)scrollViewUnable:(BOOL)unable {
    if (unable) {
        for (NSDictionary *viewDic in self.scrlooViewArray) {
            UIScrollView *view = viewDic[@"ScrollView"];
            view.delaysContentTouches = [viewDic[@"delaysContentTouches"] boolValue];
            view.canCancelContentTouches = [viewDic[@"canCancelContentTouches"] boolValue];
        }
        [self.scrlooViewArray removeAllObjects];
    }
    else{
        [self.scrlooViewArray removeAllObjects];
        [self setScrollView:self.superview scrollUnable:NO];
    }
}

- (void)setScrollView:(UIView *)view scrollUnable:(BOOL)unable {
    if (view.superview) {
        if ([view.superview isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)view.superview;
            [self.scrlooViewArray addObject:@{@"ScrollView":scrollView,
                                              @"delaysContentTouches":@(scrollView.delaysContentTouches),
                                              @"canCancelContentTouches":@(scrollView.canCancelContentTouches)
                                              }];
            scrollView.delaysContentTouches = NO;
            scrollView.canCancelContentTouches = NO;
        }
        [self setScrollView:view.superview scrollUnable:unable];
    }else{
        return;
    }
}

#pragma mark - UIResponder
- (void)selectAll:(nullable id)sender {
    _startCopyRunItem = [_firstRunItem copy];
    _endCopyRunItem = [_lastRunItem copy];
    CGPoint point = CGPointMake(_startCopyRunItem.withOutMergeBounds.origin.x, _startCopyRunItem.withOutMergeBounds.origin.y);
    
    [self showCJSelectViewWithPoint:point selectType:ShowAllSelectView item:nil startCopyRunItem:_startCopyRunItem endCopyRunItem:_endCopyRunItem  needShowMagnifyView:false];
}

@end
