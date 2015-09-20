//
//  GenericTrack.h
//  Fuse
//
//  Created by Tommy Brown on 9/19/15.
//  Copyright (c) 2015 tjl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GenericTrack : NSObject

@property (strong, nonatomic) NSString *trackTitle;
@property (strong, nonatomic) NSString *artistTitle;
@property (strong, nonatomic) NSString *trackId;
@property (strong, nonatomic) NSURL *trackURL;

- (id) initWithHypemJSON:(NSDictionary *)json;

@end
