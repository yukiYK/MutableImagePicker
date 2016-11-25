//
//  MutaImgPickerController.m
//  MutableImagePicker
//
//  Created by WP_YK on 16/7/7.
//  Copyright © 2016年 WP_YK. All rights reserved.
//

#import "MutaImgPickerController.h"
#import "PhotoCell.h"
//#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "SVProgressHUD.h"
#import "AlbumInfo.h"
#import "AlbumCell.h"

#define kPhotoCell  @"photoCell"
#define kAlbumCell  @"albumCell"
#define screenHeight [UIScreen mainScreen].bounds.size.height
#define screenWidth [UIScreen mainScreen].bounds.size.width
#define albumCellHeight  60
#define albumTableViewHeight  400

@interface MutaImgPickerController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPhotoLibraryChangeObserver, UITableViewDelegate, UITableViewDataSource>


@property (weak, nonatomic) IBOutlet UIButton *completeBtn;
@property (weak, nonatomic) IBOutlet UICollectionView *imagesCollectionView;

@property (weak, nonatomic) IBOutlet UIButton *chooseAlbumBtn;
@property (weak, nonatomic) IBOutlet UITableView *albumTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *albumTableHeightCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *albumTableTopCons;

// 显示albumTableView时的黑色透明遮罩
@property (nonatomic, strong) UIButton *hideButton;

@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) PHFetchResult *allImages;

@property (nonatomic, strong) NSMutableDictionary *dicOfImages;

@property (nonatomic, strong) NSMutableArray<AlbumInfo *> *albumArr;
@property (nonatomic, assign) BOOL isShowBigImage;

@end

@implementation MutaImgPickerController
#pragma mark - 懒加载
- (PHCachingImageManager *)imageManager {
    if (!_imageManager) {
        _imageManager = [[PHCachingImageManager alloc] init];
    }
    return _imageManager;
}

- (NSMutableArray *)selectedImagesArr {
    if (!_selectedImagesArr) {
        _selectedImagesArr = [NSMutableArray array];
    }
    return _selectedImagesArr;
}

- (NSMutableDictionary *)dicOfImages {
    if (!_dicOfImages) {
        _dicOfImages = [NSMutableDictionary dictionary];
    }
    return _dicOfImages;
}

- (NSMutableArray *)albumArr {
    if (!_albumArr) {
        _albumArr = [NSMutableArray array];
    }
    return _albumArr;
}

#pragma mark - <Life Cycle>
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBarHidden = YES;
    [SVProgressHUD setMinimumDismissTimeInterval:0.5];  // 设置HUD控件的展示时间
    
    [self findAllImages];
    [self setupCollectionView];
    [self setupAlbumTableView];
    
    // 添加相册改变监听
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    self.isShowBigImage = NO;
}

- (void)findAllImages {
    
//    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
//    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
//    self.allImages = [PHAsset fetchAssetsWithOptions:allPhotosOptions];
    
    self.allImages = [self fetchResultInCollection:nil asending:NO];
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)setupCollectionView {
    
    [self.imagesCollectionView registerNib:[UINib nibWithNibName:@"PhotoCell" bundle:nil] forCellWithReuseIdentifier:kPhotoCell];
    
    if (self.selectedImagesArr.count<1) {
        [self.completeBtn setTitle:@"完成" forState:UIControlStateNormal];
    }
    else {
        [self.completeBtn setTitle:[NSString stringWithFormat:@"完成(%ld/9)",_selectedImagesArr.count] forState:UIControlStateNormal];
    }
}

- (void)setupAlbumTableView {
    
    [self.albumTableView registerNib:[UINib nibWithNibName:@"AlbumCell" bundle:nil] forCellReuseIdentifier:kAlbumCell];
    self.albumTableView.rowHeight = albumCellHeight;
}

