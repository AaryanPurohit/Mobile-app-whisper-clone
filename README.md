# Whisper Clone Mobile

A minimal iOS voice dictation app. Tap the button to record, tap again to transcribe via OpenAI Whisper, and the result is automatically copied to your clipboard.

## Setup

1. Clone this repo
2. Install XcodeGen: `brew install xcodegen`
3. `cd iOS && xcodegen generate`
4. Open `WhisperMobile.xcodeproj` in Xcode
5. Set your Team in Signing & Capabilities
6. Run on your device

## Usage

1. Open the app and enter your OpenAI API key in Settings
2. Tap the mic button to start recording
3. Tap again to stop — the transcribed text is copied to clipboard automatically
