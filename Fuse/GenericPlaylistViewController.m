//
//  GenericPlaylistViewController.m
//  Fuse
//
//  Created by Tommy Brown on 9/19/15.
//  Copyright (c) 2015 tjl. All rights reserved.
//

#import "GenericPlaylistViewController.h"
#import "GenericTrack.h"

@interface GenericPlaylistViewController ()

@end

@implementation GenericPlaylistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _songManager = [SongManager getSharedInstance];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Actions

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
    
    GenericTrack *track = [_playlist objectAtIndex:indexPath.row];
    cell.textLabel.text = track.trackTitle;
    cell.detailTextLabel.text = track.artistTitle;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
