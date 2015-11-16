//
//  HYPageScrollView.h
//  HYPageScrollViewDemo
//
//  Created by 李思良 on 15/11/14.
//  Copyright © 2015年 lsl. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    HYPageScrollViewVeritcal = 0,
    HYPageScrollViewHorizon = 1,
} HYPageScrollViewDirection;

@class HYPageScrollView;
@protocol HYPageScrollViewDelegate <NSObject>

//每一页距离上下左右的间距
@optional
- (CGFloat)pageMarginForScrollView:(HYPageScrollView *)scrollView;

//提供第index个page的view
- (UIView *)configPageAtIndex:(NSInteger)index;

//更新第index个page的cellView的数据，该pageView为configCellAtIndex中提供的view
- (void)updatePage:(UIView *)pageView atIndex:(NSInteger)index;

//指定page的数目
- (NSInteger)numberOfPages:(HYPageScrollView *)scrollView;

//移动到特定的page的回调
@optional
- (void)didMoveToIndex:(NSInteger)index;

//点击特定page的回调
@optional
- (void)didClickIndex:(NSInteger)index;

@end

@interface HYPageScrollView : UICollectionView

@property (weak, nonatomic) id<HYPageScrollViewDelegate> pageScrollViewDelegate;


- (instancetype)initWithFrame:(CGRect)frame direction:(HYPageScrollViewDirection)direction;

- (instancetype)initWithDirection:(HYPageScrollViewDirection)direction;

//移动到指定page，没有动画
- (void)scrollToPage:(NSInteger)page;

//上一页或下一页，有动画
- (void)movePage:(BOOL)isNext;
//获取当前page
- (NSInteger)getCurrentPage;

@end
