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
#import "Secrets.h"
#import <AVFoundation/AVFoundation.h>
#import "SongManager.h"
#import "SoundcloudTrack.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface PlaylistViewController ()
{
    NSArray *playlist;
    unsigned long selectedRow;
    NSTimer *ppTimer;
}
@end

@implementation PlaylistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Your Playlist";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    _songManager = [SongManager getSharedInstance];
    _savedPlaylistManager = [SavedPlaylistManager getSharedInstance];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.navigationItem.leftBarButtonItem = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(menuButtonPressed:)];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playlistDeserialized) name:DESERIALIZATION_FINISHED object:nil];
    ppTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(ppTimerFired) userInfo:nil repeats:YES];
}

- (void) viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DESERIALIZATION_FINISHED object:nil];
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

#pragma mark - Notifications

- (void) playlistDeserialized{
    [_tableView reloadData];
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
    return _savedPlaylistManager.savedPlaylist.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"PlaylistCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
    }
    
    id track = [_savedPlaylistManager.savedPlaylist objectAtIndex:indexPath.row];
    if([[track class] isSubclassOfClass:[SPTPartialTrack class]]){// spotify track
        SPTPartialTrack *spTrack = (SPTPartialTrack *) track;
        cell.textLabel.text = spTrack.name;
        cell.detailTextLabel.text = [spTrack.artists[0] name];
    }else if ([[track class] isSubclassOfClass:[SoundcloudTrack class]]){// soundcloud track
        SoundcloudTrack *scTrack = (SoundcloudTrack *) track;
        cell.textLabel.text = scTrack.trackName;
        cell.detailTextLabel.text = scTrack.artistName;
    }else{
        cell.textLabel.text = @"TBD";
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_savedPlaylistManager deleteTrackAtIndex:(int)indexPath.row];
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectedRow = indexPath.row;
    [_songManager setCurrentPlaylist:[_savedPlaylistManager savedPlaylist]];
    [_songManager startTimer];
    [_songManager playSongAtIndex:indexPath.row];
}

@end
