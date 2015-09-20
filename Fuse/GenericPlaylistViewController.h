//
//  GenericPlaylistViewController.h
//  Fuse
//
//  Created by Tommy Brown on 9/19/15.
//  Copyright (c) 2015 tjl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SongManager.h"

@interface GenericPlaylistViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) SongManager *songManager;
@property (strong, nonatomic) NSMutableArray *playlist;

- (IBAction) backButtonPressed:(id)sender;
- (IBAction) playPauseButtonPressed:(id)sender;
- (IBAction) nextButtonPressed:(id)sender;

@end
