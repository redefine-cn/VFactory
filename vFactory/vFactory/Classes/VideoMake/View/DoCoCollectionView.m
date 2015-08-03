//
//  DoCoCollectionVew.m
//  doco_ios_app
//
//  Created by developer on 15/4/26.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "DoCoCollectionView.h"
#import "ViewToolkit.h"
#import <math.h>

@interface DoCoCollectionView()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,UIScrollViewDelegate>
@end

@implementation DoCoCollectionView

-(instancetype)initWithFrame:(CGRect)frame dataSource:(NSArray *)datas itemSize:(CGSize)itemSize itemColumnSpace:(float)itemColumnSpace itemRowSpace:(float)itemRowSpace privateKey:(NSString *)privateKey {
    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];


    self = [super initWithFrame:frame];
    if (self) {
        _datas = datas;
        _itemSize = itemSize;
        _itemColumnSpace = itemColumnSpace;
        _itemRowSpace = itemRowSpace;
        _privateKey = @"DoCo";
        self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width,frame.size.height) collectionViewLayout:aFlowLayout];
        
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        
        if (privateKey) {
            _privateKey = privateKey;
        }
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.showsVerticalScrollIndicator = NO;
        self.collectionView.allowsMultipleSelection = NO;
        self.collectionView.allowsSelection = YES;
        self.collectionView.backgroundColor = [UIColor clearColor];
        [self.collectionView registerClass:[DoCoCollectionCell class] forCellWithReuseIdentifier:@"Cell"];
        [self addSubview:_collectionView];
    }
    return  self;
}

- (void)selectItemAtIndexPath:(NSUInteger)indexPath animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)scrollPosition{
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathWithIndex:indexPath] animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)scrollPosition];
}
//将某个cell滚动到指定位置
-(void)scrollToItemAtIndexPath:(NSUInteger)indexPath animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)scrollPosition{
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:indexPath inSection:0] atScrollPosition:scrollPosition animated:animated];
}



#pragma mark-实现UICollectionView的代理
//返回几行  从0开始
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
//返回每行几个
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.datas.count;
}
//返回cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DoCoCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    if(cell){
        float y = (CGRectGetHeight(self.frame) - _itemSize.height)/2;
        [ViewToolkit setView:cell toOriginY:y];
        cell.clipsToBounds = YES;
        UIView *view = _datas[indexPath.row];
        [cell addSubview:view];
        if (_selectedColor) {
            [cell.layer setBorderColor:_selectedColor.CGColor];
        }
        
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    UIView *view = _datas[indexPath.row];
    [view removeFromSuperview];
}

//cell的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _itemSize;
}
//行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return _itemRowSpace;
}
//列间距
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return _itemColumnSpace;
}
//是否应该高亮
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{


}
- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{

}

//选择事件的代理
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

//实现点击cell事件
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor clearColor];
    if (_selectedColor) {
        cell.backgroundColor = _selectedColor;
    }
    if([self.docoDelegate respondsToSelector:@selector(itemDidSelectedWithIndex:forKey:collection:)]){
        
        [self.docoDelegate itemDidSelectedWithIndex:indexPath.row forKey:_privateKey collection:collectionView];
    }
    
}
//取消点击
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [cell.layer setBorderWidth:0];
    cell.backgroundColor = [UIColor clearColor];
    if (_unSelectColor) {
        cell.backgroundColor = _unSelectColor;
    }
    
    if ([self.docoDelegate respondsToSelector:@selector(itemDidDeselectedWithIndex:forKey:collection:)]) {
        [self.docoDelegate itemDidDeselectedWithIndex:indexPath.row forKey:_privateKey collection:collectionView];
    }
}
//
#pragma mark-滚动代理
//减速停止
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
}
//将开始减速
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    
}
//已经松手
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
}

//已经开始滚动   一直响应
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

@implementation DoCoCollectionCell
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;

}
@end
