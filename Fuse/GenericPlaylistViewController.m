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

@interface GenericPlaylistViewController ()

@end

@implementation GenericPlaylistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _songManager = [SongManager getSharedInstance];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
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
    }
    
    id genTrack = [_playlist objectAtIndex:indexPath.row];
    
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
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_songManager setCurrentPlaylist:_playlist];
    [_songManager startTimer];
    [_songManager playSongAtIndex:indexPath.row];
}

@end