/** 获取所有相册 */
- (NSMutableArray<AlbumInfo *> *)getAllAblums {
    
    NSMutableArray *allAlbumArray = [NSMutableArray array];
    // 添加所有的智能相册
    PHFetchResult *smartAblums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [allAlbumArray addObjectsFromArray:[self fetchCollection:smartAblums]];
    
    // 添加所有用户创建的相册
    PHFetchResult *userCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    [allAlbumArray addObjectsFromArray:[self fetchCollection:userCollections]];
    
    return allAlbumArray;
}

/** 获取相册资源 */
- (NSMutableArray *)fetchCollection:(PHFetchResult *)fetchResult {
    
    NSMutableArray *array = [NSMutableArray array];
    // 遍历取值
    [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:[PHAssetCollection class]]) {
            
            PHFetchResult *result = [self fetchResultInCollection:obj asending:NO];
            
            if (result.count) {
                AlbumInfo *info = [AlbumInfo infoFromResult:result collection:obj];
                
                [array addObject:info];
            }
        }
    }];
    return array;
}

// 获取 指定相册 或 所有相册 里的图片资源合集，并按资源的创建时间排序 YES正序 NO倒叙
- (PHFetchResult *)fetchResultInCollection:(PHAssetCollection *)collection asending:(BOOL)asending {
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:asending]];
    
    PHFetchResult *result;
    if (collection) {
        result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
    }
    else {
        result = [PHAsset fetchAssetsWithOptions:option];
    }
    return result;
}

// 获取 指定相册 或 所有相册 里的图片资源  存放PHAsset的数组  ->好像没什么用，暂注掉
//- (NSArray<PHAsset *> *)fetchAssetInfoCollection:(PHAssetCollection *)collection asending:(BOOL)asending {
//    
//    NSMutableArray<PHAsset *> * list = [NSMutableArray array];
//    
//    PHFetchResult * result;
//    
//    //获取指定相册资源
//    if (collection) {
//        
//        result = [self fetchResultInCollection:collection asending:asending];
//    }
//    //获取所有相册资源
//    else {
//        
//        result = [self fetchResultInCollection:nil asending:asending];
//        
//    }
//    
//    //枚举添加到数组
//    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        
//        [list addObject:obj];
//    }];
//    
//    return list;
//}

- (IBAction)cancelAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

