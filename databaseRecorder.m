% databaseRecorder.m
% Records new speaker voice samples and extracts MFCC features for database storage
% Uses windowing and pre-emphasis for better feature extraction

function databaseRecorder()
    clc;
    
    % Audio recording parameters
    fs = 16000;           % Sampling frequency (16 kHz)
    duration = 4;         % Recording duration in seconds
    numCoeffs = 13;       % Number of MFCC coefficients
    
    % Get user information
    prompt = {'Enter your name (no spaces or special characters):'};
    dlgtitle = 'User Registration';
    dims = [1 50];
    definput = {''};
    answer = inputdlg(prompt, dlgtitle, dims, definput);
    
    if isempty(answer) || isempty(answer{1})
        errordlg('Registration cancelled. No username provided.', 'Error');
        return;
    end
    
    username = answer{1};
    
    % Validate username
    if ~isvarname(username)
        errordlg('Username must be a valid MATLAB variable name (no spaces, start with letter)', 'Invalid Username');
        return;
    end
    
    % Recording countdown
    h = msgbox('Get ready to speak clearly for 4 seconds...', 'Preparation');
    pause(2);
    close(h);
    
    for i = 3:-1:1
        h = msgbox(sprintf('Recording starts in %d seconds...', i), 'Countdown');
        pause(1);
        close(h);
    end
    
    try
        % Record audio
        recObj = audiorecorder(fs, 16, 1);
        h = msgbox('Recording in progress... Speak clearly!', 'Recording');
        recordblocking(recObj, duration);
        close(h);
        
        % Get audio data
        audioData = getaudiodata(recObj);
        
        % Pre-processing
        audioData = preProcessAudio(audioData, fs);
        
        % Extract MFCC features
        mfccFeatures = extractMFCCFeatures(audioData, fs, numCoeffs);
        
        % Save to database
        saveToDatabase(username, mfccFeatures);
        
        msgbox(sprintf('Registration successful for user: %s', username), 'Success');
        
    catch ME
        errordlg(['Recording Error: ' ME.message], 'Error');
        rethrow(ME);
    end
end

function processedAudio = preProcessAudio(audioData, fs)
    % Pre-emphasis filter to balance frequency spectrum
    preEmphasis = [1 -0.97];
    processedAudio = filter(preEmphasis, 1, audioData);
    
    % Normalize audio
    processedAudio = processedAudio / max(abs(processedAudio));
    
    % Remove silence (simple energy-based VAD)
    frameLength = round(0.025 * fs); % 25ms frames
    hopLength = round(0.01 * fs);    % 10ms hop
    
    energy = [];
    for i = 1:hopLength:(length(processedAudio) - frameLength + 1)
        frame = processedAudio(i:i+frameLength-1);
        energy(end+1) = sum(frame.^2);
    end
    
    % Threshold-based voice activity detection
    threshold = 0.01 * max(energy);
    voiceFrames = energy > threshold;
    
    if any(voiceFrames)
        startIdx = find(voiceFrames, 1, 'first') * hopLength;
        endIdx = find(voiceFrames, 1, 'last') * hopLength + frameLength;
        processedAudio = processedAudio(startIdx:min(endIdx, length(processedAudio)));
    end
end

function mfccFeatures = extractMFCCFeatures(audioData, fs, numCoeffs)
    try
        % Extract MFCC using MATLAB's built-in function
        coeffs = mfcc(audioData, fs, 'NumCoeffs', numCoeffs, ...
                     'WindowLength', round(0.025*fs), ...
                     'OverlapLength', round(0.015*fs));
        
        % Statistical features: mean and standard deviation
        mfccMean = mean(coeffs, 1);
        mfccStd = std(coeffs, 0, 1);
        
        % Combine features
        mfccFeatures = [mfccMean, mfccStd];
        
    catch
        % Fallback for older MATLAB versions without mfcc function
        mfccFeatures = extractMFCCManual(audioData, fs, numCoeffs);
    end
end

function mfccFeatures = extractMFCCManual(audioData, fs, numCoeffs)
    % Manual MFCC implementation for compatibility
    frameLength = round(0.025 * fs);
    hopLength = round(0.01 * fs);
    nfft = 512;
    
    % Frame the signal
    frames = buffer(audioData, frameLength, frameLength - hopLength);
    numFrames = size(frames, 2);
    
    % Apply Hamming window
    window = hamming(frameLength);
    frames = frames .* repmat(window, 1, numFrames);
    
    % FFT
    fftFrames = fft(frames, nfft);
    magnitude = abs(fftFrames(1:nfft/2+1, :));
    
    % Mel filter bank
    melFilters = melFilterBank(nfft, fs);
    melSpectrum = melFilters * magnitude;
    
    % Log and DCT
    logMelSpectrum = log(melSpectrum + eps);
    mfccCoeffs = dct(logMelSpectrum);
    mfccCoeffs = mfccCoeffs(1:numCoeffs, :);
    
    % Statistical features
    mfccMean = mean(mfccCoeffs, 2)';
    mfccStd = std(mfccCoeffs, 0, 2)';
    mfccFeatures = [mfccMean, mfccStd];
end

function melFilters = melFilterBank(nfft, fs)
    % Create Mel filter bank
    numFilters = 26;
    lowFreq = 0;
    highFreq = fs / 2;
    
    % Convert to Mel scale
    lowMel = 2595 * log10(1 + lowFreq / 700);
    highMel = 2595 * log10(1 + highFreq / 700);
    
    % Equally spaced in Mel scale
    melPoints = linspace(lowMel, highMel, numFilters + 2);
    
    % Convert back to Hz
    hzPoints = 700 * (10.^(melPoints / 2595) - 1);
    
    % Convert to FFT bin numbers
    binPoints = floor((nfft + 1) * hzPoints / fs);
    
    % Create filter bank
    melFilters = zeros(numFilters, nfft/2 + 1);
    for i = 1:numFilters
        for j = binPoints(i):binPoints(i+1)
            melFilters(i, j+1) = (j - binPoints(i)) / (binPoints(i+1) - binPoints(i));
        end
        for j = binPoints(i+1):binPoints(i+2)
            melFilters(i, j+1) = (binPoints(i+2) - j) / (binPoints(i+2) - binPoints(i+1));
        end
    end
end

function saveToDatabase(username, mfccFeatures)
    dbFile = 'speakerDB.mat';
    
    if isfile(dbFile)
        load(dbFile, 'database');
    else
        database = struct('name', {}, 'features', {}, 'timestamp', {});
    end
    
    % Check if user already exists
    existingIdx = find(strcmp({database.name}, username), 1);
    
    if ~isempty(existingIdx)
        % Update existing user
        database(existingIdx).features = mfccFeatures;
        database(existingIdx).timestamp = datestr(now);
        fprintf('Updated existing user: %s\n', username);
    else
        % Add new user
        newIdx = length(database) + 1;
        database(newIdx).name = username;
        database(newIdx).features = mfccFeatures;
        database(newIdx).timestamp = datestr(now);
        fprintf('Added new user: %s\n', username);
    end
    
    save(dbFile, 'database');
    fprintf('Database saved with %d users\n', length(database));
end
