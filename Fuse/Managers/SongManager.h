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

#define SONG_INDEX_NOTIFICATION @"song_index_notif"

@interface SongManager : NSObject <AVAudioPlayerDelegate, SPTAudioStreamingPlaybackDelegate>

@property (strong, nonatomic) SpotifyPlayer *spotifyPlayer;
@property (strong, nonatomic) SoundcloudPlayer *soundcloudPlayer;
@property (strong, nonatomic) NSArray *currentPlaylist;
@property (strong, nonatomic) NSString *playlistId;

+ (SongManager *) getSharedInstance;
- (void) playSongAtIndex:(long)index;
- (BOOL) isPlaying;
- (void) playPause;
- (void) nextSong;
- (void) previousSong;
- (void) startTimer;
- (unsigned long) getPlayingIndex;

@end
