% SpeakerRecognition.m
% Performs speaker verification by comparing test voice with database templates
% Uses MFCC features and distance-based matching with adaptive thresholding

function SpeakerRecognition()
    clc;
    
    % Audio parameters
    fs = 16000;
    duration = 4;
    numCoeffs = 13;
    
    % Check database
    dbFile = 'speakerDB.mat';
    if ~isfile(dbFile)
        errordlg('No speaker database found. Please register users first.', 'Database Error');
        return;
    end
    
    load(dbFile, 'database');
    
    if isempty(database)
        errordlg('Database is empty. Please register users first.', 'Empty Database');
        return;
    end
    
    fprintf('Found %d registered users in database\n', length(database));
    
    % Recording preparation
    h = msgbox('Prepare for voice verification...', 'Verification');
    pause(2);
    close(h);
    
    for i = 3:-1:1
        h = msgbox(sprintf('Recording starts in %d seconds...', i), 'Countdown');
        pause(1);
        close(h);
    end
    
    try
        % Record test audio
        recObj = audiorecorder(fs, 16, 1);
        h = msgbox('Recording for verification... Speak clearly!', 'Recording');
        recordblocking(recObj, duration);
        close(h);
        
        % Process audio
        testAudio = getaudiodata(recObj);
        testAudio = preProcessAudio(testAudio, fs);
        
        % Extract features
        testFeatures = extractMFCCFeatures(testAudio, fs, numCoeffs);
        
        % Perform recognition
        [recognizedUser, confidence, allDistances] = performRecognition(testFeatures, database);
        
        % Display results
        displayResults(recognizedUser, confidence, allDistances, database);
        
    catch ME
        errordlg(['Recognition Error: ' ME.message], 'Error');
        rethrow(ME);
    end
end

function processedAudio = preProcessAudio(audioData, fs)
    % Same preprocessing as in databaseRecorder
    preEmphasis = [1 -0.97];
    processedAudio = filter(preEmphasis, 1, audioData);
    processedAudio = processedAudio / max(abs(processedAudio));
    
    % Voice Activity Detection
    frameLength = round(0.025 * fs);
    hopLength = round(0.01 * fs);
    
    energy = [];
    for i = 1:hopLength:(length(processedAudio) - frameLength + 1)
        frame = processedAudio(i:i+frameLength-1);
        energy(end+1) = sum(frame.^2);
    end
    
    threshold = 0.01 * max(energy);
    voiceFrames = energy > threshold;
    
    if any(voiceFrames)
        startIdx = find(voiceFrames, 1, 'first') * hopLength;
        endIdx = find(voiceFrames, 1, 'last') * hopLength + frameLength;
        processedAudio = processedAudio(startIdx:min(endIdx, length(processedAudio)));
    end
end

function testFeatures = extractMFCCFeatures(audioData, fs, numCoeffs)
    try
        coeffs = mfcc(audioData, fs, 'NumCoeffs', numCoeffs, ...
                     'WindowLength', round(0.025*fs), ...
                     'OverlapLength', round(0.015*fs));
        
        mfccMean = mean(coeffs, 1);
        mfccStd = std(coeffs, 0, 1);
        testFeatures = [mfccMean, mfccStd];
        
    catch
        testFeatures = extractMFCCManual(audioData, fs, numCoeffs);
    end
end

function testFeatures = extractMFCCManual(audioData, fs, numCoeffs)
    % Manual MFCC implementation (same as in databaseRecorder)
    frameLength = round(0.025 * fs);
    hopLength = round(0.01 * fs);
    nfft = 512;
    
    frames = buffer(audioData, frameLength, frameLength - hopLength);
    numFrames = size(frames, 2);
    
    window = hamming(frameLength);
    frames = frames .* repmat(window, 1, numFrames);
    
    fftFrames = fft(frames, nfft);
    magnitude = abs(fftFrames(1:nfft/2+1, :));
    
    melFilters = melFilterBank(nfft, fs);
    melSpectrum = melFilters * magnitude;
    
    logMelSpectrum = log(melSpectrum + eps);
    mfccCoeffs = dct(logMelSpectrum);
    mfccCoeffs = mfccCoeffs(1:numCoeffs, :);
    
    mfccMean = mean(mfccCoeffs, 2)';
    mfccStd = std(mfccCoeffs, 0, 2)';
    testFeatures = [mfccMean, mfccStd];
