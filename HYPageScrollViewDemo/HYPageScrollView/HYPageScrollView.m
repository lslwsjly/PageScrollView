//
//  HYPageScrollView.m
//  HYPageScrollViewDemo
//
//  Created by 李思良 on 15/11/14.
//  Copyright © 2015年 lsl. All rights reserved.
//

#import "HYPageScrollView.h"
#import "HYPageScrollViewCell.h"
#define HYPAGESCROLLCELLINDENTIFIER @"HYPAGESCROLLCELLINDENTIFIER"

#define PAGESIZE 3

@interface HYPageScrollView()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate>

//翻页的方向，可以为水平或垂直
@property (assign,  nonatomic)  HYPageScrollViewDirection direction;
@property   (assign,    nonatomic)  NSInteger   pageCount;
@property   (assign,    nonatomic)  NSInteger   currentPage;
@property   (assign,    nonatomic)  int         realIndex;//记录当前在第几个cell
@end

@implementation HYPageScrollView

- (instancetype)initWithFrame:(CGRect)frame direction:(HYPageScrollViewDirection)direction {
    if (self = [self initWithDirection:direction]) {
        self.frame = frame;
    }
    return self;
}

- (instancetype)initWithDirection:(HYPageScrollViewDirection)direction {
    if (self = [super initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]]) {
        _direction = direction;
        self.dataSource = self;
        self.delegate = self;
        [self setPagingEnabled:true];
        [self setShowsHorizontalScrollIndicator:false];
        [self setShowsVerticalScrollIndicator:false];
        [(UICollectionViewFlowLayout *)self.collectionViewLayout setScrollDirection:(_direction == HYPageScrollViewHorizon) ? UICollectionViewScrollDirectionHorizontal : UICollectionViewScrollDirectionVertical];
        [self registerClass:[HYPageScrollViewCell class] forCellWithReuseIdentifier:HYPAGESCROLLCELLINDENTIFIER];
        _currentPage = 0;
        _realIndex = 0;
    }
    return self;
}



#pragma UICollectionViewDelegateFlowLayout
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    CGFloat offset = 0;
    if ([self.pageScrollViewDelegate respondsToSelector:@selector(pageMarginForScrollView:)]) {
        offset = [self.pageScrollViewDelegate pageMarginForScrollView:self];
        return UIEdgeInsetsMake(offset/2, offset/2, offset/2, offset/2);
    }
    return UIEdgeInsetsZero;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    CGFloat offset = 0;
    if ([self.pageScrollViewDelegate respondsToSelector:@selector(pageMarginForScrollView:)]) {
        offset = [self.pageScrollViewDelegate pageMarginForScrollView:self];
    }
    return offset;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    CGFloat offset = 0;
    if ([self.pageScrollViewDelegate respondsToSelector:@selector(pageMarginForScrollView:)]) {
        offset = [self.pageScrollViewDelegate pageMarginForScrollView:self];
    }
    return offset;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat offset = 0;
    if ([self.pageScrollViewDelegate respondsToSelector:@selector(pageMarginForScrollView:)]) {
        offset = [self.pageScrollViewDelegate pageMarginForScrollView:self];
    }
    
    return CGSizeMake(self.frame.size.width - offset, self.frame.size.height - offset);
}


#pragma UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
//我们只使用三个cell来进行循环
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    _pageCount = [self.pageScrollViewDelegate numberOfPages:self];
    return (_pageCount < 2) ? _pageCount : PAGESIZE;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HYPageScrollViewCell *cell = [self dequeueReusableCellWithReuseIdentifier:HYPAGESCROLLCELLINDENTIFIER forIndexPath:indexPath];
    if ([cell configView]) {
        cell.layer.shouldRasterize = YES;
        cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
        cell.view = [self.pageScrollViewDelegate configPageAtIndex:[self indexChange:indexPath.row]];
        [cell.contentView addSubview:cell.view];
        cell.view.frame = cell.contentView.bounds;
    }
    [self.pageScrollViewDelegate updatePage:cell.view atIndex:[self indexChange:indexPath.row]];
    return cell;
}

#pragma UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.pageScrollViewDelegate respondsToSelector:@selector(didClickIndex:)]) {
        [self.pageScrollViewDelegate didClickIndex:indexPath.row % _pageCount];
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_pageCount > 1) { //page数小于2的时候没有循环效果
        if ([self checkNeedScroll:scrollView]) {
            _realIndex = PAGESIZE / 2;//移动回中间位置
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:_realIndex inSection:0];
            [self scrollToItemAtIndexPath:newIndexPath atScrollPosition:[self getScrollPosition] animated:NO];
        }
        int newIndex = (_direction == HYPageScrollViewHorizon)? ((int)round(scrollView.contentOffset.x / self.frame.size.width)) : ((int)round(scrollView.contentOffset.y / self.frame.size.height));
        if (newIndex != _realIndex) {
            _currentPage += newIndex - _realIndex;
            _currentPage = (_currentPage + _pageCount) % _pageCount;
            _realIndex = newIndex;
            if ([self.pageScrollViewDelegate respondsToSelector:@selector(didMoveToIndex:)]) {
                [self.pageScrollViewDelegate didMoveToIndex:_currentPage];
            }
        }
    }
}
//检查是否需要重新移动cell
- (BOOL)checkNeedScroll:(UIScrollView *)scrollView {
    CGFloat position = (_direction == HYPageScrollViewHorizon) ? scrollView.contentOffset.x : scrollView.contentOffset.y;
    CGFloat maxPoisition = (_direction == HYPageScrollViewHorizon) ? scrollView.contentSize.width - self.frame.size.width : scrollView.contentSize.height - self.frame.size.height;
    return position <= 0 || position >= maxPoisition;
}

//根据cell的index计算实际的page
- (NSInteger)indexChange:(NSInteger)index {
    return (index - _realIndex + _currentPage + _pageCount) % _pageCount;
}
- (void)scrollToPage:(NSInteger)page {
    _realIndex = PAGESIZE / 2;
    _currentPage = page;
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:_realIndex inSection:0];
    [self scrollToItemAtIndexPath:newIndexPath atScrollPosition:[self getScrollPosition] animated:NO];
    [self reloadItemsAtIndexPaths:@[newIndexPath]];
}
- (void)movePage:(BOOL)isNext {
    _realIndex = 1;
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:_realIndex inSection:0];
    [self scrollToItemAtIndexPath:newIndexPath atScrollPosition:[self getScrollPosition] animated:NO];
    
    newIndexPath = [NSIndexPath indexPathForItem:1 + (isNext?1:-1) inSection:0];
    [self scrollToItemAtIndexPath:newIndexPath atScrollPosition:[self getScrollPosition] animated:YES];
}

- (UICollectionViewScrollPosition)getScrollPosition {
    return (_direction == HYPageScrollViewHorizon) ? UICollectionViewScrollPositionCenteredHorizontally : UICollectionViewScrollPositionCenteredVertically;
}
- (NSInteger)getCurrentPage {
    return _currentPage % _pageCount;
}
@end
