//
//  PageCellView.m
//  HYPageScrollViewDemo
//
//  Created by 李思良 on 15/11/15.
//  Copyright © 2015年 lsl. All rights reserved.
//

#import "PageCellView.h"
@interface PageCellView()
@property (strong,  nonatomic)  UILabel *label;
@end

@implementation PageCellView

- (instancetype)init {
    if (self = [super init]) {
        _label = [[UILabel alloc] init];
        [self addSubview:_label];
        _label.font = [UIFont systemFontOfSize:20];
        _label.textColor = [UIColor whiteColor];
        _label.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
     _label.frame = self.bounds;
}
- (void)updateData:(NSString *)text {
    _label.text = text;
}
@end
