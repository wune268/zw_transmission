//
//  ZWHTTPConnection.m
//  transmission
//
//  Created by zzwu on 16/5/2.
//  Copyright © 2016年 zzwu. All rights reserved.
//

#import "ZWHTTPConnection.h"


#import "HTTPMessage.h"
#import "MultipartMessageHeader.h"
#import "MultipartMessageHeaderField.h"
#import "HTTPDynamicFileResponse.h"


#import "HTTPDataResponse.h"
#import "DDNumber.h"
#import "MultipartFormDataParser.h"
#import "HTTPFileResponse.h"

@implementation ZWHTTPConnection

#pragma mark HTTP Request and Response
- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
//    HTTPLogTrace();
    
    // Add support for POST
    
    if ([method isEqualToString:@"POST"])
    {
        if ([path isEqualToString:@"/post.html"])
        {
            return YES;
        }
    }
    
    return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
    
    // Inform HTTP server that we expect a body to accompany a POST request
    
    if([method isEqualToString:@"POST"] && [path isEqualToString:@"/post.html"]) {
        // here we need to make sure, boundary is set in header
        NSString* contentType = [request headerField:@"Content-Type"];
        NSUInteger paramsSeparator = [contentType rangeOfString:@";"].location;
        if( NSNotFound == paramsSeparator ) {
            return NO;
        }
        if( paramsSeparator >= contentType.length - 1 ) {
            return NO;
        }
        NSString* type = [contentType substringToIndex:paramsSeparator];
        if( ![type isEqualToString:@"multipart/form-data"] ) {
            // we expect multipart/form-data content type
            return NO;
        }
        
        // enumerate all params in content-type, and find boundary there
        NSArray* params = [[contentType substringFromIndex:paramsSeparator + 1] componentsSeparatedByString:@";"];
        for( NSString* param in params ) {
            paramsSeparator = [param rangeOfString:@"="].location;
            if( (NSNotFound == paramsSeparator) || paramsSeparator >= param.length - 1 ) {
                continue;
            }
            NSString* paramName = [param substringWithRange:NSMakeRange(1, paramsSeparator-1)];
            NSString* paramValue = [param substringFromIndex:paramsSeparator+1];
            
            if( [paramName isEqualToString: @"boundary"] ) {
                // let's separate the boundary from content-type, to make it more handy to handle
                [request setHeaderField:@"boundary" value:paramValue];
            }
        }
        // check if boundary specified
        if( nil == [request headerField:@"boundary"] )  {
            return NO;
        }
        return YES;
    }
    return [super expectsRequestBodyFromMethod:method atPath:path];
}

//- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
//{
//    
//    if ([method isEqualToString:@"POST"] && [path isEqualToString:@"/post.html"])
//    {
//        
//        // this method will generate response with links to uploaded file
//        NSMutableString* filesStr = [[NSMutableString alloc] init];
//        
////        for( NSString* filePath in uploadedFiles ) {
////            //generate links
////            [filesStr appendFormat:@"<a href=\"%@\"> %@ </a><br/>",filePath, [filePath lastPathComponent]];
////        }
//        NSString* templatePath = [[config documentRoot] stringByAppendingPathComponent:@"/post.html"];
//        NSDictionary* replacementDict = [NSDictionary dictionaryWithObject:filesStr forKey:@"MyFiles"];
//        // use dynamic file response to apply our links to response template
//        return [[HTTPDynamicFileResponse alloc] initWithFilePath:templatePath forConnection:self separator:@"%" replacementDictionary:replacementDict];
//    }
//    if( [method isEqualToString:@"GET"] && [path hasPrefix:@"/upload/"] ) {
//        // let download the uploaded files
//        return [[HTTPFileResponse alloc] initWithFilePath: [[config documentRoot] stringByAppendingString:path] forConnection:self];
//    }
//    
//    return [super httpResponseForMethod:method URI:path];
//}

- (void)prepareForBodyWithSize:(UInt64)contentLength
{
    
    // set up mime parser
    NSString* boundary = [request headerField:@"boundary"];
    parser = [[MultipartFormDataParser alloc] initWithBoundary:boundary formEncoding:NSUTF8StringEncoding];
    parser.delegate = self;
    
    uploadedFiles = [[NSMutableArray alloc] init];
}

- (void)processBodyData:(NSData *)postDataChunk
{
    // append data to the parser. It will invoke callbacks to let us handle
    // parsed data.
    [parser appendData:postDataChunk];
}


//-----------------------------------------------------------------
#pragma mark multipart form data parser delegate


- (void) processStartOfPartWithHeader:(MultipartMessageHeader*) header {
    // in this sample, we are not interested in parts, other then file parts.
    // check content disposition to find out filename
    
    
    MultipartMessageHeaderField *disposition = [header.fields objectForKey:@"Content-Disposition"];
    NSString *fileName = [[disposition.params objectForKey:@"filename"] lastPathComponent];
    if (fileName==nil || [fileName isEqualToString:@""])
        return;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *uploadFilePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    //Ready to write the file, if the file already exists Overwrite
    if (![[NSFileManager defaultManager] createFileAtPath:uploadFilePath contents:nil attributes:nil])
        return;
    isUploading = YES;
    storeFile = [NSFileHandle fileHandleForWritingAtPath:uploadFilePath];
}


- (void) processContent:(NSData*) data WithHeader:(MultipartMessageHeader*) header
{
    // here we just write the output from parser to the file.
    if( storeFile ) {
        [storeFile writeData:data];
    }
}

- (void) processEndOfPartWithHeader:(MultipartMessageHeader*) header
{
    // as the file part is over, we close the file.
    [storeFile closeFile];
    storeFile = nil;
}

- (void) processPreambleData:(NSData*) data 
{
    // if we are interested in preamble data, we could process it here.
    
}

- (void) processEpilogueData:(NSData*) data 
{
    // if we are interested in epilogue data, we could process it here.
    
}
@end
