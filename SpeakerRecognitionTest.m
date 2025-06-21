function SpeakerRecognitionTest()
    % Main GUI function for Speaker Recognition System
    % Creates the main interface with Sign In, Log In, and Exit buttons
    
    fig = figure('Name', 'Speaker Recognition System', ...
                 'NumberTitle', 'off', ...
                 'Position', [500, 300, 400, 300], ...
                 'MenuBar', 'none', ...
                 'Resize', 'off', ...
                 'Color', [0.95 0.95 0.95], ...
                 'CloseRequestFcn', @exit_Callback);

    % Title
    uicontrol('Style', 'text', ...
              'String', 'Speaker Recognition System', ...
              'FontSize', 14, ...
              'FontWeight', 'bold', ...
              'Position', [70, 240, 260, 40], ...
              'BackgroundColor', [0.95 0.95 0.95]);

    % Sign In Button (Registration)
    uicontrol('Style', 'pushbutton', ...
              'String', 'Sign In', ...
              'FontSize', 12, ...
              'Position', [50, 150, 100, 40], ...
              'Callback', @signin_Callback, ...
              'Tooltip', 'Register new speaker');

    % Log In Button (Recognition)
    uicontrol('Style', 'pushbutton', ...
              'String', 'Log In', ...
              'FontSize', 12, ...
              'Position', [160, 150, 100, 40], ...
              'Callback', @login_Callback, ...
              'Tooltip', 'Verify existing speaker');

    % Exit Button
    uicontrol('Style', 'pushbutton', ...
              'String', 'Exit', ...
              'FontSize', 12, ...
              'Position', [270, 150, 100, 40], ...
              'Callback', @exit_Callback, ...
              'Tooltip', 'Close application');

    % Status Display
    uicontrol('Style', 'text', ...
              'String', 'Ready', ...
              'FontSize', 10, ...
              'Position', [50, 100, 300, 30], ...
              'BackgroundColor', [0.95 0.95 0.95], ...
              'Tag', 'StatusText');
end

function signin_Callback(~, ~)
    % Callback for Sign In button - handles user registration
    hFig = gcf;
    statusText = findobj(hFig, 'Tag', 'StatusText');
    
    try
        set(statusText, 'String', 'Starting Registration...', 'ForegroundColor', 'blue');
        drawnow;
        
        % Call registration script
        run('databaseRecorder.m');
        
        set(statusText, 'String', 'Registration Complete!', 'ForegroundColor', 'green');
        pause(2);
        
        % Restart GUI to refresh
        close(hFig);
        SpeakerRecognitionTest();
        
    catch ME
        set(statusText, 'String', 'Registration Failed!', 'ForegroundColor', 'red');
        errordlg(['Sign In Error: ' ME.message], 'Registration Error');
    end
end

function login_Callback(~, ~)
    % Callback for Log In button - handles speaker verification
    hFig = gcf;
    statusText = findobj(hFig, 'Tag', 'StatusText');
    
    try
        set(statusText, 'String', 'Starting Verification...', 'ForegroundColor', 'blue');
        drawnow;
        
        % Call recognition script
        run('SpeakerRecognition.m');
        
        set(statusText, 'String', 'Verification Complete!', 'ForegroundColor', 'green');
        pause(2);
        
        % Restart GUI to refresh
        close(hFig);
        SpeakerRecognitionTest();
        
    catch ME
        set(statusText, 'String', 'Verification Failed!', 'ForegroundColor', 'red');
        errordlg(['Log In Error: ' ME.message], 'Recognition Error');
    end
end

function exit_Callback(~, ~)
    % Clean exit function
    clc;
    close all force;
    clear all;
    disp('Speaker Recognition System closed successfully.');
end
