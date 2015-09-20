//
//  GenericTrack.m
//  Fuse
//
//  Created by Tommy Brown on 9/19/15.
//  Copyright (c) 2015 tjl. All rights reserved.
//

#import "GenericTrack.h"

@implementation GenericTrack

- (id) initWithHypemJSON:(NSDictionary *)json{
    self = [super init];
    if(self){
        _artistTitle = [json objectForKey:@"artist"];
        
        NSArray *tracks = [json objectForKey:@"tracks"];
        if(tracks != nil && tracks.count > 0){
            NSDictionary *track = [tracks firstObject];
            _trackTitle = [track objectForKey:@"title"];
            _trackId = [track objectForKey:@"sc_id"];
            _trackURL = [NSURL URLWithString:[track objectForKey:@"stream_url"]];
        }
        
    }
    return self;
}

@end
