//
//  AlbumInfo.h
//  MutableImagePicker
//
//  Created by WP_YK on 16/7/8.
//  Copyright © 2016年 WP_YK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface AlbumInfo : NSObject

@property (nonatomic, copy) NSString * albumName; //相册名字

@property (nonatomic, assign) NSInteger count; //总照片数

@property (nonatomic, strong) PHAssetCollection * assetCollection; //相册

@property (nonatomic, strong) PHAsset * coverAsset; //封面

+ (instancetype)infoFromResult:(PHFetchResult *)result collection:(PHAssetCollection *)collection;

@end
