#import "ZoomUsSdk.h"


@implementation ZoomUsSdk
{
    RCTPromiseResolveBlock initializePromiseResolve;
    RCTPromiseRejectBlock initializePromiseReject;
    RCTPromiseResolveBlock meetingPromiseResolve;
    RCTPromiseRejectBlock meetingPromiseReject;
}

- (instancetype)init {
    if (self = [super init]) {
        initializePromiseResolve = nil;
        initializePromiseReject = nil;
        meetingPromiseResolve = nil;
        meetingPromiseReject = nil;
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
    
    if (![[MobileRTC sharedRTC] isRTCAuthorized]) {
        reject(@"ERR_ZOOM_START",  @"Executing startMeeting: ZoomSDK has not been initialized successfully", [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]);
        
        return;
    }
    
    MobileRTCMeetingService *meetingService = [[MobileRTC sharedRTC] getMeetingService];
    
    if (meetingService) {
        if ([meetingService getMeetingState] != MobileRTCMeetingState_Idle) {
            reject(@"ERR_ZOOM_IN_MEETING",  @"Executing startMeeting: Already in meeting", [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]);
            
            return;
        }
        
        @try {
            meetingPromiseResolve = resolve;
            meetingPromiseReject = reject;
            
            meetingService.delegate = self;
            
            MobileRTCMeetingSettings *meetingSettings = [[MobileRTC sharedRTC] getMeetingSettings];
            [meetingSettings setAutoConnectInternetAudio:true];
            [meetingSettings disableCallIn:true];
            [meetingSettings disableCallOut:true];
            meetingSettings.meetingTitleHidden = true;
            meetingSettings.meetingPasswordHidden = true;
            meetingSettings.meetingAudioHidden = true;
            meetingSettings.meetingVideoHidden = true;
            meetingSettings.meetingInviteHidden = true;
            meetingSettings.meetingParticipantHidden = true;
            meetingSettings.meetingShareHidden = true;
            meetingSettings.meetingMoreHidden = true;
            
            MobileRTCMeetingStartParam4WithoutLoginUser * params = [[MobileRTCMeetingStartParam4WithoutLoginUser alloc]init];
            params.userName = displayName;
            params.meetingNumber = meetingNo;
            params.userID = userId;
            params.userType = MobileRTCUserType_APIUser;
            params.zak = zoomAccessToken;
            params.userToken = zoomToken;
            
            MobileRTCMeetError startMeetingResult = [meetingService startMeetingWithStartParam:params];
            NSLog(@"startMeeting: startMeetingResult=%d", startMeetingResult);
            
            if (startMeetingResult != MobileRTCMeetError_Success) {
                reject(
                       @"ERR_ZOOM_START",
                       [NSString stringWithFormat:@"Error: %d", startMeetingResult],
                       [NSError errorWithDomain:@"us.zoom.sdk" code:startMeetingResult userInfo:nil]
                       );
                
                meetingService.delegate = nil;
                meetingPromiseResolve = nil;
                meetingPromiseReject = nil;
            }
        } @catch (NSError *ex) {
            reject(@"ERR_UNEXPECTED_EXCEPTION", @"Executing startMeeting", ex);
        }
    } else {
        reject(@"ERR_ZOOM_START",  @"Executing startMeeting: No meetingService", [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]);
    }
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
    
    if (![[MobileRTC sharedRTC] isRTCAuthorized]) {
        reject(@"ERR_ZOOM_JOIN",  @"Executing joinMeeting: ZoomSDK has not been initialized successfully", [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]);
        
        return;
    }
    
    MobileRTCMeetingService *meetingService = [[MobileRTC sharedRTC] getMeetingService];
    
    if (meetingService) {
        if ([meetingService getMeetingState] != MobileRTCMeetingState_Idle) {
            reject(@"ERR_ZOOM_IN_MEETING",  @"Executing joinMeeting: Already in meeting", [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]);
            
            return;
        }
        
        @try {
            meetingPromiseResolve = resolve;
            meetingPromiseReject = reject;
            
            meetingService.delegate = self;
            
            MobileRTCMeetingSettings *meetingSettings = [[MobileRTC sharedRTC] getMeetingSettings];
            [meetingSettings setAutoConnectInternetAudio:true];
            [meetingSettings disableCallIn:true];
            [meetingSettings disableCallOut:true];
            meetingSettings.meetingTitleHidden = true;
            meetingSettings.meetingPasswordHidden = true;
            meetingSettings.meetingAudioHidden = true;
            meetingSettings.meetingVideoHidden = true;
            meetingSettings.meetingInviteHidden = true;
            meetingSettings.meetingParticipantHidden = true;
            meetingSettings.meetingShareHidden = true;
            meetingSettings.meetingMoreHidden = true;
            
            NSDictionary *paramDict = @{
                kMeetingParam_Username: displayName,
                kMeetingParam_MeetingNumber: meetingNo,
                kMeetingParam_MeetingPassword:meetingPassword
            };
            
            MobileRTCMeetError joinMeetingResult = [meetingService joinMeetingWithDictionary:paramDict];
            NSLog(@"joinMeeting: joinMeetingResult=%d", joinMeetingResult);
            
            if (joinMeetingResult != MobileRTCMeetError_Success) {
                reject(
                       @"ERR_ZOOM_JOIN",
                       [NSString stringWithFormat:@"Error: %d", joinMeetingResult],
                       [NSError errorWithDomain:@"us.zoom.sdk" code:joinMeetingResult userInfo:nil]
                       );
                
                meetingService.delegate = nil;
                meetingPromiseResolve = nil;
                meetingPromiseReject = nil;
            }
        } @catch (NSError *ex) {
            reject(@"ERR_UNEXPECTED_EXCEPTION", @"Executing startMeeting", ex);
        }
    } else {
        reject(@"ERR_ZOOM_JOIN",  @"Executing joinMeeting: No meetingService", [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]);
    }
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
    
    if (![[MobileRTC sharedRTC] isRTCAuthorized]) {
        reject(@"ERR_ZOOM_LEAVE",  @"Executing leaveCurrentMeeting: ZoomSDK has not been initialized successfully", [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]);
        
        return;
    }
    
    MobileRTCMeetingService *meetingService = [[MobileRTC sharedRTC] getMeetingService];
    
    if (meetingService) {
        [meetingService leaveMeetingWithCmd:LeaveMeetingCmd_Leave];
        resolve(@"Done leaving current meeting");
    } else {
        reject(@"ERR_ZOOM_LEAVE",  @"Executing leaveCurrentMeeting: No meetingService", [NSError errorWithDomain:@"us.zoom.sdk" code:-1 userInfo:nil]);
    }
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

- (void)onMeetingStateChange:(MobileRTCMeetingState)state {
    NSLog(@"onMeetingStateChange: meetingState=%d", state);
    
    if (!meetingPromiseResolve) {
        return;
    }
    
    if (state == MobileRTCMeetingState_InMeeting) {
        NSString *meetingNo = [[MobileRTCInviteHelper sharedInstance] ongoingMeetingNumber];
        NSString *meetingPass = [[MobileRTCInviteHelper sharedInstance] rawMeetingPassword];
        
        NSDictionary *dictData = @{
            @"meetingNumber":meetingNo,
            @"meetingPassword":meetingPass
        };
        
        NSLog(@"Zoom meeting data: %@", dictData);
        meetingPromiseResolve(dictData);
        
        meetingPromiseResolve = nil;
        meetingPromiseReject = nil;
    }
}

- (void)onMeetingError:(MobileRTCMeetError)error message:(NSString *)message {
    NSLog(@"onMeetingError: errorCode=%d, message=%@", error, message);
    
    if (!meetingPromiseResolve) {
        return;
    }
    
    meetingPromiseReject(
                         @"ERR_ZOOM_MEETING",
                         [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", error, message],
                         [NSError errorWithDomain:@"us.zoom.sdk" code:error userInfo:nil]
                         );
    
    meetingPromiseResolve = nil;
    meetingPromiseReject = nil;
}

@end
