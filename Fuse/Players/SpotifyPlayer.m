//
//  SpotifyPlayer.m
//  Fuse
//
//  Created by Tommy Brown on 9/18/15.
//  Copyright (c) 2015 tjl. All rights reserved.
//

#import "SpotifyPlayer.h"

@implementation SpotifyPlayer

+ (SpotifyPlayer *) getSharedPlayer{
    static SpotifyPlayer *instance;
    if(instance == nil){
        instance = [[SpotifyPlayer alloc] init];
    }
    return instance;
}

- (id) init{
    self = [super init];
    if(self){
        
    }
    return self;
}

- (void) setSession:(SPTSession *)session{
    _session = session;
    
    if (self.player == nil) {
        self.player = [[SPTAudioStreamingController alloc] initWithClientId:[SPTAuth defaultInstance].clientID];
    }
    
    [self.player loginWithSession:session callback:^(NSError *error) {
        if (error != nil) {
            NSLog(@"*** Logging in got error: %@", error);
            return;
        }
        
        NSURL *trackURI = [NSURL URLWithString:@"spotify:track:58s6EuEYJdlb0kO7awm3Vp"];
        [self playSong:trackURI];
    }];
}

- (void) playSong:(NSURL *)songURL{
    [self.player playURIs:@[ songURL ] fromIndex:0 callback:^(NSError *error) {
        if (error != nil) {
            NSLog(@"*** Starting playback got error: %@", error);
            return;
        }
    }];
}

- (void) playTrack{
    [_player setIsPlaying:YES callback:^(NSError *error) {
        NSLog(@"Error starting track: %@", error);
    }];
}

- (void) pauseTrack{
    [_player setIsPlaying:NO callback:^(NSError *error) {
        NSLog(@"Error pausing track: %@", error);
    }];
}

@end
