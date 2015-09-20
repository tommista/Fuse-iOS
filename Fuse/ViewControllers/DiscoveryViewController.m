//
//  DiscoveryViewController.m
//  Fuse
//
//  Created by Tommy Brown on 9/19/15.
//  Copyright (c) 2015 tjl. All rights reserved.
//

#import "DiscoveryViewController.h"
#import <MMDrawerController/MMDrawerBarButtonItem.h>
#import "AppDelegate.h"
#import <AFNetworking/AFNetworking.h>

#define AROUND_ME 0
#define HYPE_MACHINE 1

@interface DiscoveryViewController ()

@end

@implementation DiscoveryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _songManager = [SongManager getSharedInstance];
    
    self.navigationItem.title = @"Discovery";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
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

- (IBAction) backButtonPressed:(id)sender{
    [_songManager previousSong];
}

- (IBAction) playPauseButtonPressed:(id)sender{
    [_songManager playPause];
}

- (IBAction) nextButtonPressed:(id)sender{
    [_songManager nextSong];
}

#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *discoveryCellIdentifier = @"Discovery_identifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:discoveryCellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:discoveryCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    switch(indexPath.row){
        case AROUND_ME:
            cell.textLabel.text = @"Around Me";
            break;
        case HYPE_MACHINE:
            cell.textLabel.text = @"Hype Machine";
            break;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch(indexPath.row){
        case AROUND_ME:{
            
        }break;
        case HYPE_MACHINE:{
            NSDictionary *parameters = @{@"type" : @"all", @"key" : @"swagger"};
            AFHTTPRequestOperationManager *afManager = [AFHTTPRequestOperationManager manager];
            [afManager GET:@"https://api.hypem.com/v2/featured" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSArray *jsonData = responseObject;
                NSLog(@"Stuf: %@", jsonData);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
        }break;
    }
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    [self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

@end
