//
//  AlbumCell.m
//  MutableImagePicker
//
//  Created by WP_YK on 16/7/8.
//  Copyright © 2016年 WP_YK. All rights reserved.
//

#import "AlbumCell.h"
#import <Photos/Photos.h>

@interface AlbumCell ()

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;

@property (weak, nonatomic) IBOutlet UILabel *albumNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *imageCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectedView;

@property (nonatomic, strong) PHCachingImageManager *imageManager;

@end

@implementation AlbumCell
- (PHCachingImageManager *)imageManager {
    if (!_imageManager) {
        _imageManager = [[PHCachingImageManager alloc] init];
    }
    return _imageManager;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
    self.selectedView.hidden = !selected;
}

- (void)setWithAlbumInfo:(AlbumInfo *)albumInfo {
    
    PHAsset *asset = albumInfo.coverAsset;
    CGSize size = CGSizeMake(55*3, 50*3);
    [self.imageManager requestImageForAsset:asset
                                 targetSize:size
                                contentMode:PHImageContentModeAspectFit
                                    options:nil
                              resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                  
                                  self.coverImageView.image = result;
                              }];
    self.albumNameLabel.text = [self getChineseName:albumInfo.albumName];
    self.imageCountLabel.text = [NSString stringWithFormat:@"(%ld)",albumInfo.count];
}

- (NSString *)getChineseName:(NSString *)engName {
    NSArray * engNameList = @[@"All Photos", @"Recently Added", @"Camera Roll", @"Videos", @"Favorites", @"Screenshots", @"Recently Deleted"];
    NSArray * chineseNameList = @[@"所有照片", @"最近添加", @"相机胶卷", @"视频", @"最爱", @"屏幕快照", @"最近删除"];
    if ([engNameList containsObject:engName]) {
        NSInteger index = [engNameList indexOfObject:engName];
        return chineseNameList[index];
    }
    return engName;
}

@end
