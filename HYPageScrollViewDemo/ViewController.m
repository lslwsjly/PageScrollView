//
//  ViewController.m
//  HYPageScrollViewDemo
//
//  Created by 李思良 on 15/11/14.
//  Copyright © 2015年 lsl. All rights reserved.
//

#import "ViewController.h"
#import "HYPageScrollView/HYPageScrollView.h"
#import "PageCellView.h"
@interface ViewController ()<HYPageScrollViewDelegate>
@property   (strong,    nonatomic)  HYPageScrollView    *scrollView;
@property   (strong,    nonatomic)  UIPageControl       *pageControl;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _scrollView = [[HYPageScrollView alloc] initWithDirection:HYPageScrollViewHorizon];
    _scrollView.frame = CGRectMake(0, 100, self.view.frame.size.width, 200);
    _scrollView.backgroundColor = [UIColor greenColor];
    _scrollView.pageScrollViewDelegate = self;
    [self.view addSubview:_scrollView];
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 300, self.view.frame.size.width, 30)];
    [self.view addSubview:_pageControl];
    _pageControl.backgroundColor = [UIColor redColor];
    _pageControl.numberOfPages = 6;
    [_pageControl addTarget:self action:@selector(changeIndex:) forControlEvents:UIControlEventValueChanged];
}


- (void)changeIndex:(UIPageControl *)pageControl {
    [_scrollView movePage:(pageControl.currentPage - [_scrollView getCurrentPage])>0];
}

#pragma HYPageScrollViewDelegate
- (CGFloat)pageMarginForScrollView:(HYPageScrollView *)scrollView {
    return 50;
}
- (NSInteger)numberOfPages:(HYPageScrollView *)scrollView {
    return 6;
}

- (UIView *)configPageAtIndex:(NSInteger)index {
    PageCellView *view = [[PageCellView alloc] init];
    return view;
}
- (void)updatePage:(UIView *)pageView atIndex:(NSInteger)index {
    pageView.backgroundColor = (index % 2 == 1)?[UIColor redColor]:[UIColor blueColor];
    [(PageCellView *)pageView updateData:[NSString stringWithFormat:@"%d", (int)index]];
}
- (void)didMoveToIndex:(NSInteger)index {
    _pageControl.currentPage = index;
}
- (void)didClickIndex:(NSInteger)index {
    NSLog(@"click %d", (int)index);
}
@end