/** 完成按钮事件 */
- (IBAction)completeAction:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(postSelectedImages:)]) {
        
        [self.delegate postSelectedImages:self.selectedImagesArr];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

/** 选择相册按钮事件 */
- (IBAction)chooseAblum:(id)sender {
    
    [self.albumArr removeAllObjects];
    [self.albumArr addObjectsFromArray:[self getAllAblums]];
//    self.albumArr = [NSMutableArray arrayWithArray:[self getAllAblums]];
    [self.albumTableView reloadData];
    
    
    
#pragma mark - 后来添加的，暂时这么实现。做成tableView的背景比较好
    // 添加一层按钮，用于隐藏albumTableView
    UIButton *blackButton = [[UIButton alloc] initWithFrame:self.view.bounds];
    [blackButton addTarget:self action:@selector(hideAlbumTableView:) forControlEvents:UIControlEventTouchUpInside];
    blackButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    [self.view addSubview:blackButton];
    self.hideButton = blackButton;
    
    
    CGFloat tableHeight = self.albumArr.count * albumCellHeight;
    if (tableHeight > albumTableViewHeight) {
        tableHeight = albumTableViewHeight;
    }
    
    
    [UIView animateWithDuration:0.2 animations:^{
        
        self.albumTableHeightCons.constant = tableHeight;
        self.albumTableTopCons.constant = -tableHeight;
        blackButton.frame = CGRectMake(0, 0, screenWidth, screenHeight-tableHeight);
        [self.view layoutIfNeeded];
    }];
    
//    self.chooseAlbumBtn.hidden = YES;

}

- (void)hideAlbumTableView:(UIButton *)button {
    
    [button removeFromSuperview];
    
    [UIView animateWithDuration:0.2 animations:^{
        
        self.albumTableHeightCons.constant = 0;
        self.albumTableTopCons.constant = 0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.chooseAlbumBtn.hidden = NO;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.allImages.count+1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCell forIndexPath:indexPath];
    if (indexPath.item == 0) {
        [cell setImagePickerWithImage:nil isFirstCell:YES];
    }
    else {
        PHAsset *asset = self.allImages[indexPath.item-1];
        
        // 这里做了下优化，如果此图片已经解析得到，则直接从dicOfImages字典中取
        if ([self.dicOfImages.allKeys containsObject:asset.localIdentifier]) {
            
            UIImage *image = [self.dicOfImages objectForKey:asset.localIdentifier];
            [cell setImagePickerWithImage:image isFirstCell:NO];
            
            for (PhotoModel *phModel in self.selectedImagesArr) {
                
                if ([phModel.localIdentifier isEqualToString:asset.localIdentifier]) {
                    cell.isSelected = YES;
                }
            }
        }
        // 如果图片还没得到，则从allImages数组中解析得到图片
        else {
            
            __weak typeof(self) weakSelf = self;
            CGSize size = cell.frame.size;
            size.width *= 2;
            size.height *= 2;
            [self.imageManager requestImageForAsset:asset
                                         targetSize:size
                                        contentMode:PHImageContentModeAspectFit
                                            options:nil
                                      resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                          
                                          [cell setImagePickerWithImage:result isFirstCell:NO];
                                          [weakSelf.dicOfImages setObject:result forKey:asset.localIdentifier];
                                          
                                          for (PhotoModel *phModel in weakSelf.selectedImagesArr) {
                                              
                                              if ([phModel.localIdentifier isEqualToString:asset.localIdentifier]) {
                                                  cell.isSelected = YES;
                                              }
                                          }
                                      }];
        }
        
        cell.contentView.tag = 1000+indexPath.item-1;
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        [cell.contentView addGestureRecognizer:longPress];
        
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item == 0) {
        
        if (self.selectedImagesArr.count >= 9) {
            [SVProgressHUD showErrorWithStatus:@"最对只能选取9张图片"];
        }
        else {
            //打开照相机拍照
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                
                UIImagePickerController *imagePickerC = [[UIImagePickerController alloc] init];
                imagePickerC.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePickerC.delegate = self;
                [self presentViewController:imagePickerC animated:YES completion:nil];
            }
            else {
                [SVProgressHUD showErrorWithStatus:@"您的设备不支持相机"];
            }
        }
    }
    else {
        
#pragma mark - 这里逻辑有待优化
        PhotoCell *cell = (PhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
        BOOL isSelected = !cell.isSelected;
        PHAsset *asset = self.allImages[indexPath.item-1];
        if (isSelected) {
            
            PhotoModel *model = [[PhotoModel alloc] init];
            model.asset = asset;
            model.localIdentifier = asset.localIdentifier;
            if (self.selectedImagesArr.count>8) {
            }
            else {
                cell.isSelected = isSelected;
                [self.selectedImagesArr addObject:model];
                if (self.selectedImagesArr.count<1) {
                    [self.completeBtn setTitle:@"完成" forState:UIControlStateNormal];
                }
                else {
                    [self.completeBtn setTitle:[NSString stringWithFormat:@"完成(%ld/9)",_selectedImagesArr.count] forState:UIControlStateNormal];
                }
            }
        }
        else {
            cell.isSelected = isSelected;
            for (PhotoModel *model in self.selectedImagesArr) {
                
                if ([model.asset isEqual:asset]) {
                    
                    [self.selectedImagesArr removeObject:model];
                    
                    if (self.selectedImagesArr.count<1) {
                        [self.completeBtn setTitle:@"完成" forState:UIControlStateNormal];
                    }
                    else {
                        [self.completeBtn setTitle:[NSString stringWithFormat:@"完成(%ld/9)",_selectedImagesArr.count] forState:UIControlStateNormal];
                    }
                    return;
                }
            }
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((screenWidth-30)/3, (screenWidth-30)/3);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 0, 0);
    return insets;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

#pragma mark - PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    
    __weak typeof(self) weakSelf = self;
    dispatch_sync(dispatch_get_main_queue(), ^{
        [weakSelf findAllImages];
        [weakSelf.imagesCollectionView reloadData];
    });
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    NSLog(@"拍照完成");
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (image == nil) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    // 写入相册
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

// 指定回调方法
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    [self findAllImages];
    PHAsset *asset = self.allImages[0];
    PhotoModel *model = [[PhotoModel alloc] init];
    model.asset = asset;
    model.localIdentifier = asset.localIdentifier;
    [self.selectedImagesArr addObject:model];
    [self.completeBtn setTitle:[NSString stringWithFormat:@"完成(%ld/9)",_selectedImagesArr.count] forState:UIControlStateNormal];
    
    [self.completeBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

/** 长按事件 */
- (void)longPressAction:(UILongPressGestureRecognizer *)longPress {
    
    NSInteger index = longPress.view.tag - 1000;
    
    PHAsset *asset = self.allImages[index];
    __weak typeof(self) weakSelf = self;
    [self.imageManager requestImageForAsset:asset
                                 targetSize:PHImageManagerMaximumSize
                                contentMode:PHImageContentModeAspectFill
                                    options:nil
                              resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                  
                                  // 由于此block会多次执行，所以设定了此标识isShowBigImage
                                  if (!weakSelf.isShowBigImage) {
                                      [weakSelf showBigImage:result];
                                      weakSelf.isShowBigImage = YES;
                                  }
                              }];
    
    
}
/** 放大图片 */
-(void)showBigImage:(UIImage *)image
{
    UIView *bigView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (screenWidth-30)/3, (screenWidth-30)/3)];
    bigView.center = self.view.center;
    bigView.backgroundColor = [UIColor blackColor];
    
    
    CGSize imageSize = image.size;
    CGFloat imageViewWith = self.view.frame.size.width;
    CGFloat imageViewHeight = imageSize.height*imageViewWith/imageSize.width;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, bigView.frame.size.width, bigView.frame.size.height)];
    imageView.image = image;
    imageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bigView];
    [bigView addSubview:imageView];
    
    
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.2];
//    bigView.bounds = self.view.bounds;
//    imageView.bounds = CGRectMake(0, 0, imageViewWith, imageViewHeight);
//    imageView.center = bigView.center;
//    [UIView commitAnimations];
    
    [UIView animateWithDuration:0.2 animations:^{
        bigView.bounds = self.view.bounds;
        imageView.bounds = CGRectMake(0, 0, imageViewWith, imageViewHeight);
        imageView.center = bigView.center;
    } completion:^(BOOL finished) {
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeBigView:)];
    [bigView addGestureRecognizer:tap];
}

//关闭放大图片
-(void)closeBigView:(UITapGestureRecognizer *)tap
{
    [tap.view removeFromSuperview];
    self.isShowBigImage = NO;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albumArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:kAlbumCell];
    
    AlbumInfo *info = self.albumArr[indexPath.row];
    [cell setWithAlbumInfo:info];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [UIView animateWithDuration:0.2 animations:^{
        
        self.albumTableHeightCons.constant = 0;
        self.albumTableTopCons.constant = 0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.chooseAlbumBtn.hidden = NO;
    }];
    
    [self.hideButton removeFromSuperview];
    
    // 根据选择的相册 重新加载collectionView
    AlbumInfo *info = self.albumArr[indexPath.row];
    self.allImages = [self fetchResultInCollection:info.assetCollection asending:NO];
    [self.imagesCollectionView reloadData];
}



@end
