//
//  DiscoveryViewController.m
//  Fuse
//
//  Created by Tommy Brown on 9/19/15.
//  Copyright (c) 2015 tjl. All rights reserved.
//

#import "DiscoveryViewController.h"
#import <MMDrawerController/MMDrawerBarButtonItem.h>
#import "AppDelegate.h"
#import "GenericTrack.h"
#import <AFNetworking/AFNetworking.h>
#import "GenericPlaylistViewController.h"
#import <Parse/Parse.h>
#import "Secrets.h"
#import "SoundcloudTrack.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define AROUND_ME 0
#define HYPE_MACHINE 1

@interface DiscoveryViewController (){
    unsigned long descrCount;
    NSMutableArray *tempArray;
    NSTimer *ppTimer;
}
@end

@implementation DiscoveryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _songManager = [SongManager getSharedInstance];
    
    self.navigationItem.title = @"Discovery";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    self.navigationItem.leftBarButtonItem = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(menuButtonPressed:)];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    ppTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(ppTimerFired) userInfo:nil repeats:YES];
}

- (void) viewWillDisappear:(BOOL)animated{
    [ppTimer invalidate];
    ppTimer = nil;
    [super viewWillDisappear:animated];
}

#pragma mark - Timer

- (void) ppTimerFired{
    if(_songManager.isPlaying){
        _ppButton.image = [UIImage imageNamed:@"pause.png"];
    }else{
        _ppButton.image = [UIImage imageNamed:@"play2.png"];
    }
}

#pragma mark - Actions

- (IBAction) menuButtonPressed:(id)sender{
    if([((AppDelegate *)[[UIApplication sharedApplication] delegate]).drawerController openSide] == MMDrawerSideNone){
        [((AppDelegate *)[[UIApplication sharedApplication] delegate]).drawerController openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    }
    else{
        [((AppDelegate *)[[UIApplication sharedApplication] delegate]).drawerController closeDrawerAnimated:YES completion:nil];
    }
}

- (IBAction) backButtonPressed:(id)sender{
    [_songManager previousSong];
}

- (IBAction) playPauseButtonPressed:(id)sender{
    [_songManager playPause];
}

- (IBAction) nextButtonPressed:(id)sender{
    [_songManager nextSong];
}

#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *discoveryCellIdentifier = @"Discovery_identifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:discoveryCellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:discoveryCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    switch(indexPath.row){
        case AROUND_ME:{
            cell.textLabel.text = @"Around Me";
            cell.imageView.image = [UIImage imageNamed:@"icn_location_dark"];
        }break;
        case HYPE_MACHINE:
            cell.textLabel.text = @"Hype Machine: Featured";
            cell.imageView.image = [UIImage imageNamed:@"hype.png"];
            break;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch(indexPath.row){
        case AROUND_ME:{
            PFQuery *query = [PFQuery queryWithClassName:@"Track"];
            tempArray = [[NSMutableArray alloc] init];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    descrCount = objects.count;
                    for(int i = 0; i < objects.count; i++){
                        [tempArray addObject:[[NSString alloc] init]];
                        NSString *trackId = [[objects objectAtIndex:i] objectForKey:@"trackId"];
                        if([trackId hasPrefix:@"spotify"]){ // is a spotify track
                            [SPTTrack trackWithURI:[NSURL URLWithString:trackId] session:nil callback:^(NSError *error, SPTTrack *object) {
                                [tempArray replaceObjectAtIndex:i withObject:object];
                                [self decrementDescrCount];
                            }];
                        }else{ //  is a soundcloud track
                            NSDictionary *parameters = @{@"client_id" : SOUNDCLOUD_CLIENT_ID};
                            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                            [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                            [manager GET:[NSString stringWithFormat:@"http://api.soundcloud.com/tracks/%@", trackId] parameters:parameters success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
                                SoundcloudTrack *sctrack = [[SoundcloudTrack alloc] initWithJSON:responseObject];
                                [tempArray replaceObjectAtIndex:i withObject:sctrack];
                                [self decrementDescrCount];
                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"Error: %@", error);
                            }];
                        }
                    }
                } else {
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }break;
        case HYPE_MACHINE:{
            NSDictionary *parameters = @{@"type" : @"premieres", @"key" : @"swagger"};
            AFHTTPRequestOperationManager *afManager = [AFHTTPRequestOperationManager manager];
            [afManager GET:@"https://api.hypem.com/v2/featured" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSArray *jsonData = responseObject;
                NSMutableArray *tracks = [[NSMutableArray alloc] init];
                for(NSDictionary *json in jsonData){
                    [tracks addObject:[[GenericTrack alloc] initWithHypemJSON:json]];
                    NSLog(@"%@", ((GenericTrack *)[tracks lastObject]).trackTitle);
                }
                
                GenericPlaylistViewController *vc = [[GenericPlaylistViewController alloc] initWithNibName:@"GenericPlaylistViewController" bundle:nil];
                vc.playlist = tracks;
                vc.playlistName = @"Featured";
                [self.navigationController pushViewController:vc animated:YES];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
        }break;
    }
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    [self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark - boring crap

- (void) decrementDescrCount{
    descrCount--;
    if(descrCount == 0){
        GenericPlaylistViewController *vc = [[GenericPlaylistViewController alloc] init];
        vc.playlistName = @"Around Me";
        vc.playlist = tempArray;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

@end
