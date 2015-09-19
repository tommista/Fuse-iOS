//
//  DrawerViewController.h
//  Fuse
//
//  Created by Tommy Brown on 9/18/15.
//  Copyright (c) 2015 tjl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end
