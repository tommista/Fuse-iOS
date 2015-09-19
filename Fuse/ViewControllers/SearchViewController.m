//
//  SearchViewController.m
//  Fuse
//
//  Created by Tommy Brown on 9/18/15.
//  Copyright (c) 2015 tjl. All rights reserved.
//

#import "SearchViewController.h"
#import "AppDelegate.h"
#import "SpotifyPlayer.h"
#import "Secrets.h"
#import <MMDrawerBarButtonItem.h>
#import <AFNetworking/AFNetworking.h>
#import "SoundcloudTrack.h"

@interface SearchViewController (){
    NSMutableArray *songsArray;
    AFHTTPRequestOperationManager *afManager;
}
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _spotifyPlayer = [SpotifyPlayer getSharedPlayer];
    afManager = [AFHTTPRequestOperationManager manager];
    
    songsArray = [[NSMutableArray alloc] init];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    _searchBar.placeholder = @"Enter Track Name";
    _searchBar.delegate = self;
    
    self.navigationItem.leftBarButtonItem = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(menuButtonPressed:)];
}

- (void) getSoundcloudResultsForString:(NSString *)searchString{
    NSDictionary *parameters = @{@"q" : searchString, @"client_id" : SOUNDCLOUD_CLIENT_ID};
    
    [afManager GET:@"http://api.soundcloud.com/tracks" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *jsonData = responseObject;
        NSMutableArray *trackArray = [[NSMutableArray alloc] init];
        for(NSDictionary *data in jsonData){
            [trackArray addObject:[[SoundcloudTrack alloc] initWithJSON:data]];
            NSLog(@"%@", [trackArray lastObject]);
        }
        [songsArray addObjectsFromArray:trackArray];
        [_tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
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
    return songsArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"SearchCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
    }
    
    NSObject *genericTrack = [songsArray objectAtIndex:indexPath.row];
    
    if([genericTrack.class isSubclassOfClass:[SPTPartialTrack class]]){
        SPTPartialTrack *track = (SPTPartialTrack *) genericTrack;
        cell.textLabel.text = track.name;
        cell.detailTextLabel.text = ((SPTPartialArtist *)[track.artists objectAtIndex:0]).name;
        cell.backgroundColor = [UIColor greenColor];
    }else{
        SoundcloudTrack *track = (SoundcloudTrack *) genericTrack;
        cell.textLabel.text = track.trackName;
        cell.detailTextLabel.text = track.artistName;
        cell.backgroundColor = [UIColor orangeColor];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark - UISearchBarDelegate

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [songsArray removeAllObjects];
    [SPTSearch performSearchWithQuery:searchBar.text queryType:SPTQueryTypeTrack accessToken:nil callback:^(NSError *error, SPTListPage *object) {
        [songsArray addObjectsFromArray:object.items];
        [_tableView reloadData];
    }];
    [self getSoundcloudResultsForString:searchBar.text];
}

@end
