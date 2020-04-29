package elmeniawy.eslam.zoomussdk;

import android.util.Log;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;

import us.zoom.sdk.InMeetingService;
import us.zoom.sdk.JoinMeetingOptions;
import us.zoom.sdk.JoinMeetingParams;
import us.zoom.sdk.MeetingError;
import us.zoom.sdk.MeetingService;
import us.zoom.sdk.MeetingServiceListener;
import us.zoom.sdk.MeetingStatus;
import us.zoom.sdk.MeetingViewsOptions;
import us.zoom.sdk.StartMeetingOptions;
import us.zoom.sdk.StartMeetingParamsWithoutLogin;
import us.zoom.sdk.ZoomError;
import us.zoom.sdk.ZoomSDK;
import us.zoom.sdk.ZoomSDKInitParams;
import us.zoom.sdk.ZoomSDKInitializeListener;

public class ZoomUsSdkModule extends ReactContextBaseJavaModule
        implements ZoomSDKInitializeListener, MeetingServiceListener {
    private static final String TAG = "ZoomUsSdk";
    private final ReactApplicationContext reactContext;
    private ZoomSDK mZoomSDK;
    private Promise initializePromise;
    private MeetingService meetingService;
    private Promise meetingPromise;

    ZoomUsSdkModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @NonNull
    @Override
    public String getName() {
        return "ZoomUsSdk";
    }

    @ReactMethod
    public void initializeZoom(final String appKey, final String appSecret, final String webDomain,
                               final Promise promise) {
        Log.v(TAG, "initializeZoom");
        mZoomSDK = ZoomSDK.getInstance();

        if (mZoomSDK.isInitialized()) {
            promise.resolve("Zoom SDK is already initialized.");
            return;
        }

        if (reactContext.getCurrentActivity() == null) {
            promise.reject("ERR_UNEXPECTED_EXCEPTION", "Current activity is null");
            return;
        }

        try {
            initializePromise = promise;

            reactContext.getCurrentActivity().runOnUiThread(() -> {
                ZoomSDK zoomSDK = ZoomSDK.getInstance();
                ZoomSDKInitParams initParams = new ZoomSDKInitParams();
                initParams.appKey = appKey;
                initParams.appSecret = appSecret;
                initParams.domain = webDomain;
                zoomSDK.initialize(reactContext, this, initParams);
            });
        } catch (Exception ex) {
            promise.reject("ERR_UNEXPECTED_EXCEPTION", ex);
        }
    }

    @ReactMethod
    public void startMeeting(final String jwtAccessToken, final String zoomToken,
                             final String zoomAccessToken, final String meetingNo,
                             final String userId, final String displayName, final Promise promise) {
        Log.v(TAG, "startMeeting");
        mZoomSDK = ZoomSDK.getInstance();

        if (!mZoomSDK.isInitialized()) {
            promise.reject(
                    "ERR_ZOOM_START", "ZoomSDK has not been initialized successfully"
            );

            return;
        }

        meetingService = mZoomSDK.getMeetingService();

        if (meetingService == null) {
            promise.reject(
                    "ERR_ZOOM_START", "Cannot get meeting service"
            );

            return;
        }

        if (meetingService.getMeetingStatus() != MeetingStatus.MEETING_STATUS_IDLE) {
            promise.reject("ERR_ZOOM_IN_MEETING", "Already in meeting");
            meetingService.removeListener(this);
            meetingService = null;
            return;
        }

        try {
            meetingPromise = promise;
            meetingService.addListener(this);

            StartMeetingOptions opts = new StartMeetingOptions();
            opts.no_invite = true;
            opts.no_meeting_end_message = true;
            opts.no_dial_in_via_phone = true;
            opts.no_dial_out_to_phone = true;
            opts.no_disconnect_audio = true;
            opts.no_share = true;

            opts.meeting_views_options = MeetingViewsOptions.NO_TEXT_MEETING_ID
                    + MeetingViewsOptions.NO_TEXT_PASSWORD + MeetingViewsOptions.NO_BUTTON_MORE
                    + MeetingViewsOptions.NO_BUTTON_PARTICIPANTS
                    + MeetingViewsOptions.NO_BUTTON_AUDIO + MeetingViewsOptions.NO_BUTTON_VIDEO;

            StartMeetingParamsWithoutLogin params = new StartMeetingParamsWithoutLogin();
            params.displayName = displayName;
            params.meetingNo = meetingNo;
            params.userId = userId;
            params.userType = MeetingService.USER_TYPE_API_USER;
            params.zoomAccessToken = zoomAccessToken;
            params.zoomToken = zoomToken;

            int startMeetingResult = meetingService.startMeetingWithParams(
                    reactContext.getCurrentActivity(), params, opts
            );

            Log.i(TAG, "startMeeting: startMeetingResult=" + startMeetingResult);

            if (startMeetingResult != MeetingError.MEETING_ERROR_SUCCESS) {
                promise.reject(
                        "ERR_ZOOM_START",
                        "startMeeting: errorCode=" + startMeetingResult
                );

                meetingService.removeListener(this);
                meetingService = null;
                meetingPromise = null;
            }
        } catch (Exception ex) {
            promise.reject("ERR_UNEXPECTED_EXCEPTION", ex);
            meetingService.removeListener(this);
            meetingService = null;
            meetingPromise = null;
        }
    }

    @ReactMethod
    public void joinMeeting(final String meetingNo, final String meetingPassword,
                            final String displayName, final Promise promise) {
        Log.v(TAG, "joinMeeting");
        mZoomSDK = ZoomSDK.getInstance();

        if (!mZoomSDK.isInitialized()) {
            promise.reject(
                    "ERR_ZOOM_JOIN", "ZoomSDK has not been initialized successfully"
            );

            return;
        }

        meetingService = mZoomSDK.getMeetingService();

        if (meetingService == null) {
            promise.reject(
                    "ERR_ZOOM_JOIN", "Cannot get meeting service"
            );

            return;
        }

        if (meetingService.getMeetingStatus() != MeetingStatus.MEETING_STATUS_IDLE) {
            promise.reject("ERR_ZOOM_IN_MEETING", "Already in meeting");
            meetingService.removeListener(this);
            meetingService = null;
            return;
        }

        try {
            JoinMeetingOptions opts = new JoinMeetingOptions();
            opts.no_invite = true;
            opts.no_meeting_end_message = true;
            opts.no_dial_in_via_phone = true;
            opts.no_dial_out_to_phone = true;
            opts.no_disconnect_audio = true;
            opts.no_share = true;

            opts.meeting_views_options = MeetingViewsOptions.NO_TEXT_MEETING_ID
                    + MeetingViewsOptions.NO_TEXT_PASSWORD + MeetingViewsOptions.NO_BUTTON_MORE
                    + MeetingViewsOptions.NO_BUTTON_PARTICIPANTS
                    + MeetingViewsOptions.NO_BUTTON_AUDIO + MeetingViewsOptions.NO_BUTTON_VIDEO;

            JoinMeetingParams params = new JoinMeetingParams();
            params.displayName = displayName;
            params.meetingNo = meetingNo;
            params.password = meetingPassword;

            int joinMeetingResult = meetingService.joinMeetingWithParams(
                    reactContext.getCurrentActivity(), params, opts
            );

            Log.i(TAG, "joinMeeting: joinMeetingResult=" + joinMeetingResult);

            if (joinMeetingResult == MeetingError.MEETING_ERROR_SUCCESS) {
                promise.resolve("Joined meeting successfully");
            } else {
                promise.reject(
                        "ERR_ZOOM_JOIN",
                        "joinMeeting: errorCode=" + joinMeetingResult
                );
            }

            meetingService.removeListener(this);
            meetingService = null;
        } catch (Exception ex) {
            promise.reject("ERR_UNEXPECTED_EXCEPTION", ex);
            meetingService.removeListener(this);
            meetingService = null;
        }
    }

    @ReactMethod
    public void returnToCurrentMeeting(final Promise promise) {
        Log.v(TAG, "returnToCurrentMeeting");
        mZoomSDK = ZoomSDK.getInstance();

        if (!mZoomSDK.isInitialized()) {
            promise.reject(
                    "ERR_ZOOM_RETURN", "ZoomSDK has not been initialized successfully"
            );

            return;
        }

        meetingService = mZoomSDK.getMeetingService();

        if (meetingService == null) {
            promise.reject(
                    "ERR_ZOOM_RETURN", "Cannot get meeting service"
            );

            return;
        }

        meetingService.returnToMeeting(reactContext.getCurrentActivity());
        promise.resolve("Done returning to current meeting");
        meetingService.removeListener(this);
        meetingService = null;
    }

    @ReactMethod
    public void leaveCurrentMeeting(final Promise promise) {
        Log.v(TAG, "leaveCurrentMeeting");
        mZoomSDK = ZoomSDK.getInstance();

        if (!mZoomSDK.isInitialized()) {
            promise.reject(
                    "ERR_ZOOM_LEAVE", "ZoomSDK has not been initialized successfully"
            );

            return;
        }

        meetingService = mZoomSDK.getMeetingService();

        if (meetingService == null) {
            promise.reject(
                    "ERR_ZOOM_LEAVE", "Cannot get meeting service"
            );

            return;
        }

        meetingService.leaveCurrentMeeting(true);
        promise.resolve("Done leaving current meeting");
        meetingService.removeListener(this);
        meetingService = null;
    }

    @Override
    public void onZoomSDKInitializeResult(int errorCode, int internalErrorCode) {
        Log.i(
                TAG,
                "onZoomSDKInitializeResult: errorCode=" + errorCode + ", internalErrorCode="
                        + internalErrorCode
        );

        if (initializePromise == null) {
            return;
        }

        if (errorCode == ZoomError.ZOOM_ERROR_SUCCESS) {
            initializePromise.resolve("Initialize Zoom SDK successfully.");
        } else {
            initializePromise.reject(
                    "ERR_ZOOM_INITIALIZATION",
                    "Error: errorCode=" + errorCode + ", internalErrorCode="
                            + internalErrorCode
            );
        }

        initializePromise = null;
    }

    @Override
    public void onZoomAuthIdentityExpired() {
        Log.e(TAG, "onZoomAuthIdentityExpired in init");
    }

    @Override
    public void onMeetingStatusChanged(MeetingStatus meetingStatus, int errorCode,
                                       int internalErrorCode) {
        Log.i(
                TAG,
                "onMeetingStatusChanged: meetingStatus=" + meetingStatus + ", errorCode="
                        + errorCode + ", internalErrorCode=" + internalErrorCode
        );

        if (meetingPromise == null) {
            meetingService.removeListener(this);
            meetingService = null;
            return;
        }

        if (meetingStatus == MeetingStatus.MEETING_STATUS_FAILED) {
            meetingPromise.reject(
                    "ERR_ZOOM_MEETING",
                    "Error: errorCode=" + errorCode + ", internalErrorCode="
                            + internalErrorCode
            );
        } else if (meetingStatus == MeetingStatus.MEETING_STATUS_INMEETING) {
            mZoomSDK = ZoomSDK.getInstance();

            if (!mZoomSDK.isInitialized()) {
                meetingPromise.reject(
                        "ERR_ZOOM_MEETING",
                        "ZoomSDK has not been initialized successfully"
                );

                meetingService.removeListener(this);
                meetingService = null;
                meetingPromise = null;
                return;
            }

            InMeetingService inMeetingService = mZoomSDK.getInMeetingService();

            if (inMeetingService == null) {
                meetingPromise.reject(
                        "ERR_ZOOM_MEETING", "Cannot get in meeting service"
                );

                meetingService.removeListener(this);
                meetingService = null;
                meetingPromise = null;
                return;
            }

            WritableMap map = Arguments.createMap();

            map.putString(
                    "meetingNumber", String.valueOf(inMeetingService.getCurrentMeetingNumber())
            );

            map.putString("meetingPassword", inMeetingService.getMeetingPassword());
            Log.i(TAG, "Zoom meeting data: " + map);
            meetingPromise.resolve(map);
        }

        meetingService.removeListener(this);
        meetingService = null;
        meetingPromise = null;
    }
}
