//
//  MutaImgPickerController.h
//  MutableImagePicker
//
//  Created by WP_YK on 16/7/7.
//  Copyright © 2016年 WP_YK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoModel.h"

@protocol ChooseImagesDelegate <NSObject>

- (void)postSelectedImages:(NSMutableArray *)imagesArray;

@end

@interface MutaImgPickerController : UIViewController

@property (nonatomic, weak) id<ChooseImagesDelegate> delegate;

@property (nonatomic, strong) NSMutableArray<PhotoModel *> *selectedImagesArr;

@end
