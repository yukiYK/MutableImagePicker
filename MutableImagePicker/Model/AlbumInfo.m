//
//  AlbumInfo.m
//  MutableImagePicker
//
//  Created by WP_YK on 16/7/8.
//  Copyright © 2016年 WP_YK. All rights reserved.
//

#import "AlbumInfo.h"

@implementation AlbumInfo

+ (instancetype)infoFromResult:(PHFetchResult *)result collection:(PHAssetCollection *)collection {
    AlbumInfo * albumInfo = [[AlbumInfo alloc]init];
    albumInfo.albumName = collection.localizedTitle;
    albumInfo.count = result.count;
    albumInfo.coverAsset = result[0];
    albumInfo.assetCollection = collection;
    return albumInfo;
}

@end
