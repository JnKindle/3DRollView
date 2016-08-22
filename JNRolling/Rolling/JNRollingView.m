//
//  JNRollingView.m
//  JNRolling
//
//  Created by WJN on 16/3/17.
//  Copyright © 2016年 Lours. All rights reserved.
//

#import "JNRollingView.h"

#import <QuartzCore/QuartzCore.h>


@implementation JNRollingView

@synthesize delegate=_delegate;
@synthesize idleDuration=_idleDuration;

- (void)initialize{
    
    idleView = nil;
    
    idleViewAnimated = NO;
    
    self.layer.masksToBounds = YES;
    
    self.layer.opaque = NO;
    
    CATransform3D theTransform = self.layer.sublayerTransform;
    theTransform.m34 = -0.01;
    self.layer.sublayerTransform = theTransform;
    
    _views = [[NSMutableArray alloc] init];
    
    _viewsAngles = [[NSMutableArray alloc] init];
    
    _originalPositionedViews = [[NSMutableArray alloc] init];
    
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    
    gesture.delegate = self;
    
    [self addGestureRecognizer:gesture];
    
    [self loadViews];
    
}



- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;{
    
    return NO;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self initialize];
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
        [self initialize];
        
    }
    return self;
    
    
}

- (void)reloadData{
    
    [self loadViews];
}

- (void)loadViews{
    
    //移除所有的object
    [_views removeAllObjects];
    
    [_viewsAngles removeAllObjects];
    
    for (UIView *__view in self.subviews) {
        
        [__view removeFromSuperview];
    }
    
    viewsNum = [_delegate numberOfRowsOfRollingView:self];
    
    //循环创建视图
    for (int index = 0; index < viewsNum; index++) {
        
        UIView *__view = [_delegate rollingView:self viewForRowAtIndex:index];
        
        [self addSubview:__view];
        
        //添加进views的数组
        [_views addObject:__view];
        //添加进原始位置view的数组
        [_originalPositionedViews addObject:__view];
        //宽度
        float rowWidth = [_delegate rowWidthInRollingView:self];
        //高度
        float rowHeight = [_delegate rowHeightInRollingView:self];
        //frame
        __view.frame = CGRectMake((self.bounds.size.width - rowWidth) / 2.0, 0, rowWidth, rowHeight);
        //阴影
        setShadowForLayer(__view.layer);
        //点击手势
        UITapGestureRecognizer *_tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewSelected:)];
        
        _tapGesture.delegate = self;
        
        [__view addGestureRecognizer:_tapGesture];
        //布局
        [self layoutView:__view atIndex:index animated:NO duration:0];
        
    }
    
}


void(^setShadowForLayer)(CALayer *) = ^(CALayer *____layer) {
    
    ____layer.masksToBounds = NO;
    ____layer.shadowRadius = 6;
    ____layer.shadowOpacity = 0.6;
    ____layer.shadowColor = [[UIColor clearColor] CGColor];
    ____layer.shadowOffset = CGSizeMake(-10, 10);
    ____layer.shadowPath = [[UIBezierPath bezierPathWithRect:____layer.bounds] CGPath];
    
};

- (void)layoutView:(UIView *)__view atIndex:(int)index animated:(BOOL)animated duration:(double)duration{
    
    const double dAngle = M_PI / viewsNum;
    
    double angle = (index < viewsNum / 2.0 ? index : viewsNum - index) * dAngle;
    
    int _index = [_originalPositionedViews indexOfObject:__view];
    
    
    if (_index < [_viewsAngles count]) {
        
        [_viewsAngles replaceObjectAtIndex:_index withObject:[NSNumber numberWithDouble:angle]];
        
    }else{
        
        [_viewsAngles addObject:[NSNumber numberWithDouble:angle]];
    }
    
    double z = -self.bounds.size.height / 2.0 + self.bounds.size.height / 2.0 * cos(angle);
    
    double x = self.bounds.size.width / 2.0 + (index < viewsNum / 2.0 ? 1 : -1) * self.bounds.size.width / 1.4 * sin(angle);
    
    void(^changeLayerLayout)(void) = ^(void) {
        //__view.layer.position.y
        __view.layer.position = CGPointMake(x,self.bounds.size.height/2);
        __view.layer.zPosition = z;
        
        if (index == 0) {
            
            __view.userInteractionEnabled = YES;
            
            __view.layer.opacity = 1.0;
            
            if ([_delegate respondsToSelector:@selector(rollingView:shouldEnterIdleStateForRowAtIndex:animated:)]) {
                
                if ([_delegate rollingView:self shouldEnterIdleStateForRowAtIndex:[_originalPositionedViews indexOfObject:[_views objectAtIndex:0]] animated:&idleViewAnimated]) {
                    
                    [self performSelector:@selector(idleStateBegin) withObject:nil afterDelay:10.0];
                    
                }
            }
            
        }else{
            
            __view.userInteractionEnabled = NO;
            
            __view.layer.opacity = 0.85;
        }
        
    };
    
    if (animated) {
        
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationCurveEaseOut animations:changeLayerLayout completion:^(BOOL finished){}];
        
        CABasicAnimation *theAnimation;
        theAnimation = [CABasicAnimation animationWithKeyPath:@"zPosition"];
        theAnimation.duration = duration;
        theAnimation.removedOnCompletion = YES;
        [__view.layer addAnimation:theAnimation forKey:@"theAnimation"];
        
    }else{
        
        changeLayerLayout();
        
    }
    
}

