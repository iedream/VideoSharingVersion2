//
//  PlistSettingViewController.m
//  
//
//  Created by Catherine Zhao on 2016-03-06.
//
//

#import "PlistSettingViewController.h"
#import <DropboxSDK/DropboxSDK.h>

@interface PlistSettingViewController ()

@end

@implementation PlistSettingViewController

DBRestClient *restClient;
NSURL *fileURL;
NSString *plistName;
NSMutableDictionary *videoIds;
UIAlertController *emptyGroupName;
UIAlertController *emptyPlaylistFolder;
UIAlertController *createNewPlaylist;
UIAlertController *downloadError;
UIAlertController *missingFileName;
UIAlertController *missingFileURL;
UIAlertController *uploadSuccess;
UIAlertController *downloadSuccess;
UIAlertController *uploadError;
UIAlertAction *okAction;
UIAlertAction *cancelAction;
UIAlertAction *createAction;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setPlist];
    emptyGroupName = [UIAlertController alertControllerWithTitle: @"GroupName cannot be Empty" message:@"Please enter in a GroupName" preferredStyle:UIAlertControllerStyleAlert];
    emptyPlaylistFolder = [UIAlertController alertControllerWithTitle:@"Cannot Upload Playlist" message:@"Cannot upload an empty playlist" preferredStyle:UIAlertControllerStyleAlert];
    uploadError = [UIAlertController alertControllerWithTitle:@"Upload Error" message:@"Upload Playlist encounters an error. Please make sure you have internet connection" preferredStyle:UIAlertControllerStyleAlert];
    downloadError = [UIAlertController alertControllerWithTitle:@"Download Error" message:@"Download Playlist encounters an error. Please make sure you have internet connection" preferredStyle:UIAlertControllerStyleAlert];
    missingFileName = [UIAlertController alertControllerWithTitle:@"File Name cannot be Empty" message:@"Please enter in a File Name" preferredStyle:UIAlertControllerStyleAlert];
    missingFileURL = [UIAlertController alertControllerWithTitle:@"File URL cannot be Empty" message:@"Please enter in a File URL" preferredStyle:UIAlertControllerStyleAlert];
    uploadSuccess = [UIAlertController alertControllerWithTitle:@"Upload Successful" message:@"PlayList successfully Uploaded" preferredStyle:UIAlertControllerStyleAlert];
    downloadSuccess = [UIAlertController alertControllerWithTitle:@"Download Successful" message:@"PlayList successfully Downloaded" preferredStyle:UIAlertControllerStyleAlert];
    okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [emptyGroupName addAction:okAction];
    [emptyPlaylistFolder addAction:okAction];
    [uploadError addAction:okAction];
    [downloadError addAction:okAction];
    [missingFileName addAction:okAction];
    [missingFileURL addAction:okAction];
    [uploadSuccess addAction:okAction];
    [downloadSuccess addAction:okAction];
    
    
    createNewPlaylist = [UIAlertController alertControllerWithTitle:@"Create New Playlist" message:@"This playlist does not exist yet. Are you sure you want to create it?" preferredStyle:UIAlertControllerStyleAlert];
    cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    createAction = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction *alert) {
        [restClient uploadFile:plistName toPath:@"/" withParentRev:nil fromPath:fileURL.path];
    }];
    [createNewPlaylist addAction:createAction];
    [createNewPlaylist addAction:cancelAction];
    
    self.fileURLField.delegate = self;
    
    restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession] userId:@"551438413"];
    restClient.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.groupNameField.text = plistName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)linkToPersonalDropbox:(id)sender {
    [[DBSession sharedSession] unlinkAll];
    [[DBSession sharedSession] linkFromController:self];
}

-(void)setRestClient {
    NSString* userID = [[[DBSession sharedSession] userIds] firstObject];
    restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession] userId:userID];
    restClient.delegate = self;
}
- (IBAction)linkToPublicDropbox:(id)sender {
    [[DBSession sharedSession] unlinkAll];
    DBSession *dbSession = [[DBSession alloc]initWithAppKey:@"v7qvmmcql1k3leu" appSecret:@"n24c2enkvp10mdl" root:kDBRootAppFolder];
    [dbSession updateAccessToken:@"9uu88jm18fhverki" accessTokenSecret:@"6zxgx2dbtnnjpqv" forUserId:@"551438413"];
    [DBSession setSharedSession:dbSession];
    restClient = [[DBRestClient alloc] initWithSession:dbSession userId:@"551438413"];
    restClient.delegate = self;
}

#pragma mark - Upload Plist Methods
- (IBAction)uploadPlist:(id)sender {
    if ([videoIds count] <= 0) {
        [self presentAlertView:emptyPlaylistFolder];
    }
    [self changePlistName:nil];
    NSFileManager *fileManage = [NSFileManager defaultManager];
    if(![fileManage fileExistsAtPath:fileURL.path]){
        [self writeToFile];
    }
    [self writeToFile];
    [restClient loadMetadata:@"/"];
}

-(void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    if (metadata.isDirectory) {
        NSLog(@"Folder '%@' contains:", metadata.path);
        for (DBMetadata *file in metadata.contents) {
            NSLog(@"	%@", file.filename);
            if([file.filename isEqualToString:plistName]){
                [restClient uploadFile:plistName toPath:@"/" withParentRev:file.rev fromPath:fileURL.path];
                return;
            }
        }
        [self presentAlertView:createNewPlaylist];
    }
}

