

# Speaker Recognition System

A MATLAB-based speaker recognition system using MFCC (Mel-Frequency Cepstral Coefficients) features and template matching for voice-based user authentication.

## Features

- **User Registration**: Record and store voice templates with MFCC feature extraction
- **Speaker Verification**: Real-time voice authentication against stored templates  
- **GUI Interface**: User-friendly graphical interface for easy interaction
- **Voice Activity Detection**: Automatic silence removal for better recognition
- **Adaptive Thresholding**: Dynamic threshold adjustment based on database statistics
- **Confidence Scoring**: Recognition confidence percentage for reliability assessment

## System Requirements

- MATLAB R2018a or newer (recommended for built-in `mfcc` function)
- Audio System Toolbox (preferred) or Signal Processing Toolbox
- Microphone for audio recording
- Windows/Mac/Linux compatible

## Installation

1. Clone or download this repository
2. Open MATLAB and navigate to the project directory
3. Ensure your microphone is connected and working
4. Run `SpeakerRecognitionTest.m` to start the application

## Usage

### First Time Setup
1. Run `SpeakerRecognitionTest()` in MATLAB
2. Click **"Sign In"** to register new users
3. Enter your name (no spaces or special characters)
4. Follow the recording instructions (speak clearly for 4 seconds)
5. Repeat for all users you want to register

### Voice Verification
1. Click **"Log In"** from the main menu
2. Follow recording instructions when prompted
3. The system will identify the speaker and show confidence level
4. View detailed results if needed

## File Structure

