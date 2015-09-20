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
    return 4;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"DrawerCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSString *cellText = @"";
    
    switch(indexPath.row){
        case 0:
            cellText = @"Discovery";
            break;
        case 1:
            cellText = @"Search";
            break;
        case 2:
            cellText = @"Playlist";
            break;
        case 3:
            cellText = @"Options";
            break;
    }
    
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
            case 3:
                break;
        }
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
        ((AppDelegate *)[[UIApplication sharedApplication] delegate]).drawerController.centerViewController = nav;
    }
    
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]).drawerController closeDrawerAnimated:YES completion:nil];
}

@end