- (void)layoutView:(UIView *)__view byAngle:(double)angle animated:(BOOL)animated duration:(double)duration{
    
    int _index = [_originalPositionedViews indexOfObject:__view];
    
    int __index = [_views indexOfObject:__view];
    
    double _angle = [[_viewsAngles objectAtIndex:_index] doubleValue] + (__index < viewsNum / 2.0 ? 1 : -1) * angle;
    
    if (_angle > M_PI_2) {
        _angle = M_PI - _angle;
    }
    
    [_viewsAngles replaceObjectAtIndex:_index withObject:[NSNumber numberWithDouble:_angle]];
    
    double z = -self.bounds.size.height / 2.0 + self.bounds.size.height / 2.0 * cos(_angle);
    
    double x = self.bounds.size.width / 2.0 + (__index < viewsNum / 2.0 ? 1 : -1) * self.bounds.size.width / 1.4 * sin(_angle);
    
    void(^changeLayerLayout)(void) = ^(void) {
        
        __view.layer.position = CGPointMake(x,self.bounds.size.height/2);
        __view.layer.zPosition = z;
        
        if (index == 0) {
            
            __view.userInteractionEnabled = YES;
            
            __view.layer.opacity = 1.0;
            
            if ([_delegate respondsToSelector:@selector(rollingView:shouldEnterIdleStateForRowAtIndex:animated:)]) {
                
                if ([_delegate rollingView:self shouldEnterIdleStateForRowAtIndex:[_originalPositionedViews indexOfObject:[_views objectAtIndex:0]] animated:&idleViewAnimated]) {
                    
                    [self performSelector:@selector(idleStateBegin) withObject:nil afterDelay:10.0];
                    
                }
            }
            
        }else{
            
            __view.userInteractionEnabled = YES;
            
            __view.layer.opacity = 0.85;
        }
        
    };
    
    if (animated) {
        
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationCurveEaseOut animations:changeLayerLayout completion:^(BOOL finished){}];
        
        CABasicAnimation *theAnimation;
        theAnimation = [CABasicAnimation animationWithKeyPath:@"zPosition"];
        theAnimation.duration = duration;
        theAnimation.removedOnCompletion = YES;
        [__view.layer addAnimation:theAnimation forKey:@"theAnimation"];
        
    }else{
        
        changeLayerLayout();
        
    }
    
}

- (void)pan:(UIPanGestureRecognizer *)gesture{
    
    if (idleView) {
        
        [self endIdle];
        
        return;
    }
    //清楚叠加值
    //[gesture setTranslation:CGPointMake(0, 0) inView:self];
    UIGestureRecognizerState state = [gesture state];
    NSLog(@"state %ld",(long)state);
    
    //gesture 速度
    CGPoint velocity = [gesture velocityInView:self];
    //gesture 偏移
    CGPoint translation = [gesture translationInView:self];
    
    NSLog(@"velocity %@",NSStringFromCGPoint(velocity));
    NSLog(@"111111");
    NSLog(@"fabs(velocity.x) %f",fabs(velocity.x));
    
    toDescelerate = state == UIGestureRecognizerStateEnded && fabs(velocity.x) > self.frame.size.width/2;
    
    toRearrange = state == UIGestureRecognizerStateEnded && fabs(velocity.x) < self.frame.size.width/2;
    //不为0时，才赋值
    if (fabs(velocity.x) != 0) {
        velocity_x = velocity.x;
    }
    
    //临界值（宽度）
    float rowWidth = [_delegate rowWidthInRollingView:self];
    NSLog(@"rowWidth %f",rowWidth);
    
    [gesture setTranslation:CGPointMake(0, 0) inView:self];
    
    if ([_views count] > 0) {
        
        if (fabs(velocity.x) > 1500) {
            if (fabs(velocity.x) == 0) {
                [self animateViewsWithVelocity:[NSNumber numberWithDouble:velocity_x]];
            }else{
                [self animateViewsWithVelocity:[NSNumber numberWithDouble:velocity.x]];
            }
            return;
        }else {
            if (velocity.x > 0) {
                [self animateViewsWithVelocity:[NSNumber numberWithDouble:20]];
            }else{
                [self animateViewsWithVelocity:[NSNumber numberWithDouble:-20]];
            }
            return;
        }
        
        
    }
    
}

