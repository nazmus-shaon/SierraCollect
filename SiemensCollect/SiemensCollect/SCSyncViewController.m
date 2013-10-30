//
//  SCSyncViewController.m
//  SiemensCollect
//
//  Created by Andreas Seitz on 01.07.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "SCSyncViewController.h"
#import "SCAppDelegate.h"

@interface SCSyncViewController ()

@end

@implementation SCSyncViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    pickerCont = [[GKPeerPickerController alloc] init];
    [pickerCont setDelegate:self];
    
    [pickerCont setConnectionTypesMask:GKPeerPickerConnectionTypeNearby];
    
    availablePeers = [NSMutableArray array];
    [self.sendDataBtn setEnabled:NO];
    
    [self fetchDBs];
}

- (void)fetchDBs {
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDir error:nil];

    availableDBs = [NSMutableArray array];
    
    NSError *error;
    for (NSString *str in [dirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.sqlite'"]]) {
        
        NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        
        NSLog(@"applicationDocumentsDirectory: %@", applicationDocumentsDirectory);
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd_hh-mm-ss"];
        
        NSURL *storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:str];
        
        
        NSDate *fileDate;
        [storeURL getResourceValue:&fileDate forKey:NSURLContentModificationDateKey error:&error];
        if (!error) {
            NSLog(@"file date: %@", fileDate);
            NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:str, [formatter stringFromDate:fileDate], nil] forKeys:[NSArray arrayWithObjects:@"name", @"date", nil]];
            [availableDBs addObject:dict];
        }
    }
    NSLog(@"available DBs: %@", availableDBs);
}

- (void)refreshView {
    [self fetchDBs];
    [self.tableView reloadData];
}

- (BOOL)checkSelectedPersistentStore:(NSString*)_name {
    NSURL *url = [(SCAppDelegate*)[[UIApplication sharedApplication] delegate] currentPersistentStore];
    if ([_name isEqualToString:[url lastPathComponent]]) {
        return YES;
    } else {
        return NO;
    }
}

- (IBAction)sendData:(id)sender {
    NSLog(@"Send File");
    
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"SierraDB.sqlite"];
    
    NSLog(@"storepath: %@", storePath);
    
    NSData *data = [NSData dataWithContentsOfFile:storePath];
    
    
    NSError *error;
    [self.session sendData:data toPeers:availablePeers withDataMode:GKSendDataReliable error:&error];
    
    if (error) {
        NSLog(@"error: %@", error.description);
    }
    
}

- (IBAction)closeOverlay:(id)sender {
    [self.delegate removeModalController];
}

- (IBAction)connectDevice:(id)sender {
    [pickerCont show];
}

#pragma mark -
#pragma mark GKPeerPickerControllerDelegate

- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type {
    if(self.session == nil){
        self.session = [[GKSession alloc] initWithSessionID:@"in.tum.de" displayName:@"Sierra Collect" sessionMode:GKSessionModePeer];
        self.session.delegate = self;
    }
    return self.session;
}


- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session{
	
	// Get the session and assign it locally
    self.session = session;
    session.delegate = self;
    
    //No need of teh picekr anymore
	picker.delegate = nil;
    [picker dismiss];
}

// Function to receive data when sent from peer
- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
    
    //write data to documents
	NSLog(@"received data");
    NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
 
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd_hh-mm-ss"];

    NSURL *storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@_db.sqlite", [formatter stringFromDate:[NSDate date]]]];
    
    [data writeToURL:storeURL atomically:YES];
    
    NSLog(@"This is store URL %@ ", storeURL.absoluteString);
    //----
    
    
    //--- activate that db
    [(SCAppDelegate*)[[UIApplication sharedApplication] delegate] replaceDB:storeURL];
    //---
    
    
    [self refreshView];
}

#pragma mark -
#pragma mark GKSessionDelegate

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state{
    
	if(state == GKPeerStateConnected){
		// Add the peer to the Array
		[availablePeers addObject:peerID];
        
		NSString *str = [NSString stringWithFormat:@"Connected with %@",[session displayNameForPeer:peerID]];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connected" message:str delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		
		// Used to acknowledge that we will be sending data
		[session setDataReceiveHandler:self withContext:nil];
        [self.sendDataBtn setEnabled:YES];
		
	}
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
    NSLog(@"error connect with peer failed");
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
    NSLog(@"session did fail with error");
}

#pragma mark UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [availableDBs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if ([self checkSelectedPersistentStore:[[availableDBs objectAtIndex:indexPath.row] objectForKey:@"name"]]) {
       cell.accessoryType = UITableViewCellAccessoryCheckmark; 
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
//    if (indexPath.row == selectedIndex) {
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//    } else {
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [[availableDBs objectAtIndex:indexPath.row] objectForKey:@"name"]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [[availableDBs objectAtIndex:indexPath.row] objectForKey:@"date"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if ([[tableView cellForRowAtIndexPath:indexPath] accessoryType] == UITableViewCellAccessoryCheckmark) {
        return;
    }
    
    [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    selectedIndex = indexPath.row;
    //--- activate that db
    NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:[[availableDBs objectAtIndex:indexPath.row] objectForKey:@"name"]];
    [(SCAppDelegate*)[[UIApplication sharedApplication] delegate] replaceDB:storeURL];
    //--
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    NSURL *storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:[[availableDBs objectAtIndex:indexPath.row] objectForKey:@"name"]];
     NSLog(@"sotre url to delete: %@", storeURL);
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSError *error;
        NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        
        NSURL *storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:[[availableDBs objectAtIndex:indexPath.row] objectForKey:@"name"]];
        
        NSLog(@"sotre url to delete: %@", storeURL);
        
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
        if (error) {
            NSLog(@"could not delete: %@", error.localizedDescription);
        }
        [self refreshView];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[tableView cellForRowAtIndexPath:indexPath] accessoryType] == UITableViewCellAccessoryCheckmark) {
        return NO;
    } else {
        return YES;
    }
}


@end