//
//  SelectTextRangeView.m
//  hh
//
//  Created by 盘国权 on 2020/2/27.
//  Copyright © 2020 pgq. All rights reserved.
//

#import "TLSelectTextRangeView.h"
#import "TLSelectRangManager.h"

#define isUseLayer false

@implementation TLSelectTextRangeView {
    UIView *_left;
    UIView *_leftLine;
    UIView *_right;
    UIView *_rightLine;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
#if isUseLayer
#else
        _left = [[UIView alloc] init];
        _left.layer.cornerRadius = 5;
//        _left.clipsToBounds = true;
        _leftLine = [[UIView alloc] init];
        _right = [[UIView alloc] init];
        _right.layer.cornerRadius = 5;
//        _right.clipsToBounds = true;
        _rightLine = [[UIView alloc] init];
        
        [self addSubview:_leftLine];
        [self addSubview:_left];
        [self addSubview:_rightLine];
        [self addSubview:_right];
#endif
    }
    return self;
}

- (void)updateFrame:(CGRect)frame headRect:(CGRect)headRect middleRect:(CGRect)middleRect tailRect:(CGRect)tailRect differentLine:(BOOL)differentLine {
    self.differentLine = differentLine;
    self.frame = frame;
    self.headRect = headRect;
    self.middleRect = middleRect;
    self.tailRect = tailRect;
    [self setNeedsDisplay];
    
    if (differentLine) {
        [self updatePinView:CGPointMake(self.headRect.origin.x, self.headRect.origin.y) height:self.headRect.size.height isLeft:YES];
        [self updatePinView:CGPointMake(self.tailRect.origin.x + self.tailRect.size.width, self.tailRect.origin.y) height:self.tailRect.size.height isLeft:NO];
    } else {
        [self updatePinView:CGPointMake(self.middleRect.origin.x, self.middleRect.origin.y) height:self.middleRect.size.height isLeft:YES];
        [self updatePinView:CGPointMake(self.middleRect.origin.x + self.middleRect.size.width, self.middleRect.origin.y) height:self.middleRect.size.height isLeft:NO];
    }
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //背景色
    UIColor *backColor = [UIColor colorWithRed:251/255.0 green:128/250.0 blue:34/255.0 alpha: 0.2];
    
    if (self.differentLine) {
        [backColor set];
        CGContextAddRect(ctx, self.headRect);
        if (!CGRectEqualToRect(self.middleRect,CGRectNull)) {
            CGContextAddRect(ctx, self.middleRect);
        }
        CGContextAddRect(ctx, self.tailRect);
        CGContextFillPath(ctx);
        
#if isUseLayer
        [self updatePinLayer:ctx point:CGPointMake(self.headRect.origin.x, self.headRect.origin.y) height:self.headRect.size.height isLeft:YES];
        
        [self updatePinLayer:ctx point:CGPointMake(self.tailRect.origin.x + self.tailRect.size.width, self.tailRect.origin.y) height:self.tailRect.size.height isLeft:NO];
#else
//        [self updatePinView:CGPointMake(self.headRect.origin.x, self.headRect.origin.y) height:self.headRect.size.height isLeft:YES];
//        [self updatePinView:CGPointMake(self.tailRect.origin.x + self.tailRect.size.width, self.tailRect.origin.y) height:self.tailRect.size.height isLeft:NO];
#endif
    }else{
        
        [backColor set];
        CGContextAddRect(ctx, self.middleRect);
        CGContextFillPath(ctx);
#if isUseLayer
        [self updatePinLayer:ctx point:CGPointMake(self.middleRect.origin.x, self.middleRect.origin.y) height:self.middleRect.size.height isLeft:YES];
        
        [self updatePinLayer:ctx point:CGPointMake(self.middleRect.origin.x + self.middleRect.size.width, self.middleRect.origin.y) height:self.middleRect.size.height isLeft:NO];
#else
//        [self updatePinView:CGPointMake(self.middleRect.origin.x, self.middleRect.origin.y) height:self.middleRect.size.height isLeft:YES];
//        [self updatePinView:CGPointMake(self.middleRect.origin.x + self.middleRect.size.width, self.middleRect.origin.y) height:self.middleRect.size.height isLeft:NO];
#endif
    }
    
    CGContextStrokePath(ctx);
}

- (void)updatePinLayer:(CGContextRef)ctx point:(CGPoint)point height:(CGFloat)height isLeft:(BOOL)isLeft {
    UIColor *color = [UIColor colorWithRed:251/255.0 green:128/250.0 blue:34/255.0 alpha:1.0];
    _left.backgroundColor = color;
    _right.backgroundColor = color;
    CGRect roundRect = CGRectMake(point.x - 5,
                                  isLeft?(point.y - 10):(point.y + height),
                                  10,
                                  10);
    //画圆
    CGContextAddEllipseInRect(ctx, roundRect);
    [color set];
    CGContextFillPath(ctx);
    
    CGContextMoveToPoint(ctx, point.x, point.y);
    CGContextAddLineToPoint(ctx, point.x, point.y + height);
    CGContextSetLineWidth(ctx, 2.0);
    CGContextSetStrokeColorWithColor(ctx, color.CGColor);
    
    CGContextStrokePath(ctx);
}

- (void)updatePinView:(CGPoint)point height:(CGFloat)height isLeft:(BOOL)isLeft{
    UIColor *color = [UIColor colorWithRed:251/255.0 green:128/250.0 blue:34/255.0 alpha:1.0];
    _left.backgroundColor = color;
    _right.backgroundColor = color;
    CGRect roundRect = CGRectMake(point.x - 5,
                                  isLeft?(point.y - 10):(point.y + height - 1),
                                  10,
                                  10);
    
    if (isLeft) {
        _left.frame = roundRect;
        _leftLine.backgroundColor = color;
        _leftLine.frame = CGRectMake(point.x - 1, point.y, 2, height);
    } else {
        _right.frame = roundRect;
        _rightLine.backgroundColor = color;
        _rightLine.frame = CGRectMake(point.x - 1, point.y, 2, height);
        
        if (_right.frame.origin.y > self.superview.superview.frame.size.height) {
            CGRect frame = _right.frame;
            frame.origin.y = self.superview.superview.frame.size.height;
            _right.frame = frame;
        }
    }
}

@end
