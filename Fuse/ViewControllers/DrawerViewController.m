//
//  DrawerViewController.m
//  Fuse
//
//  Created by Tommy Brown on 9/18/15.
//  Copyright (c) 2015 tjl. All rights reserved.
//

#import "DrawerViewController.h"
#import "AppDelegate.h"
#import <MMDrawerBarButtonItem.h>
#import "SearchViewController.h"
#import "PlaylistViewController.h"
#import "DiscoveryViewController.h"

@interface DrawerViewController ()
{
    int selectedRow;
}
@end

@implementation DrawerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Fuse";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    selectedRow = 2;
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"DrawerCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSString *cellText = @"";
    UIImage *image;
    
    switch(indexPath.row){
        case 0:
            cellText = @"Discovery";
            image = [UIImage imageNamed:@"headphones.png"];
            break;
        case 1:
            cellText = @"Search";
            image = [UIImage imageNamed:@"search.png"];
            break;
        case 2:
            cellText = @"Playlist";
            image = [UIImage imageNamed:@"list2.png"];
            break;
    }
    
    cell.imageView.image = image;
    cell.imageView.frame = CGRectMake(0, 0, 24, 24);
    cell.textLabel.text = cellText;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row != selectedRow){
        [tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:0] animated:YES];
        selectedRow = indexPath.row;
        
        UIViewController *viewController;
        switch(indexPath.row){
            case 0:
                viewController = [[DiscoveryViewController alloc] initWithNibName:@"DiscoveryViewController" bundle:nil];
                break;
            case 1:
                viewController = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
                break;
            case 2:
                viewController = [[PlaylistViewController alloc] initWithNibName:@"PlaylistViewController" bundle:nil];
                break;
        }
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
        ((AppDelegate *)[[UIApplication sharedApplication] delegate]).drawerController.centerViewController = nav;
    }
    
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]).drawerController closeDrawerAnimated:YES completion:nil];
}

@end
