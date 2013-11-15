//
//  QuestionAndAnswerCell.m
//  CaiJinTongApp
//
//  Created by david on 13-11-7.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import "QuestionAndAnswerCell.h"
@interface QuestionAndAnswerCell()

@end
@implementation QuestionAndAnswerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)qflowerBtClicked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(questionAndAnswerCell:flowerAnswerAtIndexPath:)]) {
        [self.delegate questionAndAnswerCell:self flowerAnswerAtIndexPath:self.path];
    }
}

- (IBAction)answerBtClicked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(questionAndAnswerCell:isHiddleQuestionView:atIndexPath:)]) {
        [self.delegate questionAndAnswerCell:self isHiddleQuestionView:self.questionBackgroundView.isHidden atIndexPath:self.path];
    }
    self.answerTextField.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
}

- (IBAction)questionOKBtClicked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(questionAndAnswerCell:summitQuestion:atIndexPath:)]) {
        [self.delegate questionAndAnswerCell:self summitQuestion:self.questionTextField.text atIndexPath:self.path];
    }
}

- (IBAction)acceptAnswerBtClicked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(questionAndAnswerCell:acceptAnswerAtIndexPath:)]) {
        [self.delegate questionAndAnswerCell:self acceptAnswerAtIndexPath:self.path];
    }
}

#pragma mark UITextViewDelegate

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if (self.delegate && [self.delegate respondsToSelector:@selector(questionAndAnswerCell:willBeginTypeQuestionTextFieldAtIndexPath:)]) {
        [self.delegate questionAndAnswerCell:self willBeginTypeQuestionTextFieldAtIndexPath:self.path];
    }
    return YES;
}

#pragma mark --

-(void)setAnswerModel:(AnswerModel*)answer{
    self.answerTextField.delegate = self;
    self.qTitleNameLabel.text = answer.answerNick;
    self.qDateLabel.text = [NSString stringWithFormat:@"发表于%@",answer.answerTime];
    self.qflowerLabel.text = answer.answerPraiseCount;
    self.answerTextField.text = answer.answerContent;
    [self.questionBackgroundView setHidden:!answer.isEditing];
    self.answerTextField.font = [UIFont systemFontOfSize:TEXT_FONT_SIZE+6];
    [self.qflowerBt setUserInteractionEnabled:!answer.isPraised];
    [self.acceptAnswerBt setUserInteractionEnabled:!answer.IsAnswerAccept];
    [self.acceptAnswerBt setTitleColor:answer.IsAnswerAccept?[UIColor lightGrayColor]:[UIColor blueColor] forState:UIControlStateNormal];
    [self setNeedsLayout];
    
    self.qTitleNameLabel.backgroundColor = [UIColor clearColor];
    self.qDateLabel.backgroundColor = [UIColor clearColor];
    self.qflowerImageView.image = [UIImage imageNamed:@"Q&A-myq_19.png"];
    self.qflowerLabel.backgroundColor = [UIColor clearColor];
    self.answerTextField.backgroundColor = [UIColor whiteColor];
    self.acceptAnswerBt.backgroundColor = [UIColor clearColor];
    [self.qflowerBt setTitle:@"" forState:UIControlStateNormal];
    self.questionTextField.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    self.questionBackgroundView.backgroundColor = [UIColor clearColor];
}

-(void)layoutSubviews{
    
    self.qTitleNameLabel.frame = (CGRect){0,0,[Utility getTextSizeWithString:self.qTitleNameLabel.text withFont:self.qTitleNameLabel.font].width,CGRectGetHeight(self.qTitleNameLabel.frame)};
    
    self.qDateLabel.frame = (CGRect){CGRectGetMaxX(self.qTitleNameLabel.frame)+TEXT_PADDING,0,[Utility getTextSizeWithString:self.qDateLabel.text withFont:self.qDateLabel.font].width,CGRectGetHeight(self.qDateLabel.frame)};
    
    self.qflowerImageView.frame = (CGRect){CGRectGetMaxX(self.qDateLabel.frame)+TEXT_PADDING,0,CGRectGetHeight(self.qflowerImageView.frame),CGRectGetHeight(self.qflowerImageView.frame)};
    
    self.qflowerLabel.frame = (CGRect){CGRectGetMaxX(self.qflowerImageView.frame)+TEXT_PADDING,0,[Utility getTextSizeWithString:self.qflowerLabel.text withFont:self.qflowerLabel.font].width,CGRectGetHeight(self.qflowerLabel.frame)};
    
    self.acceptAnswerBt.frame = (CGRect){CGRectGetMaxX(self.qflowerLabel.frame)+TEXT_PADDING,0,self.acceptAnswerBt.frame.size};
    
    CGSize size = [Utility getTextSizeWithString:self.answerTextField.text withFont:[UIFont systemFontOfSize:TEXT_FONT_SIZE+6] withWidth:CGRectGetWidth(self.answerBackgroundView.frame)];
    self.answerBackgroundView.frame = (CGRect){self.answerBackgroundView.frame.origin,CGRectGetWidth(self.answerBackgroundView.frame),size.height+20};
    self.qflowerBt.frame = (CGRect){CGRectGetMinX(self.qflowerImageView.frame)-TEXT_PADDING,0,CGRectGetMaxX(self.qflowerLabel.frame) - CGRectGetMinX(self.qflowerImageView.frame)+TEXT_PADDING*2,CGRectGetHeight(self.qTitleNameLabel.frame)};
}


@end
