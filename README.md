# React Native zoom.us SDK
Implementation of native Android and iOS zoom.us SDK for React Native.

# :exclamation: :rotating_light: :exclamation: This repository is still under development and not yet ready for use.

## Getting started

### 1. Install native zoom.us SDK
This is an implementation of the native Android and iOS zoom.us SDK so before you start you need to install the native Android and iOS SDK first to your project.

Follow [Zoom Developer Documentation](https://marketplace.zoom.us/docs/guides) to create a developer account and install native Android and iOS SDK in your project.

### 2. Install the library
using either Yarn:

```bash
$ yarn add https://github.com/EslamElMeniawy/react-native-zoom-us-sdk
```

or npm:

```bash
$ npm install --save https://github.com/EslamElMeniawy/react-native-zoom-us-sdk
```

### 3. Link

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
