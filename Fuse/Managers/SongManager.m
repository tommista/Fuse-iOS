//
//  SongManager.m
//  Fuse
//
//  Created by Tommy Brown on 9/19/15.
//  Copyright (c) 2015 tjl. All rights reserved.
//

#import "SongManager.h"
#import "SoundcloudTrack.h"
#import "GenericTrack.h"
#import <Parse/Parse.h>

#define NONE_PLAYING 0
#define SPOTIFY_PLAYING 1
#define SOUNDCLOUD_PLAYING 2

@interface SongManager(){
    long playingIndex;
    long playingSource;
    BOOL isPlaying;
    NSTimer *spotTimer;
}
@end

@implementation SongManager

+ (SongManager *) getSharedInstance{
    static SongManager *instance;
    if(instance == nil){
        instance = [[SongManager alloc] init];
    }
    return instance;
}

- (id) init{
    self = [super init];
    if(self){
        _spotifyPlayer = [SpotifyPlayer getSharedPlayer];
        _spotifyPlayer.playbackDelegate = self;
        _soundcloudPlayer = [SoundcloudPlayer getSharedInstance];
        _soundcloudPlayer.playbackDelegate = self;
        playingSource = NONE_PLAYING;
        playingIndex = 0;
        isPlaying = NO;
    }
    return self;
}

- (void) sentIDToParse:(NSString *)trackId{
    NSLog(@"ID: %@", trackId);
    PFObject *trackObj = [PFObject objectWithClassName:@"Track"];
    trackObj[@"trackId"] = trackId;
    [trackObj saveInBackground];
}

- (void) setCurrentPlaylist:(NSArray *)currentPlaylist{
    _currentPlaylist = currentPlaylist;
}

- (void) playSongAtIndex:(long)index{
    playingIndex = index;
    
    [self pause];
    
    NSString *uuid = @"";
    
    isPlaying = YES;
    
    id track = [_currentPlaylist objectAtIndex:playingIndex];
    if([[track class] isSubclassOfClass:[SPTPartialTrack class]]){// spotify track
        SPTPartialTrack *spTrack = (SPTPartialTrack *) track;
        playingSource = SPOTIFY_PLAYING;
        [self sentIDToParse:spTrack.uri.absoluteString];
        uuid = spTrack.uri.absoluteString;
        [_spotifyPlayer playSong:spTrack.uri];
    }else if ([[track class] isSubclassOfClass:[SoundcloudTrack class]]){// soundcloud track
        SoundcloudTrack *scTrack = (SoundcloudTrack *) track;
        playingSource = SOUNDCLOUD_PLAYING;
        [self sentIDToParse:scTrack.trackId];
        uuid = scTrack.trackId;
        [_soundcloudPlayer playSong:scTrack.trackId];
    }else{ // Generic track
        GenericTrack *gTrack = (GenericTrack *) track;
        playingSource = SOUNDCLOUD_PLAYING;
        
        NSArray *parts = [gTrack.trackURL.absoluteString componentsSeparatedByString:@"/"];
        [self sentIDToParse:[parts objectAtIndex:4]];
        
        uuid = [parts objectAtIndex:4];
        [_soundcloudPlayer playSong:[parts objectAtIndex:4]];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SONG_INDEX_NOTIFICATION object:nil userInfo:@{@"index" : [NSNumber numberWithLong:playingIndex], @"id" : uuid}];
}

- (void) playPause{
    if(isPlaying){ // is currently playing, going to pause
        isPlaying = NO;
        [self pause];
    }else{ //  is currentply paused, going to start
        isPlaying = YES;
        [self play];
    }
}

- (BOOL) isPlaying{
    return isPlaying;
}

- (unsigned long) getPlayingIndex{
    return playingIndex;
}

- (void) play{
    switch(playingSource){
        case NONE_PLAYING:
            break;
        case SPOTIFY_PLAYING:
            [_spotifyPlayer playTrack];
            break;
        case SOUNDCLOUD_PLAYING:
            [_soundcloudPlayer playTrack];
            break;
    }
}

- (void) pause{
    switch(playingSource){
        case NONE_PLAYING:
            break;
        case SPOTIFY_PLAYING:
            [_spotifyPlayer pauseTrack];
            break;
        case SOUNDCLOUD_PLAYING:
            [_soundcloudPlayer pauseTrack];
            break;
    }
}

- (void) nextSong{
    if(playingIndex + 1 == _currentPlaylist.count){ // At the end
        [self pause];
    }else{
        spotTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerFired) userInfo:nil repeats:NO];
        [self playSongAtIndex:(playingIndex + 1)];
    }
}

- (void) previousSong{
    if(playingIndex == 0){
        [self playSongAtIndex:0];
    }else{
        spotTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerFired) userInfo:nil repeats:NO];
        [self playSongAtIndex:(playingIndex - 1)];
    }
}

- (void) startTimer{
    spotTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerFired) userInfo:nil repeats:NO];
}

#pragma mark - AVAudioPlayerDelegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"#### Song finished");
    [_soundcloudPlayer.player stop];
    _soundcloudPlayer.player = nil;
    [self nextSong];
}

#pragma mark - SPTAudioStreamingPlaybackDelegate

- (void) audioStreaming:(SPTAudioStreamingController *)audioStreaming didStopPlayingTrack:(NSURL *)trackUri{
    if(spotTimer != nil && spotTimer.isValid){ // some stuff happened
    }else{// track ended
        [self nextSong];
    }
}

/*- (void) audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangePlaybackStatus:(BOOL)isPlaying{
    NSLog(@"status: %d", isPlaying);
    NSLog(@"### spotify song finished");
    [_spotifyPlayer.player stop:^(NSError *error) {
        NSLog(@"Spotify stop error: %@", error);
    }];
    _spotifyPlayer.player = nil;
    [self nextSong];
}*/

#pragma mark - Timer Actions

- (void) timerFired{
    [spotTimer invalidate];
    spotTimer = nil;
}

@end
