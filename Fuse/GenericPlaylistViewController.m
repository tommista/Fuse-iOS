//
//  GenericPlaylistViewController.m
//  Fuse
//
//  Created by Tommy Brown on 9/19/15.
//  Copyright (c) 2015 tjl. All rights reserved.
//

#import "GenericPlaylistViewController.h"
#import "GenericTrack.h"
#import "SoundcloudTrack.h"
#import "SavedPlaylistManager.h"

@interface GenericPlaylistViewController (){
    NSTimer *ppTimer;
    SavedPlaylistManager *savedPlaylistManager;
    unsigned long selectedRow;
}
@end

@implementation GenericPlaylistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _songManager = [SongManager getSharedInstance];
    savedPlaylistManager = [SavedPlaylistManager getSharedInstance];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    ppTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(ppTimerFired) userInfo:nil repeats:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newSong:) name:SONG_INDEX_NOTIFICATION object:nil];
}

- (void) viewWillDisappear:(BOOL)animated{
    [ppTimer invalidate];
    ppTimer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SONG_INDEX_NOTIFICATION object:nil];
    [super viewWillDisappear:animated];
}

#pragma mark - Notifications

- (void) newSong:(NSNotification *)notif{
    NSString *uuid = [notif.userInfo objectForKey:@"id"];
    for(int i = 0; i < _playlist.count; i++){
        id track = [_playlist objectAtIndex:i];
        NSString *trackId = @"";;
        if([[track class] isSubclassOfClass:[SPTPartialTrack class]]){// spotify track
            SPTPartialTrack *spTrack = (SPTPartialTrack *) track;
            trackId = spTrack.uri.absoluteString;
        }else if ([[track class] isSubclassOfClass:[SoundcloudTrack class]]){// soundcloud track
            SoundcloudTrack *scTrack = (SoundcloudTrack *) track;
            trackId = scTrack.trackId;
        }else if([[track class] isSubclassOfClass:[GenericTrack class]]){
          GenericTrack *gTrack = (GenericTrack *) track;
          NSArray *parts = [gTrack.trackURL.absoluteString componentsSeparatedByString:@"/"];
          trackId = [parts objectAtIndex:4];
          }
        
        if([trackId isEqualToString:uuid] && i != selectedRow){
            [_tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:0] animated:YES];
            [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
            selectedRow = i;
            return;
        }
    }
}

#pragma mark - Timer

- (void) ppTimerFired{
    if(_songManager.isPlaying){
        _ppButton.image = [UIImage imageNamed:@"pause.png"];
    }else{
        _ppButton.image = [UIImage imageNamed:@"play2.png"];
    }
}

- (void) setPlaylist:(NSMutableArray *)playlist{
    _playlist = playlist;
    [_tableView reloadData];
}

- (void) setPlaylistName:(NSString *)playlistName{
    _playlistName = playlistName;
    self.navigationItem.title = _playlistName;
}

#pragma mark - Actions

- (IBAction) backMenuButtonPressed:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) accessoryButtonPressed:(UIButton *)sender{
    NSObject *genericTrack = [_playlist objectAtIndex:sender.tag];
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
    return _playlist.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *genericCellIdentifier = @"generic_cell_stuff";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:genericCellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:genericCellIdentifier];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
    }
    
    id genTrack = [_playlist objectAtIndex:indexPath.row];
    
    UIButton *button = [[UIButton alloc] init];
    [button setImage:[UIImage imageNamed:@"IcnPlus"] forState:UIControlStateNormal];
    button.tag = indexPath.row;
    [button addTarget:self action:@selector(accessoryButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = button;
    [cell.accessoryView setFrame:CGRectMake(0, 0, 24, 24)];
    
    if([[genTrack class] isSubclassOfClass:[SPTPartialTrack class]]){
        SPTPartialTrack *track = (SPTPartialTrack *)genTrack;
        cell.textLabel.text = track.name;
        cell.detailTextLabel.text = [track.artists[0] name];
    }else if([[genTrack class] isSubclassOfClass:[SoundcloudTrack class]]){
        SoundcloudTrack *track = (SoundcloudTrack *) genTrack;
        cell.textLabel.text = track.trackName;
        cell.detailTextLabel.text = track.artistName;
    }else{
        GenericTrack *track = (GenericTrack *) genTrack;
        cell.textLabel.text = track.trackTitle;
        cell.detailTextLabel.text = track.artistTitle;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectedRow = indexPath.row;
    [_songManager setCurrentPlaylist:_playlist];
    [_songManager startTimer];
    [_songManager playSongAtIndex:indexPath.row];
}

@end
