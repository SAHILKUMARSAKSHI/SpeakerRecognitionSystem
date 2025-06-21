% databaseRecorder.m
% Records a new speaker's voice and saves MFCC features to a database

clc; clear; close all;

fs = 16000;         % Sampling frequency
duration = 3;       % Recording duration in seconds

prompt = 'Enter your name (no spaces): ';
username = input(prompt, 's');
if isempty(username)
    error('No username entered.');
end

disp('Get ready to record...');
pause(1);
disp('Recording will start in 2 seconds...');
pause(2);

recObj = audiorecorder(fs, 16, 1);
disp('Recording...');
recordblocking(recObj, duration);
disp('Recording finished.');

audioData = getaudiodata(recObj);

% Feature extraction (MFCC)
coeffs = mfcc(audioData, fs, 'NumCoeffs', 13);

% Save to database (append or create)
dbFile = 'speakerDB.mat';
if isfile(dbFile)
    load(dbFile, 'database');
else
    database = struct('name', {}, 'mfcc', {});
end

% Check if user already exists
idx = find(strcmp({database.name}, username), 1);
if ~isempty(idx)
    database(idx).mfcc = coeffs;
    disp('User updated in database.');
else
    database(end+1).name = username;
    database(end).mfcc = coeffs;
    disp('User added to database.');
end

save(dbFile, 'database');
msgbox('Registration complete!', 'Success');
