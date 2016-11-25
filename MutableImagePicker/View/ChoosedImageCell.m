//
//  ChoosedImageCell.m
//  MutableImagePicker
//
//  Created by WP_YK on 16/7/7.
//  Copyright © 2016年 WP_YK. All rights reserved.
//

#import "ChoosedImageCell.h"

@interface ChoosedImageCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@end

@implementation ChoosedImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setWithImage:(UIImage *)image indexPath:(NSIndexPath *)indexPath {
    
    self.imageView.image = image;
    self.deleteBtn.tag = indexPath.item;
}


@end
