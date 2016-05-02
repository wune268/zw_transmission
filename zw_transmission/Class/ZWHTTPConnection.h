//
//  ZWHTTPConnection.h
//  transmission
//
//  Created by zzwu on 16/5/2.
//  Copyright © 2016年 zzwu. All rights reserved.
//

#import "HTTPConnection.h"
#import "MultipartFormDataParser.h"

@interface ZWHTTPConnection : HTTPConnection<MultipartFormDataParserDelegate>
{
    BOOL                     isUploading;    //Is not being performed Upload
    MultipartFormDataParser  *parser;        //
    NSFileHandle             *storeFile;     //Storing uploaded files
    UInt64                   uploadFileSize; //The total size of the uploaded file
    NSMutableArray           *uploadedFiles;
}

@end
