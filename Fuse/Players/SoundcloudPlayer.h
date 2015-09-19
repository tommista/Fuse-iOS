//
//  SoundcloudPlayer.h
//  Fuse
//
//  Created by Tommy Brown on 9/19/15.
//  Copyright (c) 2015 tjl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface SoundcloudPlayer : NSObject

@property (strong, nonatomic) AVAudioPlayer *player;

+ (SoundcloudPlayer *) getSharedInstance;

- (void) playSong:(NSString *) songId;
- (void) playTrack;
- (void) pauseTrack;

@end
