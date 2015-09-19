//
//  SpotifyPlayer.h
//  Fuse
//
//  Created by Tommy Brown on 9/18/15.
//  Copyright (c) 2015 tjl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Spotify/Spotify.h>

@interface SpotifyPlayer : NSObject

@property (nonatomic, strong) SPTSession *session;
@property (nonatomic, strong) SPTAudioStreamingController *player;

+ (SpotifyPlayer *) getSharedPlayer;

- (void) playSong:(NSURL *) songURL;
- (void) pauseTrack;
- (void) playTrack;

@end
