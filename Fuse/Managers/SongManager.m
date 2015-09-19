//
//  SongManager.m
//  Fuse
//
//  Created by Tommy Brown on 9/19/15.
//  Copyright (c) 2015 tjl. All rights reserved.
//

#import "SongManager.h"

#define NONE_PLAYING 0
#define SPOTIFY_PLAYING 1
#define SOUNDCLOUD_PLAYING 2

@interface SongManager(){
    long playingIndex;
    long playingSource;
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
        _soundcloudPlayer = [SoundcloudPlayer getSharedInstance];
        playingSource = NONE_PLAYING;
        playingIndex = 0;
    }
    return self;
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
        
    }else{
    }
}

- (void) previousSong{
}

@end
