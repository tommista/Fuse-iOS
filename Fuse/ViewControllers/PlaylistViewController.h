//
//  PlaylistViewController.h
//  Fuse
//
//  Created by Tommy Brown on 9/18/15.
//  Copyright (c) 2015 tjl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpotifyPlayer.h"
#import "SoundcloudPlayer.h"
#import "SongManager.h"
#import "SavedPlaylistManager.h"

@interface PlaylistViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) SavedPlaylistManager *savedPlaylistManager;
@property (strong, nonatomic) SongManager *songManager;

@end
