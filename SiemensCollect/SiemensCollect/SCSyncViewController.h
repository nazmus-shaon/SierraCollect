//
//  SCSyncViewController.h
//  SiemensCollect
//
//  Created by Andreas Seitz on 01.07.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "SCAbstractViewController.h"
#import <GameKit/GameKit.h>

@protocol SCSyncViewControllerDelegate <NSObject>

- (void)removeModalController;

@end

@interface SCSyncViewController : SCAbstractViewController <GKSessionDelegate, GKPeerPickerControllerDelegate, UITableViewDataSource, UITableViewDelegate> {
    GKPeerPickerController *pickerCont;
    NSMutableArray *availablePeers;
    
    NSMutableArray *availableDBs;
    
    int selectedIndex;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (nonatomic, strong) GKSession *session;

@property (nonatomic, weak) NSObject <SCSyncViewControllerDelegate> *delegate;
@property (weak, nonatomic) IBOutlet UIButton *connectDeviceBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendDataBtn;


- (IBAction)connectDevice:(id)sender;
- (IBAction)sendData:(id)sender;

- (IBAction)closeOverlay:(id)sender;

@end
