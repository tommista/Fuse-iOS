//
//  SoundcloudTrack.h
//  Fuse
//
//  Created by Tommy Brown on 9/19/15.
//  Copyright (c) 2015 tjl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SoundcloudTrack : NSObject

@property (strong, nonatomic) NSString *trackId;
@property (strong, nonatomic) NSString *trackName;
@property (strong, nonatomic) NSString *artistName;
@property (strong, nonatomic) NSURL *trackImageURL;
@property (strong, nonatomic) NSURL *streamURL;

- (id) initWithJSON:(NSDictionary *)json;

@end
