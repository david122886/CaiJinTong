//
//  SectionCustomView.m
//  CaiJinTongApp
//
//  Created by comdosoft on 13-11-4.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import "SectionCustomView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"

@implementation SectionCustomView

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame andSection:nil andItemLabel:0];
}
- (id)initWithFrame:(CGRect)frame andSection:(SectionModel *)section andItemLabel:(float)itemLabel{
    self = [super initWithFrame:frame];
    if (self) {
        //视频名称
        if (itemLabel>0) {
            UIFont *font = [UIFont systemFontOfSize:20];
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, itemLabel)];
            nameLabel.text = [NSString stringWithFormat:@"%@",section.sectionName];
            nameLabel.textColor = [UIColor blackColor];
            nameLabel.numberOfLines = 0;
            nameLabel.textAlignment = NSTextAlignmentLeft;
            nameLabel.backgroundColor = [UIColor clearColor];
            nameLabel.font = font;
            self.nameLab = nameLabel;
            [self addSubview:self.nameLab];
            nameLabel = nil;
        }
        
        //视频封面
        UIImageView *imageViewC = [[UIImageView alloc]initWithFrame:CGRectMake(0, itemLabel, self.frame.size.width, self.frame.size.height)];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",section.sectionImg]];
        [imageViewC setImageWithURL:url placeholderImage:Image(@"loginBgImage_v.png")];
        
        imageViewC.tag = [section.sectionId intValue];
        self.imageView = imageViewC;
        self.tag = self.imageView.tag;
        [self addSubview:self.imageView];
        imageViewC = nil;
        
        //视频进度
//        AMProgressView *pvv = [[AMProgressView alloc] initWithFrame:CGRectMake(0, self.frame.size.height+itemLabel-30, self.frame.size.width, 30)
//                                                 andGradientColors:nil
//                                                  andOutsideBorder:NO
//                                                       andVertical:NO];
//        pvv.progress = [section.sectionProgress floatValue];
//        float pgress = (float)[section.sectionProgress floatValue];
//        if (pgress-100>0) {
//            pgress = 100.0;
//        }
//        pvv.text = [NSString stringWithFormat:@"学习进度:%.2f%%",pgress];
//        self.pv = pvv;
//        [self addSubview:self.pv];
//        pvv = nil;
        self.pv = [[UISlider alloc] initWithFrame:CGRectMake(-2, self.frame.size.height+itemLabel-30, self.frame.size.width+4, 37)];
        UIImage *frontImage = [[UIImage imageNamed:@"progressBar-front.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0) resizingMode:UIImageResizingModeStretch];
        UIImage *backgroundImage = [[UIImage imageNamed:@"progressBar-background.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0) resizingMode:UIImageResizingModeStretch];
        [self.pv setMinimumTrackImage:frontImage forState:UIControlStateNormal];
        [self.pv setMaximumTrackImage:backgroundImage forState:UIControlStateNormal];
        [self.pv setThumbImage:[UIImage imageNamed:@"nothing"] forState:UIControlStateNormal];
        [self.pv setMaximumValue:100.0];
        [self.pv setMinimumValue:0.0];
        self.pv.value = [section.sectionProgress floatValue];
        UILabel *progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, self.frame.size.height+itemLabel-28, self.frame.size.width, 30)];
        progressLabel.text = [NSString stringWithFormat:@"学习进度:%@%%",section.sectionProgress];
        progressLabel.textAlignment = NSTextAlignmentLeft;
        progressLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.pv];
        [self addSubview:progressLabel];
        
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
