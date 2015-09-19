//
//  SavedPlaylistManager.m
//  Fuse
//
//  Created by Tommy Brown on 9/19/15.
//  Copyright (c) 2015 tjl. All rights reserved.
//

#import "SavedPlaylistManager.h"
#import <Spotify/Spotify.h>
#import <AFNetworking/AFNetworking.h>
#import "SoundcloudTrack.h"
#import "Secrets.h"

#define SAVED_DATA_KEY @"saved_data_key"

@interface SavedPlaylistManager(){
    NSUserDefaults *defaults;
    int deserCount;
}
@end

@implementation SavedPlaylistManager

+ (SavedPlaylistManager *) getSharedInstance{
    static SavedPlaylistManager *instance;
    if(instance == nil){
        instance = [[SavedPlaylistManager alloc] init];
    }
    return instance;
}

- (id) init{
    self = [super init];
    if(self){
        defaults = [NSUserDefaults standardUserDefaults];
        _savedPlaylist = [[NSMutableArray alloc] init];
        //[defaults setObject:@"spotify:track:5PUawWFG1oIS2NwEcyHaCr@216760840" forKey:SAVED_DATA_KEY];
        [self deserialize];
    }
    return self;
}

- (void) serialize{
    NSString *str = [[NSString alloc] init];
    for(id anonTrack in _savedPlaylist){
        if([[anonTrack class] isSubclassOfClass:[SPTTrack class]]){ // spotify track
            str = [str stringByAppendingString: ((SPTTrack *)anonTrack).uri.absoluteString];
            str = [str stringByAppendingString:@"@"];
        }else{ // soundcloud track
            str = [str stringByAppendingString: ((SoundcloudTrack *)anonTrack).trackId];
            str = [str stringByAppendingString:@"@"];
        }
    }
    str = [str substringToIndex:str.length - 1];
    [defaults setObject:str forKey:SAVED_DATA_KEY];
    
    [defaults synchronize];
}

- (void) deserialize{
    NSString *rawData = [defaults objectForKey:SAVED_DATA_KEY];
    NSArray *partsArray = [rawData componentsSeparatedByString:@"@"];
    _savedPlaylist = [[NSMutableArray alloc] init];
    
    deserCount = (int)partsArray.count;
    for(int i = 0; i < partsArray.count; i++){
        [_savedPlaylist addObject:[[NSString alloc] init]];
        NSString *trackId = [partsArray objectAtIndex:i];
        if([trackId hasPrefix:@"spotify"]){ // is a spotify track
           [SPTTrack trackWithURI:[NSURL URLWithString:trackId] session:nil callback:^(NSError *error, SPTTrack *object) {
               [_savedPlaylist replaceObjectAtIndex:i withObject:object];
               [self decrementDescrCount];
            }];
        }else{ //  is a soundcloud track
            NSDictionary *parameters = @{@"client_id" : SOUNDCLOUD_CLIENT_ID};
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [manager GET:[NSString stringWithFormat:@"http://api.soundcloud.com/tracks/%@", trackId] parameters:parameters success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
                SoundcloudTrack *sctrack = [[SoundcloudTrack alloc] initWithJSON:responseObject];
                [_savedPlaylist replaceObjectAtIndex:i withObject:sctrack];
                [self decrementDescrCount];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
        }
    }
}

- (void) decrementDescrCount{
    deserCount--;
    if(deserCount == 0){
        NSLog(@"Finished deserializing");
        [[NSNotificationCenter defaultCenter] postNotificationName:DESERIALIZATION_FINISHED object:nil];
    }

}

- (void) deleteTrackAtIndex:(int) index{
    [_savedPlaylist removeObjectAtIndex:index];
    [self serialize];
}

@end
