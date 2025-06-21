% SpeakerRecognition.m
% Records a test voice and tries to identify the speaker from the database

clc; clear; close all;

fs = 16000;
duration = 3;

dbFile = 'speakerDB.mat';
if ~isfile(dbFile)
    errordlg('No speaker database found. Please register first.', 'Database Error');
    return;
end

load(dbFile, 'database');

disp('Get ready to record for verification...');
pause(1);
disp('Recording will start in 2 seconds...');
pause(2);

recObj = audiorecorder(fs, 16, 1);
disp('Recording...');
recordblocking(recObj, duration);
disp('Recording finished.');

audioData = getaudiodata(recObj);

% Feature extraction (MFCC)
testMFCC = mfcc(audioData, fs, 'NumCoeffs', 13);

% Compare with database using Euclidean distance
minDist = inf;
matchedName = '';
for i = 1:length(database)
    dbMFCC = database(i).mfcc;
    % Align lengths for fair comparison
    minLen = min(size(dbMFCC,1), size(testMFCC,1));
    dist = norm(dbMFCC(1:minLen,:) - testMFCC(1:minLen,:),'fro');
    if dist < minDist
        minDist = dist;
        matchedName = database(i).name;
    end
end

% Threshold (tune as needed)
threshold = 80; % You may need to adjust this value

if minDist < threshold
    msgbox(['Speaker identified as: ' matchedName], 'Success');
    disp(['Speaker identified as: ' matchedName]);
else
    msgbox('Speaker not recognized.', 'Failure');
    disp('Speaker not recognized.');
end
