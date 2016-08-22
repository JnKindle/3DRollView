//
//  ViewController.m
//  JNRolling
//
//  Created by WJN on 16/3/17.
//  Copyright © 2016年 Lours. All rights reserved.
//



#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@end

@implementation ViewController


//- (JNRollingView *)wheelView{
//    
//    return (JNRollingView *)self.view;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView1 = [[UIImageView alloc] init];
    imageView1.frame = CGRectMake((self.view.frame.size.width-320)/2, (self.view.frame.size.height-320)/2,320, 320);
    imageView1.image = [UIImage imageNamed:@"homecenterbackground"];
    [self.view addSubview:imageView1];
    
    
    
    JNRollingView *view1 = [[JNRollingView alloc] init];
    view1.frame = CGRectMake((self.view.frame.size.width-300)/2, (self.view.frame.size.height-300)/2,300, 300);
    view1.layer.cornerRadius = 150;
    view1.clipsToBounds = true;
    [self.view addSubview:view1];
    view1.delegate = self;
    [view1 reloadData];
    view1.idleDuration = 0;
    
    
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

- (unsigned int)numberOfRowsOfRollingView:(JNRollingView *)rollingView{
    
    return 3;
}

- (UIView *)rollingView:(JNRollingView *)rollingView viewForRowAtIndex:(unsigned int)index{
    
    NSString *str = [NSString stringWithFormat:@"item-%d",index+1];
    
    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:str]];
}

//Width
- (float)rowWidthInRollingView:(JNRollingView *)rollingView{
    
    return 192;
    
}

//Height
- (float)rowHeightInRollingView:(JNRollingView *)rollingView{
    
    return 227;
    
}

//select
- (void)rollingView:(JNRollingView *)rollingView didSelectedRowAtIndex:(unsigned int)index{
    
    NSLog(@"%d",index);
    
}

- (BOOL)rollingView:(JNRollingView *)rollingView shouldEnterIdleStateForRowAtIndex:(unsigned int)index animated:(BOOL *)animated{
    
    return NO;
}

- (UIView *)rollingView:(JNRollingView *)rollingView idleStateViewForRowAtIndex:(unsigned int)index{
    
    return nil;
}

- (void)rollingView:(JNRollingView *)rollingView didStartIdleStateForRowAtIndex:(unsigned int)index{
    NSLog(@"开始");
    
}

//- (void)dealloc{
//    
//    [super dealloc];
//}

@end
