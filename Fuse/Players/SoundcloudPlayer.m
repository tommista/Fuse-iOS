//
//  SoundcloudPlayer.m
//  Fuse
//
//  Created by Tommy Brown on 9/19/15.
//  Copyright (c) 2015 tjl. All rights reserved.
//

#import "SoundcloudPlayer.h"
#import "Secrets.h"

@implementation SoundcloudPlayer

+ (SoundcloudPlayer *) getSharedInstance{
    static SoundcloudPlayer *instance;
    if(instance == nil){
        instance = [[SoundcloudPlayer alloc] init];
    }
    return instance;
}

- (id) init{
    self = [super init];
    if(self){
        
    }
    return self;
}

- (void) playSong:(NSString *)songId{
    NSURL *trackURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.soundcloud.com/tracks/%@/stream?client_id=%@", songId, SOUNDCLOUD_CLIENT_ID]];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:trackURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        _player = [[AVAudioPlayer alloc] initWithData:data error:nil]; // TODO fix this
        _player.delegate = _playbackDelegate;
        [_player play];
    }];
    
    [task resume];
}

- (void) playTrack{
    [_player prepareToPlay];
    [_player play];
}

- (void) pauseTrack{
    [_player pause];
}

@end
