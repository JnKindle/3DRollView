//
//  JNRollingView.h
//  JNRolling
//
//  Created by WJN on 16/3/17.
//  Copyright © 2016年 Lours. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JNRollingViewDelegate;

@interface JNRollingView : UIView <UIGestureRecognizerDelegate>{
    
    //
    NSMutableArray *_views;
    NSMutableArray *_viewsAngles;
    NSMutableArray *_originalPositionedViews;
    unsigned int viewsNum;
    
    //上一个velocity.x
    float velocity_x;
    
    UIView *idleView;
    BOOL idleViewAnimated;
    
    BOOL toDescelerate;
    
    BOOL toRearrange;
}

@property (nonatomic,assign) NSObject<JNRollingViewDelegate> *delegate;
@property (nonatomic,readwrite) int idleDuration;


- (void)reloadData;

@end

@protocol JNRollingViewDelegate

@required

/**
 *  row count
 *
 *  @param wheelView self
 *
 *  @return count
 */
- (unsigned int)numberOfRowsOfRollingView:(JNRollingView *)rollingView;

/**
 *  viewForRow
 *
 *  @param rollingView self
 *  @param index       index
 *
 *  @return view
 */
- (UIView *)rollingView:(JNRollingView *)rollingView viewForRowAtIndex:(unsigned int)index;

//宽
- (float)rowWidthInRollingView:(JNRollingView *)rollingView;

//高
- (float)rowHeightInRollingView:(JNRollingView *)rollingView;

@optional

- (void)rollingView:(JNRollingView *)rollingView didSelectedRowAtIndex:(unsigned int)index;
- (BOOL)rollingView:(JNRollingView *)rollingView shouldEnterIdleStateForRowAtIndex:(unsigned int)index animated:(BOOL*)animated;
- (UIView *)rollingView:(JNRollingView *)rollingView idleStateViewForRowAtIndex:(unsigned int)index;
- (void)rollingView:(JNRollingView *)rollingView didStartIdleStateForRowAtIndex:(unsigned int)index;


@end