- (void)animateViewsWithVelocity:(NSNumber *)velocity{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(idleStateBegin) object:nil];
    
    if ([velocity doubleValue] != 0) {
        
        static double angle = 0;
        
        double _dAngle = [velocity doubleValue] * M_PI / viewsNum / self.bounds.size.height / 10;
        
        angle += _dAngle;
        
        const double dAngle = M_PI / viewsNum;
        
        double duration = 0;
        
        BOOL rearrange = toRearrange || (toDescelerate && fabs([velocity doubleValue]) <= 1);
        
        if (fabs(angle / dAngle) > 0.9 || rearrange) {
            
            if ([velocity doubleValue] > 0) {
                
                [_views insertObject:[_views lastObject] atIndex:0];
                
                [_views removeLastObject];
                
            }else{
                
                [_views addObject:[_views objectAtIndex:0]];
                
                [_views removeObjectAtIndex:0];
                
            }
            
            duration = rearrange ? 0.25 * (1.0 - fabs(angle / dAngle)) : 0;
            
            for (int index = 0; index < viewsNum; index++) {
                
                UIView *__view = [_views objectAtIndex:index];
                
                [self layoutView:__view atIndex:index animated:rearrange  duration:duration];
            }
            
            angle = 0;
            
        }else {
            
            duration = 0;
            
            for (int index = 0; index < viewsNum; index++) {
                
                UIView *__view = [_views objectAtIndex:index];
                
                [self layoutView:__view byAngle:_dAngle animated:NO duration:duration];
            }
            
        }
        
        if(toDescelerate && fabs([velocity doubleValue]) > 1){
            
            [self performSelector:@selector(animateViewsWithVelocity:) withObject:[NSNumber numberWithDouble:[velocity doubleValue] / 1.02] afterDelay:duration];
            
        }
        
    }
    
}

- (void)viewSelected:(UITapGestureRecognizer *)gesture{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(idleStateBegin) object:nil];
    
    if ([_delegate respondsToSelector:@selector(rollingView:didSelectedRowAtIndex:)]) {
        
        [_delegate rollingView:self didSelectedRowAtIndex:[_originalPositionedViews indexOfObject:gesture.view]];
    }
    
}

- (void)idleStateBegin{
    
    if ([_delegate respondsToSelector:@selector(rollingView:idleStateViewForRowAtIndex:)] && idleView == nil) {
        
        UIView *__view0 = [_views objectAtIndex:0];
        
        UIView *__view = [_delegate rollingView:self idleStateViewForRowAtIndex:[_originalPositionedViews indexOfObject:__view0]];
        
        idleView = [[UIView alloc] initWithFrame:CGRectInset(__view0.frame, -50, -50)];
        
        idleView.layer.masksToBounds = YES;
        
        idleView.userInteractionEnabled = YES;
        
        idleView.tag = YES;
        
        UITapGestureRecognizer *_gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endIdle)];
        
        _gesture.delegate = self;
        
        [idleView addGestureRecognizer:_gesture];
        
        CATransform3D theTransform = idleView.layer.sublayerTransform;
        theTransform.m34 = -0.001;
        idleView.layer.sublayerTransform = theTransform;
        
        [self addSubview:idleView];
        
        [idleView addSubview:__view];
        
        CGRect frame = CGRectMake(50, 50, __view0.bounds.size.width, __view0.bounds.size.height);
        
        __view.frame = CGRectInset(frame,10,10);
        
        if (idleViewAnimated) {
            
            __view.layer.zPosition = -1;
            
            CALayer *__layer = [CALayer layer];
            
            __layer.frame = frame;
            
            __layer.delegate = idleView.layer;
            
            __layer.doubleSided = NO;
            
            UIGraphicsBeginImageContextWithOptions(__view0.bounds.size, NO, 0);
            
            [__view0.layer renderInContext:UIGraphicsGetCurrentContext()];
            
            __layer.contents = (id)[UIGraphicsGetImageFromCurrentImageContext() CGImage];
            
            UIGraphicsEndImageContext();
            
            [idleView.layer addSublayer:__layer];
            
            __view0.alpha = 0;
            
            rotateLayer(__layer,M_PI,self,@"theAnimation",YES);
            
            rotateLayer(__view.layer,M_PI,nil,@"theAnimation",NO);
            
        }
        
    }
    
}

