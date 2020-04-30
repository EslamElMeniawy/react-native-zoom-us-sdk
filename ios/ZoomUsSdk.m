#import "ZoomUsSdk.h"


@implementation ZoomUsSdk

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(
                  initializeZoom: (NSString *)appKey
                  withAppSecret: (NSString *)appSecret
                  withWebDomain: (NSString *)webDomain
                  withResolve: (RCTPromiseResolveBlock)resolve
                  withReject: (RCTPromiseRejectBlock)reject
                  )
{
    NSLog(@"initializeZoom");
    reject(@"ERR_ZOOM_INITIALIZATION",  @"Executing initializeZoom: iOS part of this library is not implemented yet", [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]);
}

RCT_EXPORT_METHOD(
                  startMeeting: (NSString *)jwtAccessToken
                  withZoomToken: (NSString *)zoomToken
                  withZoomAccessToken: (NSString *)zoomAccessToken
                  withMeetingNo: (NSString *)meetingNo
                  withUserId: (NSString *)userId
                  withDisplayName: (NSString *)displayName
                  withResolve: (RCTPromiseResolveBlock)resolve
                  withReject: (RCTPromiseRejectBlock)reject
                  )
{
    NSLog(@"startMeeting");
    reject(@"ERR_ZOOM_START",  @"Executing startMeeting: iOS part of this library is not implemented yet", [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]);
}

RCT_EXPORT_METHOD(
                  joinMeeting: (NSString *)meetingNo
                  withMeetingPassword: (NSString *)meetingPassword
                  withDisplayName: (NSString *)displayName
                  withResolve: (RCTPromiseResolveBlock)resolve
                  withReject: (RCTPromiseRejectBlock)reject
                  )
{
    NSLog(@"joinMeeting");
    reject(@"ERR_ZOOM_JOIN",  @"Executing joinMeeting: iOS part of this library is not implemented yet", [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]);
}

RCT_EXPORT_METHOD(
                  returnToCurrentMeeting: (RCTPromiseResolveBlock)resolve
                  withReject: (RCTPromiseRejectBlock)reject
                  )
{
    NSLog(@"returnToCurrentMeeting");
    reject(@"ERR_ZOOM_RETURN",  @"Executing returnToCurrentMeeting: iOS part of this library is not implemented yet", [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]);
}

RCT_EXPORT_METHOD(
                  leaveCurrentMeeting: (RCTPromiseResolveBlock)resolve
                  withReject: (RCTPromiseRejectBlock)reject
                  )
{
    NSLog(@"leaveCurrentMeeting");
    reject(@"ERR_ZOOM_LEAVE",  @"Executing leaveCurrentMeeting: iOS part of this library is not implemented yet", [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]);
}

@end
