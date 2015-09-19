//
//  SongManager.m
//  Fuse
//
//  Created by Tommy Brown on 9/19/15.
//  Copyright (c) 2015 tjl. All rights reserved.
//

#import "SongManager.h"
#import "SoundcloudTrack.h"

#define NONE_PLAYING 0
#define SPOTIFY_PLAYING 1
#define SOUNDCLOUD_PLAYING 2

@interface SongManager(){
    long playingIndex;
    long playingSource;
    BOOL isPlaying;
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

- (void) setCurrentPlaylist:(NSArray *)currentPlaylist{
    _currentPlaylist = currentPlaylist;
}

- (void) playSongAtIndex:(long)index{
    playingIndex = index;
    
    [self pause];
    
    isPlaying = YES;
    
    id track = [_currentPlaylist objectAtIndex:playingIndex];
    if([[track class] isSubclassOfClass:[SPTPartialTrack class]]){// spotify track
        SPTPartialTrack *spTrack = (SPTPartialTrack *) track;
        playingSource = SPOTIFY_PLAYING;
        [_spotifyPlayer playSong:spTrack.uri];
    }else if ([[track class] isSubclassOfClass:[SoundcloudTrack class]]){// soundcloud track
        SoundcloudTrack *scTrack = (SoundcloudTrack *) track;
        playingSource = SOUNDCLOUD_PLAYING;
        [_soundcloudPlayer playSong:scTrack.trackId];
    }
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
        [self playSongAtIndex:(playingIndex + 1)];
    }
}

- (void) previousSong{
    if(playingIndex == 0){
        [self playSongAtIndex:0];
    }else{
        [self playSongAtIndex:(playingIndex - 1)];
    }
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
    
    SPTPartialTrack *track = [_currentPlaylist objectAtIndex:playingIndex];
    if([track.uri.absoluteString isEqualToString:trackUri.absoluteString]){ // The song just ended
        NSLog(@"### spotify song finished");
        [_spotifyPlayer.player stop:^(NSError *error) {
            NSLog(@"Spotify stop error: %@", error);
        }];
        _spotifyPlayer.player = nil;
        [self nextSong];
    }else { // the song was skipped
        
    }
}

@end