void(^rotateLayer)(CALayer*,float,id,NSString*,BOOL) = ^(CALayer * ____layer,float angle,id ____delegate,NSString *animationKey,BOOL continueRotated) {
    
    CABasicAnimation *theAnimation;
    theAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    theAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(angle, 1.0, 0, 0)];
    theAnimation.duration = 0.25;
    
    if (continueRotated) {
        
        theAnimation.fillMode = kCAFillModeForwards;
        theAnimation.removedOnCompletion = NO;
        
    }else{
        
        theAnimation.removedOnCompletion = YES;
        
    }
    
    theAnimation.delegate = ____delegate;
    
    [____layer addAnimation:theAnimation forKey:animationKey];
    
};

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag{
    
    if (flag) {
        
        if (idleView.tag) {
            
            [[_views objectAtIndex:0] setAlpha:1.0];
            
            [[idleView.layer.sublayers objectAtIndex:0] setZPosition:0];
            
            if ([_delegate respondsToSelector:@selector(rollingView:didStartIdleStateForRowAtIndex:)]) {
                
                [_delegate rollingView:self didStartIdleStateForRowAtIndex:[_originalPositionedViews indexOfObject:[_views objectAtIndex:0]]];
            }
            
            [self performSelector:@selector(idleStateEnd) withObject:nil afterDelay:_idleDuration];
            
        }else{
            
            [self endIdle];
        }
        
    }
    
}

- (void)idleStateEnd{
    
    if (idleView) {
        
        if (idleViewAnimated) {
            
            idleView.tag = NO;
            
            UIView *__view0 = [_views objectAtIndex:0];
            
            CALayer *___layer = [idleView.layer.sublayers lastObject];
            
            ___layer.zPosition = -1;
            
            ___layer.transform = CATransform3DMakeRotation(M_PI, 1.0, 0, 0);
            
            [___layer removeAllAnimations];
            
            ___layer.doubleSided = YES;
            
            CALayer *__layer = [CALayer layer];
            
            CGRect frame = CGRectMake(50, 50, __view0.bounds.size.width, __view0.bounds.size.height);
            
            __layer.frame = frame;
            
            __layer.delegate = idleView.layer;
            
            __layer.doubleSided = NO;
            
            UIGraphicsBeginImageContextWithOptions(__view0.bounds.size, NO, 0);
            
            CGContextFillRect(UIGraphicsGetCurrentContext(), __view0.bounds);
            
            __layer.contents = (id)[UIGraphicsGetImageFromCurrentImageContext() CGImage];
            
            UIGraphicsEndImageContext();
            
            [idleView.layer addSublayer:__layer];
            
            __view0.alpha = 0;
            
            rotateLayer(___layer,2 * M_PI,self,@"theAnimation2",YES);
            
            rotateLayer(__layer,M_PI,nil,@"theAnimation2",YES);
            
        }else{
            
            [self endIdle];
            
        }
        
    }
    
}

- (void)endIdle{
    
    if ([idleView.subviews count] > 0) {
        
        [NSObject cancelPreviousPerformRequestsWithTarget:[idleView.subviews objectAtIndex:0]];
        
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(idleStateEnd)  object:nil];
    
    [[_views objectAtIndex:0] setAlpha:1.0];
    
    [idleView removeFromSuperview];
    
    idleView = nil;
    
    if ([_delegate respondsToSelector:@selector(rollingView:shouldEnterIdleStateForRowAtIndex:animated:)]) {
        
        if ([_delegate rollingView:self shouldEnterIdleStateForRowAtIndex:[_originalPositionedViews indexOfObject:[_views objectAtIndex:0]] animated:&idleViewAnimated]) {
            
            [self performSelector:@selector(idleStateBegin) withObject:nil afterDelay:10.0];
            
        }
    }
    
}



@end
