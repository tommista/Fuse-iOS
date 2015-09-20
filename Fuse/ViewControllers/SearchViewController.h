//
//  SearchViewController.h
//  Fuse
//
//  Created by Tommy Brown on 9/18/15.
//  Copyright (c) 2015 tjl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Spotify/Spotify.h>
#import "SpotifyPlayer.h"
#import "SongManager.h"

@interface SearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) SongManager *songManager;
@property (strong, nonatomic) SpotifyPlayer *spotifyPlayer;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *ppButton;

- (IBAction) backButtonPressed:(id)sender;
- (IBAction) playPauseButtonPressed:(id)sender;
- (IBAction) nextButtonPressed:(id)sender;


@end
