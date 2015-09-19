//
//  PlaylistViewController.m
//  Fuse
//
//  Created by Tommy Brown on 9/18/15.
//  Copyright (c) 2015 tjl. All rights reserved.
//

#import "PlaylistViewController.h"
#import "AppDelegate.h"
#import <MMDrawerBarButtonItem.h>

@interface PlaylistViewController ()

@end

@implementation PlaylistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _spotifyPlayer = [SpotifyPlayer getSharedPlayer];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.navigationItem.leftBarButtonItem = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(menuButtonPressed:)];
}

#pragma mark - Actions

- (IBAction) menuButtonPressed:(id)sender{
    if([((AppDelegate *)[[UIApplication sharedApplication] delegate]).drawerController openSide] == MMDrawerSideNone){
        [((AppDelegate *)[[UIApplication sharedApplication] delegate]).drawerController openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    }
    else{
        [((AppDelegate *)[[UIApplication sharedApplication] delegate]).drawerController closeDrawerAnimated:YES completion:nil];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"PlaylistCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSString *cellText = @"asdf";
    
    cell.textLabel.text = cellText;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
