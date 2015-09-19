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

@interface SongManager : NSObject <AVAudioPlayerDelegate, SPTAudioStreamingPlaybackDelegate>

@property (strong, nonatomic) SpotifyPlayer *spotifyPlayer;
@property (strong, nonatomic) SoundcloudPlayer *soundcloudPlayer;
@property (strong, nonatomic) NSArray *currentPlaylist;

+ (SongManager *) getSharedInstance;
- (void) playSongAtIndex:(long)index;
- (BOOL) isPlaying;
- (void) playPause;
- (void) nextSong;
- (void) previousSong;
- (void) startTimer;

@end
