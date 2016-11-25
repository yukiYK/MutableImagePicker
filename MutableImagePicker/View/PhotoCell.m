//
//  PhotoCell.m
//  MutableImagePicker
//
//  Created by WP_YK on 16/7/7.
//  Copyright © 2016年 WP_YK. All rights reserved.
//

#import "PhotoCell.h"

@interface PhotoCell ()

@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UIImageView *chooseImageView;

@property (weak, nonatomic) IBOutlet UIImageView *takePhotoImageView;
@property (weak, nonatomic) IBOutlet UILabel *takePhotoLabel;

@end

@implementation PhotoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setImagePickerWithImage:(UIImage *)mainImage isFirstCell:(BOOL)isFirstCell {
    
    self.isSelected = NO;
    self.takePhotoImageView.hidden = YES;
    self.takePhotoLabel.hidden = YES;
    
    if (!isFirstCell) {
        
        self.mainImageView.hidden = NO;
        self.chooseImageView.hidden = NO;
        self.mainImageView.image = mainImage;
    }
    else {
        self.mainImageView.hidden = YES;
        self.chooseImageView.hidden = YES;
        self.takePhotoLabel.hidden = NO;
        self.takePhotoImageView.hidden = NO;
    }
    
}

- (void)setIsSelected:(BOOL)isSelected {
    
    _isSelected = isSelected;
    self.chooseImageView.image = isSelected?[UIImage imageNamed:@"imagePicker_selected"]:[UIImage imageNamed:@"imagePicker"];
}

@end
