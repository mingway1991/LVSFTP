//
//  main.m
//  LVSFTP
//
//  Created by yanguo sun on 18/09/2016.
//  Copyright © 2016 Lvmama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NMSSH.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        if (argc - 1 < 4) {
            printf("参数个数不匹配\n");
            return 0;
        }
        
        NSString *host = [NSString stringWithFormat:@"%s", argv[1]];
        NSString *username = [NSString stringWithFormat:@"%s", argv[2]];
        NSString *password = [NSString stringWithFormat:@"%s", argv[3]];
        NSString *remoteDirectory = [NSString stringWithFormat:@"%s", argv[4]];
        
        NMSSHSession *session = [[NMSSHSession alloc] initWithHost:host andUsername:username];
        [session connect];
        
        if (session.isConnected) {
            [session authenticateByPassword:password];
            
            if (session.isAuthorized) {
                [session.sftp connect];
                
                for (int i=5; i<(argc-1); i+=2) {
                    NSString *localFilePath = [NSString stringWithFormat:@"%s", argv[i]];
                    NSString *toFilePath = [NSString stringWithFormat:@"%@/%s", remoteDirectory, argv[i+1]];
                    BOOL writeResult = [session.channel uploadFile:localFilePath to:toFilePath];
                    assert(writeResult);
                }
            }
            NSArray *remoteFileList = [session.sftp contentsOfDirectoryAtPath:remoteDirectory];
            for (NMSFTPFile *file in remoteFileList) {
                NSLog(@"--------%@--------", file.filename);
            }
            
            [session disconnect];
        }
        NSRunLoop *currLoop = [NSRunLoop currentRunLoop];
        [currLoop addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
        [currLoop run];
    }
    return 0;
}
