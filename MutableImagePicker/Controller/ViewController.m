//
//  ViewController.m
//  MutableImagePicker
//
//  Created by WP_YK on 16/7/7.
//  Copyright © 2016年 WP_YK. All rights reserved.
//

#import "ViewController.h"
#import <Photos/Photos.h>
#import "MutaImgPickerController.h"
#import "ChoosedImageCell.h"

#define kChooseImageCell @"chooseImageCell"

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ChooseImagesDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *imagesCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *chooseImgBtn;

/** 图片管理者 */
@property (nonatomic, strong) PHCachingImageManager *imageManager;

/** 图片model数组 */
@property (nonatomic, strong) NSMutableArray<PhotoModel *> *imageModelArr;
/** 图片数组 */
@property (nonatomic, strong) NSMutableArray *imagesArr;

@end

@implementation ViewController
#pragma mark - 懒加载
- (PHCachingImageManager *)imageManager {
    if (!_imageManager) {
        _imageManager = [[PHCachingImageManager alloc] init];
    }
    return _imageManager;
}

- (NSMutableArray *)imageModelArr {
    if(!_imageModelArr) {
        _imageModelArr = [NSMutableArray array];
    }
    return _imageModelArr;
}

- (NSMutableArray *)imagesArr {
    if(!_imagesArr) {
        _imagesArr = [NSMutableArray array];
    }
    return _imagesArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupCollectionView];
    self.chooseImgBtn.layer.cornerRadius = self.chooseImgBtn.bounds.size.height/2;
    
}

- (void)setupCollectionView {
    
    // 注册cell
    [self.imagesCollectionView registerNib:[UINib nibWithNibName:@"ChoosedImageCell" bundle:nil] forCellWithReuseIdentifier:kChooseImageCell];
}

- (IBAction)chooseImages:(id)sender {
    
    MutaImgPickerController *imgPickerVC = [[MutaImgPickerController alloc] init];
    imgPickerVC.delegate = self;
    NSMutableArray *array = [NSMutableArray array];
    for (int i=0;i<self.imageModelArr.count;i++) {
        [array addObject:self.imageModelArr[i]];
    }
    imgPickerVC.selectedImagesArr = array;
    [self presentViewController:imgPickerVC animated:YES completion:nil];
}
- (IBAction)deleteImage:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    [self.imagesArr removeObjectAtIndex:btn.tag];
    [self.imagesCollectionView reloadData];
    
    [self.imageModelArr removeObjectAtIndex:btn.tag];
}

/** 从图片资源解析出图片 */
- (void)analysisImages {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.imageModelArr.count<1) {
        [self.imagesArr removeAllObjects];
    }
    else {
        
        for (int i=0;i<self.imageModelArr.count;i++) {
            
            __weak typeof(self) weakSelf = self;
            PhotoModel *model = self.imageModelArr[i];
            
            [weakSelf.imageManager requestImageForAsset:model.asset
                                             targetSize:PHImageManagerMaximumSize
                                            contentMode:PHImageContentModeAspectFill
                                                options:nil
                                          resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                              
                                              [dic setObject:result forKey:[NSString stringWithFormat:@"%d",i]];
                                              if (dic.count == weakSelf.imageModelArr.count) {
                                                  [weakSelf sortImagesWithDic:dic];
                                              }
                                          }];
            
            
        }
    }
}

/** 对图片进行排序 */
- (void)sortImagesWithDic:(NSMutableDictionary *)dic {
    
    __weak typeof(self) weakSelf = self;
    [weakSelf.imagesArr removeAllObjects];
    for (int i=0;i<dic.count;i++) {
        
        NSString *key = [NSString stringWithFormat:@"%d",i];
        UIImage *image = [dic objectForKey:key];
        [weakSelf.imagesArr addObject:image];
    }
    
    [weakSelf.imagesCollectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imagesArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ChoosedImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kChooseImageCell forIndexPath:indexPath];
    UIImage *image = self.imagesArr[indexPath.item];
    [cell setWithImage:image indexPath:indexPath];
    return cell;
}

// 设置cell的size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(90, 90);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 0, 0);
    return insets;
}

// 设置cell的最小行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

#pragma mark - ChooseImagesDelegate
- (void)postSelectedImages:(NSMutableArray *)imagesArray {
    
    [self.imageModelArr removeAllObjects];
    for (int i=0;i<imagesArray.count;i++) {
        
        [self.imageModelArr addObject:imagesArray[i]];
    }
    
    [self analysisImages];
}

@end