- (void)restClient:(DBRestClient *)client
loadMetadataFailedWithError:(NSError *)error {
    NSLog(@"Error loading metadata: %@", error);
    [self presentAlertView:uploadError];
}

-(void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
    [self presentAlertView:uploadSuccess];
}

-(void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    NSLog(@"Failure");
    [self presentAlertView:uploadError];
}

#pragma mark - Download Plist Methods

- (IBAction)downloadPlist:(id)sender {
    [self changePlistName:nil];
    [restClient loadFile: [NSString stringWithFormat:@"/%@",plistName] intoPath:fileURL.path];
}

-(void)restClient:(DBRestClient *)client loadedFile:(NSString *)destPath contentType:(NSString *)contentType metadata:(DBMetadata *)metadata {
    NSLog(@"File loaded into path: %@", destPath);
    [PlistSettingViewController populateLocalDictionary];
    [self presentAlertView:downloadSuccess];
}

-(void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error {
    [self presentAlertView:downloadError];
}

#pragma mark - WriteTo Plist Methods
-(void)writeToFile {
    [videoIds writeToFile:fileURL.path atomically:false];
}


- (IBAction)addVideo:(id)sender {
    if ([plistName length] == 0) {
        [self presentAlertView:emptyGroupName];
        return;
    }
    if ([self.fileNameField.text length] == 0) {
        [self presentAlertView:missingFileName];
        return;
        
    }
    if ([self.fileURLField.text length] == 0) {
        [self presentAlertView:missingFileURL];
        return;
    }
    
    NSString *fileName = [self.fileNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSNumber *fileType;
    NSString *fileURL;
    if(self.fileTypeSelector.selectedSegmentIndex == 0){
        fileType = [NSNumber numberWithInt:FILE_YOUTUBE];
        NSArray *urlArray = [self.fileURLField.text componentsSeparatedByString:@"v="];
        NSArray *videoIdArray = [urlArray[1] componentsSeparatedByString:@"&"];
        fileURL = videoIdArray[0];
    }else{
        fileType = [NSNumber numberWithInt:FILE_OTHER];
        fileURL = self.fileURLField.text;
    }
    videoIds[fileName] = @[fileType,fileURL];
    [self writeToFile];
}

-(void)presentAlertView:(UIAlertController*)alertView {
    if(self.presentedViewController != nil){
         [self.presentedViewController.view removeFromSuperview];
    }
    [self presentViewController:alertView animated:true completion:nil];
}
- (IBAction)changePlistName:(id)sender {
    if([self.groupNameField.text length] == 0){
        [self presentAlertView:emptyGroupName];
        return;
    }
    if ([self.groupNameField.text isEqualToString:plistName]) {
        return;
    }
    plistName = self.groupNameField.text;
    NSURL *documentsURL = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    fileURL = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",plistName]];
    NSString *filename = @"plistName.txt";
    NSString *localDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *localPath = [localDir stringByAppendingPathComponent:filename];
    [plistName writeToFile:localPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    NSFileManager *fileManage = [NSFileManager defaultManager];
    if([fileManage fileExistsAtPath:fileURL.path]){
        videoIds= [[NSMutableDictionary alloc] initWithContentsOfFile:fileURL.path];
    }else{
        videoIds = [[NSMutableDictionary alloc]init];
    }
}

- (void)setPlist {
    NSString *filename = @"plistName.txt";
    NSString *localDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *localPath = [localDir stringByAppendingPathComponent:filename];
    NSFileManager *fileManage = [NSFileManager defaultManager];
    if([fileManage fileExistsAtPath:localPath]){
        plistName = [[NSString alloc]initWithContentsOfFile:localPath encoding:NSUTF8StringEncoding error:NULL];
        self.groupNameField.text = plistName;
        return;
    }
}

+(NSDictionary *)getVideoPlaylist:(FileType)fileType {
    NSMutableDictionary *returnDic = [[NSMutableDictionary alloc]init];
    for (NSString *key in videoIds) {
        NSLog(@"%i", FILE_YOUTUBE);
        if([videoIds[key][0] intValue] == fileType){
            returnDic[key] = videoIds[key][1];
        }
    }
    return [returnDic copy];
}

- (IBAction)clearWebList:(id)sender {
    for (NSString *key in videoIds.copy) {
        if([videoIds[key][0] intValue] == FILE_OTHER){
            [videoIds removeObjectForKey:key];
        }
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"WebClear" object:nil];
}

- (IBAction)clearYoutubeList:(id)sender {
    for (NSString *key in videoIds.copy) {
        if([videoIds[key][0] intValue] == FILE_YOUTUBE){
            [videoIds removeObjectForKey:key];
        }
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"YoutubeClear" object:nil];
}

+(void)populateLocalDictionary {
    NSString *filename = @"plistName.txt";
    NSString *localDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *localPath = [localDir stringByAppendingPathComponent:filename];
    NSFileManager *fileManage = [NSFileManager defaultManager];
    if(![fileManage fileExistsAtPath:localPath]){
        return;
    }
    plistName = [[NSString alloc]initWithContentsOfFile:localPath encoding:NSUTF8StringEncoding error:NULL];

    
    NSURL *documentsURL = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    fileURL = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",plistName]];
    if(![fileManage fileExistsAtPath:fileURL.path]){
        videoIds = [[NSMutableDictionary alloc]init];
        return;
    }
    videoIds= [[NSMutableDictionary alloc] initWithContentsOfFile:fileURL.path];
}

-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:true];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField setText:@""];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
