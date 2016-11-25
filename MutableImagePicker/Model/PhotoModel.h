//
//  PhotoModel.h
//  MutableImagePicker
//
//  Created by WP_YK on 16/7/7.
//  Copyright © 2016年 WP_YK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface PhotoModel : UIViewController

@property (nonatomic, strong) PHAsset *asset;  // 照片模型
@property (nonatomic, copy) NSString *localIdentifier;  // 照片id

@end
