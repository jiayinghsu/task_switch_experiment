%% Shepard Letter Rotation Task
%% SDM, September 13th 2016, Princeton, NJ
%% *Amended, Feb. 20th 2017

clear; close all; clc;
addpath Data
%savdir = '/Users/jonathantsay/Dropbox/VICE/JT/TASK_SWITCH/';
savdir = '/Users/arohisaxena/Dropbox/VICE/JT/TASK_SWITCH/';
%savdir = '/Users/newxjy/Dropbox/VICE/JT/TASK_SWITCH/';
cd([savdir, 'TargetFiles']);

try
    
    %% Enter subject's name in command window
    subject_info = input('Enter Subject Key:', 's');
    subject_info = strcat(subject_info);
    while exist(strcat('TS_', subject_info,'.csv'),'file')
        subject_info = input('Subject Key Already Used. Enter New Subject Key:', 's');
        subject_info = strcat(subject_info);
    end
    
    %% Trial Protocol
    % Make subject-specific trial file using "make_trials" script
    make_trials_TS(subject_info, savdir);
    filename = strcat('TS_', subject_info,'.csv'); % load subject-specific protocol
    T = readtable(filename);
    
    %% get length of session
    numTrials = max(T.trial_num);
    
    % sync bug
    %PsychDebugWindowConfiguration
    Screen('Preference', 'SkipSyncTests', 1);
    
    %% create screen
    which_screen = 0; % get primary monitor
    bg_color = [0, 0, 0]; % background black
    [window, screen_dimensions] = Screen(which_screen,'OpenWindow', bg_color);
    HideCursor; % hide mouse cursor
    
    % get screen resolution, size, etc
    screenInfo = Screen('Resolution',0);
    screenWidth = screenInfo.width/2; % NEED TO DIVIDE BY 2 FOR SOME REASON ON MY LAPTOP. width in pix
    screenHeight = screenInfo.height/2; % DITTO. height in pix
    %     screenWidth = 2560/2;
    %     screenHeight = 1600/2;
    screenPixelSize = screenInfo.pixelSize; % pixel size in mm/10
    [width_mm, height_mm]=Screen('DisplaySize',which_screen); % get screen dimen. in mm
    pix_per_mm = screenWidth/width_mm; % conversion ratio? not for all monitors...should be validated and should be same as "screenPixelSize"
    
    %% font
    Screen('TextFont',window,'Arial');
    Screen('TextStyle',window,1);
    Screen('TextSize', window, 100);
    %% TASK VARIABLES
    % start area variables
    start_x = screenWidth/2; % middle of screen
    start_y = screenHeight/2; % lower portion of screen
    
    % letter placement
    letter_shift = 200;
    
    % colors
    green = [0,220,20];     % define green color
    white = [255,255,255]; % define white
    red = [255,0,0];       % define red color
    blue = [0,80,255];   % blue
    
    % wait times
    target_wait = 2; % 2s wait between trials
    RT_limit = 5; % max RT
    feedback_time = 1; % seconds for fb
    
    %% DATA INTITIALIZATION
    % init simple data struct
    data = struct('rt',nan(numTrials,1),'trans',nan(numTrials,1),...
        'trial_type',nan(numTrials,1), 'number',nan(numTrials,1), 'letter',repmat('A', [numTrials,1]), 'choice',nan(numTrials,1),'correct',nan(numTrials,1),...
        'too_slow',nan(numTrials,1),'trial_start',nan(numTrials,1),'stim_appear',nan(numTrials,1),'experiment_time',nan(numTrials,1));
    
    %% init events
    e_hold = 1;
    e_show_letter = 0;
    e_feedback = 0;
    e_fbwait = 0;
    e_data = 0;
    choice = 0;
    e_too_slow = 0;
    y_space = 150;
    x_len = 150;
    x_shift = 30;
    
    %% Keyboard Stuff
    [kbs_idx, kbs_names] = GetKeyboardIndices; % get indices + names of keyboards
    keypress_device_idx = kbs_idx(cellfun(@(x) ~isempty(x), strfind(kbs_names, 'Apple Internal Keyboard'))); % get keyboard, try 'USB' for comp
    
    KbQueueCreate(keypress_device_idx); % init queue for pulse
    
    %% --- INITIALIZE TRIAL LOOP --- %%
    count = 1;
    trialnum = 1; % init trial count
    hold_start_t = GetSecs(); % init first time out counter
    
    %% ------------------ %%%% MAIN LOOP %%%% ------------------ %%
    
    while trialnum <= numTrials % make what you want for testing, insert "num_Trials" when running
        
        %% FIND START %%
        if e_hold == 1 % subject is locating start position
            
            %% fixation cross during ITI
            
            Screen('DrawLine',window, white, start_x-x_len, start_y + y_space,start_x+x_len,start_y + y_space,4);
            Screen('DrawLine',window, white, start_x-x_len, start_y, start_x + x_len, start_y,4);
            Screen('DrawLine',window, white, start_x-x_len, start_y - y_space,start_x+x_len,start_y - y_space,4);
            Screen('Flip', window, [], 1);
            
            % time for stimulus?
            time_holding = GetSecs;
            if time_holding-hold_start_t > target_wait
                e_hold = 0;
                e_show_letter = 1;
                %% show letter!
                
                Screen('DrawLine',window, white, start_x-x_len, start_y + y_space,start_x+x_len, start_y + y_space,4);
                Screen('DrawLine',window, white, start_x-x_len, start_y, start_x + x_len,start_y,4);
                Screen('DrawLine',window, white, start_x-x_len, start_y - y_space,start_x+x_len, start_y - y_space,4);
                
                T.trial_type(trialnum)
                switch T.trial_type(trialnum)
                    case 1
                        Screen('DrawText', window, num2str(T.number(trialnum)), start_x - x_shift - 40, start_y - 250, white);
                        Screen('DrawText', window, T.letter{trialnum}, start_x + x_shift - 40, start_y - 250, white);
                    case 2
                        Screen('DrawText', window, num2str(T.number(trialnum)), start_x-x_shift - 40, start_y - 100, white);
                        Screen('DrawText', window, T.letter{trialnum}, start_x+x_shift - 40, start_y - 100, white);
                    case 3
                        Screen('DrawText', window, num2str(T.number(trialnum)), start_x- x_shift - 40, start_y + 50, white);
                        Screen('DrawText', window, T.letter{trialnum}, start_x+ x_shift - 40, start_y + 50, white);
                end
                
                % flip
                Screen('Flip', window, [], 1);
                % make KB queue
                KbQueueStart(keypress_device_idx); % begin queue
                KbQueueFlush(keypress_device_idx); % flush queue
                % start RT clock!
                rt_start_t = GetSecs();
            end
        end
        
        %% HOLD %%
        if e_show_letter == 1 % now they're holding start
            
            rt_clock = GetSecs();
            
            %% --- key triggering --- %%
            [pressed, firstPress, firstRelease, lastPress, lastRelease] = KbQueueCheck(keypress_device_idx);
            
            if pressed && (firstPress(79) > 0 || firstPress(80) > 0) % BUTTON WAS PRESSED, AND IT'S ONE OF THE ARROWS
                RT = rt_clock - rt_start_t;
                
                if firstPress(79) > 0 % right key pressed
                    choice = 0;
                elseif firstPress(80) > 0 % left key pressed
                    choice = 1; % normal
                end
                e_show_letter = 0;
                e_feedback = 1;
            end
            
        end
        
        if e_feedback == 1
            
            %% TRIAL OUTCOMES %%
            if RT > RT_limit
                e_too_slow = 1;
                correct = 99;
                Screen('DrawText', window, 'TOO SLOW!', start_x-250,start_y+300,red);
            elseif choice == T.correct(trialnum) %% choice (1/odd,2/even) matches mirror figures (normal/odd,mirror/mirror)
                Screen('DrawText', window, 'CORRECT', start_x-250,start_y+300, green);
                correct = 1;
            else
                Screen('DrawText', window, 'INCORRECT', start_x-250,start_y+300,red);
                correct = 0;
            end
            Screen('Flip', window);
            
            fb_start = GetSecs();
            e_feedback = 0;
            e_fbwait = 1;
        end
        
        %% FB PERIOD %%
        if e_fbwait == 1
            
            fb_hold = GetSecs;
            if fb_hold-fb_start > feedback_time
                e_fbwait = 0;
                e_data = 1;
            end
        end
        
        %% Trial completed successfully -- log 'quick' data %%
        if e_data == 1
            % RT
            data.rt(trialnum) = RT;
            % transition type
            data.trans(trialnum) = T.trans(trialnum);
            % transition type
            data.trial_type(trialnum) = T.trial_type(trialnum);
            % rotation stuff
            data.number(trialnum) = T.number(trialnum);
            % stim
            data.letter(trialnum) = T.letter{trialnum};
            % choice
            data.choice(trialnum) = choice;
            % correct?
            data.correct(trialnum) = correct;
            % too slow?
            data.too_slow(trialnum) = e_too_slow;
            % start trial time
            data.trial_start(trialnum) = hold_start_t;
            % stim presentation
            data.stim_appear(trialnum) = rt_start_t;
            % experiment time
            data.experiment_time(trialnum) = GetSecs;
            
            %% SAVE %%
            
            cd([savdir, 'Data'])
            save(fullfile([savdir, 'Data'],subject_info),'data');
            writetable(  struct2table(data), [subject_info, 'data.csv'] );
            
            % RE-INIT
            trialnum = trialnum + 1; % iterate trial number
            e_hold = 1; % time to start again
            hold_start_t = GetSecs();
            e_data = 0;
            KbQueueStop(keypress_device_idx);
            KbQueueFlush(keypress_device_idx);
        end
        
    end
    
    %% end messege %%
    Screen('DrawText', window, 'Great Job, Thanks!', start_x-250,start_y,green);
    Screen('Flip',window, [], 1);
    WaitSecs(3);
    clear Screen;
    ShowCursor;
    
catch err
    clear Screen;
    Screen('CloseAll');
    ShowCursor;
    disp(err);
end



