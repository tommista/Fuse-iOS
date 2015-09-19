//
//  SoundcloudTrack.m
//  Fuse
//
//  Created by Tommy Brown on 9/19/15.
//  Copyright (c) 2015 tjl. All rights reserved.
//

#import "SoundcloudTrack.h"

@implementation SoundcloudTrack

- (id) initWithJSON:(NSDictionary *)json{
    self = [super init];
    if(self){
        
        _trackId = [json objectForKey:@"id"];
        _trackName = [json objectForKey:@"title"];
        _artistName = [[json objectForKey:@"user"] objectForKey:@"username"];
        
        if([json objectForKey:@"artwork_url"] != [NSNull null]){
            _trackImageURL = [NSURL URLWithString:[json objectForKey:@"artwork_url"]];
        }
        
        if([json objectForKey:@"stream_url"] != [NSNull null]){
            _streamURL = [NSURL URLWithString:[json objectForKey:@"stream_url"]];
        }
        
    }
    return self;
}

- (NSString *) description{
    return [NSString stringWithFormat:@"%@ by %@", _trackName, _artistName];
}

@end