end

function melFilters = melFilterBank(nfft, fs)
    numFilters = 26;
    lowFreq = 0;
    highFreq = fs / 2;
    
    lowMel = 2595 * log10(1 + lowFreq / 700);
    highMel = 2595 * log10(1 + highFreq / 700);
    
    melPoints = linspace(lowMel, highMel, numFilters + 2);
    hzPoints = 700 * (10.^(melPoints / 2595) - 1);
    binPoints = floor((nfft + 1) * hzPoints / fs);
    
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

function [recognizedUser, confidence, allDistances] = performRecognition(testFeatures, database)
    numUsers = length(database);
    distances = zeros(numUsers, 1);
    
    % Calculate distances to all users
    for i = 1:numUsers
        dbFeatures = database(i).features;
        
        % Euclidean distance
        euclideanDist = norm(testFeatures - dbFeatures);
        
        % Cosine distance
        cosineDist = 1 - dot(testFeatures, dbFeatures) / (norm(testFeatures) * norm(dbFeatures));
        
        % Combined distance (weighted)
        distances(i) = 0.7 * euclideanDist + 0.3 * cosineDist;
    end
    
    % Find best match
    [minDistance, bestIdx] = min(distances);
    
    % Adaptive threshold based on database statistics
    meanDistance = mean(distances);
    stdDistance = std(distances);
    adaptiveThreshold = meanDistance - 0.5 * stdDistance;
    
    % Confidence calculation
    if numUsers > 1
        sortedDistances = sort(distances);
        confidence = (sortedDistances(2) - sortedDistances(1)) / sortedDistances(2) * 100;
    else
        confidence = max(0, (adaptiveThreshold - minDistance) / adaptiveThreshold * 100);
    end
    
    % Decision
    if minDistance < adaptiveThreshold && confidence > 20
        recognizedUser = database(bestIdx).name;
    else
        recognizedUser = 'Unknown';
        confidence = 0;
    end
    
    allDistances = distances;
end

function displayResults(recognizedUser, confidence, allDistances, database)
    % Create results display
    if strcmp(recognizedUser, 'Unknown')
        message = sprintf('Speaker not recognized.\nNo match found in database.');
        title = 'Recognition Failed';
        icon = 'warn';
    else
        message = sprintf('Speaker identified as: %s\nConfidence: %.1f%%', ...
                         recognizedUser, confidence);
        title = 'Recognition Successful';
        icon = 'none';
    end
    
    % Show detailed results
    detailedResults = sprintf('Recognition Results:\n\n');
    detailedResults = [detailedResults, sprintf('Identified Speaker: %s\n', recognizedUser)];
    detailedResults = [detailedResults, sprintf('Confidence: %.1f%%\n\n', confidence)];
    detailedResults = [detailedResults, 'Distance to all users:\n'];
    
    for i = 1:length(database)
        detailedResults = [detailedResults, sprintf('%s: %.3f\n', ...
                          database(i).name, allDistances(i))];
    end
    
    % Display main result
    msgbox(message, title, icon);
    
    % Display detailed results
    choice = questdlg('Show detailed results?', 'Details', 'Yes', 'No', 'Yes');
    if strcmp(choice, 'Yes')
        msgbox(detailedResults, 'Detailed Results');
    end
    
    % Log results
    fprintf('\n=== Recognition Results ===\n');
    fprintf('Recognized Speaker: %s\n', recognizedUser);
    fprintf('Confidence: %.1f%%\n', confidence);
    fprintf('Distances: ');
    for i = 1:length(allDistances)
        fprintf('%.3f ', allDistances(i));
    end
    fprintf('\n');
end
