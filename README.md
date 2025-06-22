

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
SpeakerRecognitionSystem/
├── SpeakerRecognitionTest.m # Main GUI controller

├── databaseRecorder.m # User registration module

├── SpeakerRecognition.m # Speaker verification module

├── speakerDB.mat # Voice database (created automatically)

├── README.md # This file

└── .gitignore # Git ignore rules


## Technical Details

### Audio Processing Pipeline
1. **Recording**: 16 kHz sampling, 4-second duration
2. **Pre-processing**: Pre-emphasis filtering and normalization
3. **Voice Activity Detection**: Energy-based silence removal
4. **Feature Extraction**: 13 MFCC coefficients with statistical measures
5. **Template Matching**: Combined Euclidean and cosine distance metrics
6. **Decision**: Adaptive threshold with confidence scoring

### MFCC Feature Extraction
- Frame size: 25ms with 10ms overlap
- Mel filter bank: 26 filters
- DCT coefficients: 13 (excluding C0)
- Statistical features: Mean and standard deviation

### Recognition Algorithm
- Distance metrics: Weighted combination of Euclidean and cosine distances
- Threshold: Adaptive based on database statistics  
- Confidence: Relative distance separation between best and second-best matches

## Performance Tuning

### Improving Recognition Accuracy
- Record in quiet environment
- Speak clearly and consistently
- Register multiple samples per user (modify code)
- Adjust threshold parameters in `performRecognition()`

### Troubleshooting
- **"No mfcc function"**: System falls back to manual MFCC implementation
- **Recording issues**: Check microphone permissions and connections
- **Low confidence**: Re-register user or improve recording conditions
- **Database errors**: Delete `speakerDB.mat` and re-register users

## Customization

### Adjustable Parameters
% In both databaseRecorder.m and SpeakerRecognition.m
fs = 16000; % Sampling frequency
duration = 4; % Recording duration (seconds)
numCoeffs = 13; % Number of MFCC coefficients


### Distance Weighting


## Future Enhancements

- Multiple template storage per user
- Real-time continuous recognition
- Gaussian Mixture Model (GMM) implementation
- Deep learning-based features
- Text-dependent recognition
- Noise robustness improvements

## License

MIT License - Feel free to use and modify for educational and research purposes.

## Author

Created for educational purposes. Modify and distribute freely.

## References

- Davis, S. and Mermelstein, P. (1980). "Comparison of parametric representations for monosyllabic word recognition"
- Reynolds, D. A. and Rose, R. C. (1995). "Robust text-independent speaker identification using Gaussian mixture speaker models"











