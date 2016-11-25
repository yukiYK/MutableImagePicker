//
//  PhotoCell.h
//  MutableImagePicker
//
//  Created by WP_YK on 16/7/7.
//  Copyright © 2016年 WP_YK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCell : UICollectionViewCell

@property (nonatomic, assign) BOOL isSelected;

- (void)setImagePickerWithImage:(UIImage *)mainImage isFirstCell:(BOOL)isFirstCell;

- (void)setIsSelected:(BOOL)isSelected;

@end
