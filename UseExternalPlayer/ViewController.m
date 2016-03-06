//
//  ViewController.m
//  UseExternalPlayer
//
//  Created by Catherine Zhao on 2016-03-04.
//  Copyright © 2016 Catherine. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

NSDictionary *playerVars;
NSMutableDictionary *videoIds;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.restClient.delegate = self;

//    playerVars = @{@"playsinline" : @1,};
    videoIds = [[NSMutableDictionary alloc] initWithDictionary:@{@"一次就好":@"7dgyfnX-nmE",@"空白格":@"GrzzfZ1qaI0",@"最爱":@"OT0wn1mHbOY",@"流浪记":@"miTB7LO2OF8",@"匆匆那年":@"jAoNQ5g3PBI",@"大海":@"UBjLqzy0yI8"}];
//    self.mainTableView.delegate = self;
//    self.mainTableView.dataSource = self;
//    self.playerView.delegate = self;
//    [self.playerView loadWithVideoId:@"GrzzfZ1qaI0" playerVars:playerVars];
    //[self.playerView loadWithVideoId:@"7dgyfnX-nmE"];
    //[self.playerView loadVideoById:@"M7lc1UVf-VE" startSeconds:0.0f endSeconds:60.0f suggestedQuality:kYTPlaybackQualityAuto];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
}

-(void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    NSLog(@"Failure");
}

-(void)restClient:(DBRestClient *)client loadedFile:(NSString *)destPath contentType:(NSString *)contentType metadata:(DBMetadata *)metadata {
    NSLog(@"File loaded into path: %@", destPath);
    videoIds = [[NSMutableDictionary alloc] initWithContentsOfFile:destPath];
}

-(void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error {
    NSLog(@"There was an error loading the file: %@", error);
}

- (IBAction)dropBoxLinking:(id)sender {
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
    }
}

- (IBAction)checkFile:(id)sender {
    [self.restClient loadMetadata:@"/"];
}

-(void)writeToFile {
    [videoIds setObject:@"UBjLqzy0yI8" forKey:@"刘惜君-大海"];
    NSURL *documentsURL = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    NSURL *fileURL = [documentsURL URLByAppendingPathComponent:@"askaList.plist"];
    [videoIds writeToFile:fileURL.path atomically:false];
}
- (IBAction)downloadFile:(id)sender {
    NSURL *documentsURL = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    NSURL *fileURL = [documentsURL URLByAppendingPathComponent:@"askaList.plist"];
    [self.restClient loadFile:@"/aska" intoPath:fileURL.path];
    
    videoIds = [[NSMutableDictionary alloc] initWithContentsOfFile:fileURL.path];
}
- (IBAction)uploadFile:(id)sender {
    NSURL *documentsURL = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    NSURL *fileURL = [documentsURL URLByAppendingPathComponent:@"askaList.plist"];
    NSFileManager *fileManage = [NSFileManager defaultManager];
    if(![fileManage fileExistsAtPath:fileURL.path]){
        if ([[NSBundle mainBundle] pathForResource:@"askaList" ofType:@"plist"]){
            NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"askaList" ofType:@"plist"];
            [fileManage copyItemAtPath:bundlePath toPath:fileURL.path error:NULL];
        }
    }
    [self writeToFile];
    [self.restClient loadMetadata:@"/"];
    //[self.restClient uploadFile:@"aska" toPath:@"/" withParentRev:@"3229f8253f" fromPath:fileURL.path];
}

-(void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    NSURL *documentsURL = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    NSURL *fileURL = [documentsURL URLByAppendingPathComponent:@"askaList.plist"];
    if (metadata.isDirectory) {
        NSLog(@"Folder '%@' contains:", metadata.path);
        for (DBMetadata *file in metadata.contents) {
            NSLog(@"	%@", file.filename);
            if([file.filename isEqualToString:@"aska"]){
                [self.restClient uploadFile:@"aska" toPath:@"/" withParentRev:file.rev fromPath:fileURL.path];
                return;
            }
        }
        [self.restClient uploadFile:@"aska" toPath:@"/" withParentRev:nil fromPath:fileURL.path];
    }
}

- (void)restClient:(DBRestClient *)client
loadMetadataFailedWithError:(NSError *)error {
    NSLog(@"Error loading metadata: %@", error);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [videoIds.allKeys count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"videoCell"];
    cell.textLabel.text = [videoIds.allKeys objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.playerView stopVideo];
    [self.playerView loadWithVideoId:[videoIds.allValues objectAtIndex:indexPath.row] playerVars:playerVars];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
