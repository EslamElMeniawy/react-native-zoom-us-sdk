# React Native zoom.us SDK

Implementation of native Android and iOS zoom.us SDK for React Native.

## Getting started

### 1. Install native zoom.us SDK

This is an implementation of the native Android and iOS zoom.us SDK so before you start you need to install the native Android and iOS SDK first to your project.

Follow [Zoom Developer Documentation](https://marketplace.zoom.us/docs/guides) to create a developer account and application.

#### Android

Follow [Zoom Android SDK Documentation](https://marketplace.zoom.us/docs/sdk/native-sdks/android) to install native Android SDK in your project.

#### iOS

Follow [Zoom iOS SDK Documentation](https://marketplace.zoom.us/docs/sdk/native-sdks/iOS) to just download the library and don't add it to project.

### 2. Install the library

using either Yarn:

```bash
$ yarn add https://github.com/EslamElMeniawy/react-native-zoom-us-sdk
```

or npm:

```bash
$ npm install --save https://github.com/EslamElMeniawy/react-native-zoom-us-sdk
```

### 3. Add native zoom.us iOS SDK

Move the iOS `lib` folder downloaded in first step to

```
projectDir/node_modules/react-native-zoom-us-sdk/ios
```

### 4. Link

- **React Native 0.60+**

[CLI autolink feature](https://github.com/react-native-community/cli/blob/master/docs/autolinking.md) links the module while building the app. 


- **React Native <= 0.59**

```bash
$ react-native link react-native-zoom-us-sdk
```

*Note* For `iOS` using `cocoapods`, run:

```bash
$ cd ios/ && pod install
```

## Usage

### Import the library

```javascript
import ZoomUsSdk from 'react-native-zoom-us-sdk';
```

### Initialize Zoom SDK

```javascript
try {
  const initializeResult = await ZoomUsSdk.initializeZoom(
    'SdkApiKey',
    'SdkApiSecret',
    'WebDomain',
  );

  console.log(initializeResult);
} catch (exception) {
  console.error('Error initialize zoom', exception);
}
```

### Start Meeting

```javascript
try {
  const startResult = await ZoomUsSdk.startMeeting(
    'JwtAccessToken',
    'ZoomToken',
    'ZoomAccessToken',
    'MeetingNnumber',
    'UserId',
    'DisplayName',
    // Meeting options.
    {
      autoConnectAudio: true,
      disableCallIn: true,
      disableCallOut: true,
      meetingInviteHidden: true,
      meetingShareHidden: true,
      meetingIdHidden: true,
      meetingPasswordHidden: true,
      meetingAudioHidden: true,
      meetingVideoHidden: true,
      meetingParticipantHidden: true,
      meetingMoreHidden: true,
    },
  );

  console.log(startResult);
} catch (exception) {
  if (exception.code === 'ERR_ZOOM_IN_MEETING') {
    // User already in a meeting.
    // You can either use ZoomUsSdk.returnToCurrentMeeting()
    // Or ZoomUsSdk.leaveCurrentMeeting()
    // Or let the user decide.
  } else {
    console.error('Error start meeting', exception);
  }
}
```

### Join Meeting

```javascript
try {
  const joinResult = await ZoomUsSdk.joinMeeting(
    'MeetingNnumber', // This value is returened in start meeting result.
    'MeetingPassword', // This value is returened in start meeting result.
    'DisplayName',
    // Meeting options.
    {
      autoConnectAudio: true,
      disableCallIn: true,
      disableCallOut: true,
      meetingInviteHidden: true,
      meetingShareHidden: true,
      meetingIdHidden: true,
      meetingPasswordHidden: true,
      meetingAudioHidden: true,
      meetingVideoHidden: true,
      meetingParticipantHidden: true,
      meetingMoreHidden: true,
    },
  );

  console.log(joinResult);
} catch (exception) {
  if (exception.code === 'ERR_ZOOM_IN_MEETING') {
    // User already in a meeting.
    // You can either use ZoomUsSdk.returnToCurrentMeeting()
    // Or ZoomUsSdk.leaveCurrentMeeting()
    // Or let the user decide.
  } else {
    console.error('Error join meeting', exception);
  }
}
```

### Return To Current Meeting

```javascript
try {
  const returnToMeetingResult = await ZoomUsSdk.returnToCurrentMeeting();
  console.log(returnToMeetingResult);
} catch (exception) {
  console.error('Error returning to current meeting', exception);
}
```

### Leave Current Meeting

```javascript
try {
  const leaveMeetingResult = await ZoomUsSdk.leaveCurrentMeeting();
  console.log(leaveMeetingResult);
} catch (exception) {
  console.error('Error leaving current meeting', exception);
}
```

## Example

An example of usage of this library can be found at [react-native-zoom-us-sdk-example](https://github.com/EslamElMeniawy/react-native-zoom-us-sdk-example).
