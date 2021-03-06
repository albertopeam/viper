//
//  FavouriteCitiesViewController.m
//  viper
//
//  Created by vagrant on 10/10/17.
//  Copyright © 2017 vagrant. All rights reserved.
//

#import "FavouriteCitiesViewController.h"
#import "FavouriteCitiesDataSource.h"
#import "WeatherRouter.h"
#import "MBProgressHUD.h"

@interface FavouriteCitiesViewController ()

@end

@implementation FavouriteCitiesViewController{
    FavouriteCitiesDataSource* datasource;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self getFavoriteCities];
}

-(void)setup {
    self.navigationItem.title = @"Favourites";
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self
                        action:@selector(getFavoriteCities)
              forControlEvents:UIControlEventValueChanged];
    [_collectionView addSubview:_refreshControl];
    _collectionView.alwaysBounceVertical = YES;
    datasource = [FavouriteCitiesDataSource new];
    [_collectionView setDataSource:datasource];
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(deleteFavoriteCity:)];
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;
    [self.collectionView addGestureRecognizer:lpgr];
}

-(void)getFavoriteCities{
    [_presenter getFavoriteCities];
}

-(void)doYouWantToRemove:(FavoriteCity*)favCity{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Remove!"
                                 message:[NSString stringWithFormat:@"Are you sure to remove %@?", favCity.name]
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Yes"
                                style:UIAlertActionStyleDestructive
                                handler:^(UIAlertAction * action) {
                                    [_presenter removeFavoriteCity:favCity];
                                }];
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleCancel
                               handler:nil];
    [alert addAction:yesButton];
    [alert addAction:noButton];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark presenter interface
-(void)onGetFavoriteCities:(NSArray<FavoriteCity*>*)cities{
    [_searchBar setText:@""];
    [_searchBar endEditing:YES];
    [datasource setCities:cities];
    [_collectionView reloadData];
}

-(void)showLoading{
     [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

-(void)hideLoading{
    [_refreshControl endRefreshing];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(void)showError:(NSString*)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:nil];
    });
}

-(void)onRemovedFavoriteCity:(FavoriteCity *)favoriteCity{
    NSMutableArray*tmp = [datasource.cities mutableCopy];
    [tmp removeObject:favoriteCity];
    [datasource setCities:[NSArray arrayWithArray:tmp]];
    [_collectionView reloadData];
}

#pragma mark gestures
-(void)deleteFavoriteCity:(UILongPressGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    CGPoint p = [gestureRecognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
    if (indexPath){
        FavoriteCity*favCity = [datasource.cities objectAtIndex:indexPath.row];
        [self doYouWantToRemove:favCity];
    }
}

#pragma mark - CollectionView
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    FavoriteCity* favoriteCity = [[datasource cities] objectAtIndex:indexPath.row];
    UIViewController* viewController = [WeatherRouter provide:favoriteCity];
    [self.navigationController pushViewController:viewController animated:YES];

}

/*
- (void)collectionView:(UICollectionView *)colView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell = [colView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.1
                          delay:0
                        options:(UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         [cell setBackgroundColor:[UIColor colorWithRed:232/255.0f green:232/255.0f blue:232/255.0f alpha:1]];
                     }
                     completion:nil];
}

- (void)collectionView:(UICollectionView *)colView  didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell = [colView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.1
                          delay:0
                        options:(UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         [cell setBackgroundColor:[UIColor clearColor]];
                     }
                     completion:nil ];
}*/

#pragma mark - Search
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [_presenter addFavoriteCity:searchBar.text];
}

@end
