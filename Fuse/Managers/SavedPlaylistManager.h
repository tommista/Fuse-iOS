//
//  SavedPlaylistManager.h
//  Fuse
//
//  Created by Tommy Brown on 9/19/15.
//  Copyright (c) 2015 tjl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Spotify/Spotify.h>
#import <AFNetworking/AFNetworking.h>
#import "SoundcloudTrack.h"

#define DESERIALIZATION_FINISHED @"Deserialization_finished"

@interface SavedPlaylistManager : NSObject

@property (strong, nonatomic) NSMutableArray *savedPlaylist;

+ (SavedPlaylistManager *) getSharedInstance;

- (void) deleteTrackAtIndex:(int) index;
- (void) addSpotifyTrack:(SPTPartialTrack *)track;
- (void) addSoundcloudTrack:(SoundcloudTrack *)track;

@end
