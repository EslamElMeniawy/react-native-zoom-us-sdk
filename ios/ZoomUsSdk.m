#import "ZoomUsSdk.h"


@implementation ZoomUsSdk
{
    RCTPromiseResolveBlock initializePromiseResolve;
    RCTPromiseRejectBlock initializePromiseReject;
}

- (instancetype)init {
    if (self = [super init]) {
        initializePromiseResolve = nil;
        initializePromiseReject = nil;
    }
    return self;
}

+ (BOOL)requiresMainQueueSetup
{
    return NO;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

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
    
    if ([[MobileRTC sharedRTC] isRTCAuthorized]) {
        resolve(@"Zoom SDK is already initialized.");
        return;
    }
    
    @try {
        MobileRTCSDKInitContext *context = [[MobileRTCSDKInitContext alloc] init];
        context.domain = webDomain;
        BOOL initializeSuc = [[MobileRTC sharedRTC] initialize:context];
        NSLog(@"initializeSuc=%@",@(initializeSuc));
        
        MobileRTCAuthService *authService = [[MobileRTC sharedRTC] getAuthService];
        
        if (authService)
        {
            initializePromiseResolve = resolve;
            initializePromiseReject = reject;
            
            authService.delegate = self;
            authService.clientKey = appKey;
            authService.clientSecret = appSecret;
            [authService sdkAuth];
        } else {
            NSLog(@"onMobileRTCAuthReturn: No authService");
            
            reject(@"ERR_ZOOM_INITIALIZATION",  @"Executing initializeZoom: No authService", [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]);
        }
    } @catch (NSError *ex) {
        reject(@"ERR_UNEXPECTED_EXCEPTION", @"Executing initializeZoom", ex);
    }
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

- (void)onMobileRTCAuthReturn:(MobileRTCAuthError)returnValue {
    NSLog(@"onMobileRTCAuthReturn: errorCode=%d", returnValue);
    
    if (initializePromiseResolve == nil || initializePromiseReject == nil) {
        return;
    }
    
    if (returnValue == MobileRTCAuthError_Success) {
        initializePromiseResolve(@"Initialize Zoom SDK successfully.");
    } else {
        initializePromiseReject(
          @"ERR_ZOOM_INITIALIZATION",
          [NSString stringWithFormat:@"Error: %d", returnValue],
          [NSError errorWithDomain:@"us.zoom.sdk" code:returnValue userInfo:nil]
        );
    }
    
    initializePromiseResolve = nil;
    initializePromiseReject = nil;
}

@end
