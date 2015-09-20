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
#import "SavedPlaylistManager.h"

@interface SearchViewController (){
    NSMutableArray *songsArray;
    AFHTTPRequestOperationManager *afManager;
    SavedPlaylistManager *savedPlaylistManager;
    NSTimer *ppTimer;
}
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _songManager = [SongManager getSharedInstance];
    
    self.navigationItem.title = @"Search";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    _spotifyPlayer = [SpotifyPlayer getSharedPlayer];
    afManager = [AFHTTPRequestOperationManager manager];
    savedPlaylistManager = [SavedPlaylistManager getSharedInstance];
    
    songsArray = [[NSMutableArray alloc] init];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    _searchBar.placeholder = @"Enter Track Name";
    _searchBar.delegate = self;
    _searchBar.showsCancelButton = YES;
    
    self.navigationItem.leftBarButtonItem = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(menuButtonPressed:)];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    ppTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(ppTimerFired) userInfo:nil repeats:YES];
}

- (void) viewWillDisappear:(BOOL)animated{
    [ppTimer invalidate];
    ppTimer = nil;
    [super viewWillDisappear:animated];
}

#pragma mark - Timer

- (void) ppTimerFired{
    if(_songManager.isPlaying){
        _ppButton.image = [UIImage imageNamed:@"pause.png"];
    }else{
        _ppButton.image = [UIImage imageNamed:@"play2.png"];
    }
}

- (void) getSoundcloudResultsForString:(NSString *)searchString{
    NSDictionary *parameters = @{@"q" : searchString, @"client_id" : SOUNDCLOUD_CLIENT_ID};
    
    [afManager GET:@"http://api.soundcloud.com/tracks" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *jsonData = responseObject;
        NSMutableArray *trackArray = [[NSMutableArray alloc] init];
        for(NSDictionary *data in jsonData){
            [trackArray addObject:[[SoundcloudTrack alloc] initWithJSON:data]];
        }
        
        for(int i = 1; i <= trackArray.count; i++){
            long insertLocation = i * 2;
            long currentSize = songsArray.count;
            if(insertLocation < currentSize - 1){
                [songsArray insertObject:[trackArray objectAtIndex:i - 1] atIndex:insertLocation];
            }else{
                [songsArray addObject:[trackArray objectAtIndex:i - 1]];
            }
        }
        
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

- (IBAction) accessoryButtonPressed:(UIButton *)sender{
    NSObject *genericTrack = [songsArray objectAtIndex:sender.tag];
    if([genericTrack.class isSubclassOfClass:[SPTPartialTrack class]]){
        SPTPartialTrack *track = (SPTPartialTrack *) genericTrack;
        [savedPlaylistManager addSpotifyTrack:track];
    }else{
        SoundcloudTrack *track = (SoundcloudTrack *) genericTrack;
        [savedPlaylistManager addSoundcloudTrack:track];
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
    return songsArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"SearchCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
    }
    
    NSObject *genericTrack = [songsArray objectAtIndex:indexPath.row];
    
    NSArray *playlist = [savedPlaylistManager savedPlaylist];
    NSString *trackId = @"";
    
    UIButton *button = [[UIButton alloc] init];
    [button setImage:[UIImage imageNamed:@"IcnPlus"] forState:UIControlStateNormal];
    button.tag = indexPath.row;
    [button addTarget:self action:@selector(accessoryButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = button;
    [cell.accessoryView setFrame:CGRectMake(0, 0, 24, 24)];
    
    if([genericTrack.class isSubclassOfClass:[SPTPartialTrack class]]){
        SPTPartialTrack *track = (SPTPartialTrack *) genericTrack;
        trackId = track.uri.absoluteString;
        cell.textLabel.text = track.name;
        cell.detailTextLabel.text = ((SPTPartialArtist *)[track.artists objectAtIndex:0]).name;
    }else{
        SoundcloudTrack *track = (SoundcloudTrack *) genericTrack;
        cell.textLabel.text = track.trackName;
        cell.detailTextLabel.text = track.artistName;
        trackId = track.trackId;
    }
    
    bool saved = NO;
    for(id gTrack in playlist){
        NSString *genericID = @"";
        if([[gTrack class] isSubclassOfClass:[SPTPartialTrack class]]){ // is spotify song
            genericID = ((SPTPartialTrack *) gTrack).uri.absoluteString;
        }else{ // is soundcloud song
            genericID = ((SoundcloudTrack *)gTrack).trackId;
        }
        
        if([genericID isEqualToString:trackId]){
            saved = YES;
            break;
        }
    }
    
    if(saved){
        cell.tintColor = [UIColor blueColor];
    }else{
        cell.tintColor = [UIColor redColor];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [_songManager setCurrentPlaylist:[NSArray arrayWithObject:[songsArray objectAtIndex:indexPath.row]]];
    [_songManager startTimer];
    [_songManager playSongAtIndex:0];
}

#pragma mark - UISearchBarDelegate

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [songsArray removeAllObjects];
    [SPTSearch performSearchWithQuery:searchBar.text queryType:SPTQueryTypeTrack accessToken:nil callback:^(NSError *error, SPTListPage *object) {
        [songsArray addObjectsFromArray:object.items];
        [self getSoundcloudResultsForString:searchBar.text];
        //[_tableView reloadData];
    }];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [_searchBar resignFirstResponder];
}

@end
