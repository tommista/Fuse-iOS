//
//  SongManager.h
//  Fuse
//
//  Created by Tommy Brown on 9/19/15.
//  Copyright (c) 2015 tjl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpotifyPlayer.h"
#import "SoundcloudPlayer.h"

@interface SongManager : NSObject

@property (strong, nonatomic) SpotifyPlayer *spotifyPlayer;
@property (strong, nonatomic) SoundcloudPlayer *soundcloudPlayer;
@property (strong, nonatomic) NSArray *currentPlaylist;

+ (SongManager *) getSharedInstance;
- (void) play;
- (void) pause;
- (void) nextSong;
- (void) previousSong;

@end
