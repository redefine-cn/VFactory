//
//  DoCoCollectionVew.h
//  doco_ios_app
//
//  Created by developer on 15/4/26.
//  Copyright (c) 2015年 developer. All rights reserved.
//

@protocol DoCoCollectionViewDelegate;
@interface DoCoCollectionView : UIView

@property(nonatomic,strong)UICollectionView *collectionView;

@property(nonatomic,strong)NSArray *datas;
@property(nonatomic,assign)CGSize itemSize;
@property(nonatomic,assign)float itemColumnSpace;
@property(nonatomic,assign)float itemRowSpace;
@property(nonatomic,copy)NSString *privateKey;
@property(nonatomic,strong)UIButton *leftBtn;
@property(nonatomic,strong)UIButton *rightBtn;

@property(nonatomic,strong)UIColor *selectedColor;
@property(nonatomic,strong)UIColor *unSelectColor;
@property(nonatomic,weak)id<DoCoCollectionViewDelegate> docoDelegate;

-(instancetype)initWithFrame:(CGRect)frame dataSource:(NSArray *)datas itemSize:(CGSize)itemSize itemColumnSpace:(float)itemComlumnSpace itemRowSpace:(float)itemRowSpace privateKey:(NSString *)privateKey ;

- (void)selectItemAtIndexPath:(NSUInteger)indexPath animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)scrollPosition;

-(void)scrollToItemAtIndexPath:(NSUInteger)indexPath animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)scrollPosition;
@end

@interface DoCoCollectionCell : UICollectionViewCell
@property(nonatomic,strong)UIView *view;
@end

@protocol DoCoCollectionViewDelegate <NSObject>

@optional
-(void)itemDidSelectedWithIndex:(NSUInteger)index forKey:(NSString *)privateKey collection:(UICollectionView *)collection;

-(void)itemDidDeselectedWithIndex:(NSUInteger)index forKey:(NSString *)privateKey collection:(UICollectionView *)collection;


@end



