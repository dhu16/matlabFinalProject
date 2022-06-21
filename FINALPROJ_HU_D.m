try
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; close all;   % clear variables and close windows
AssertOpenGL;       % make sure we have OpenGL which we need for displaying 
                    % stimuli; most computers come with it now
KbName('UnifyKeyNames'); % Ensure PTB recognizes keys on all OSs
Screen('Preference', 'SkipSyncTests', 1); % Skip sync tests, so we're not 
% forced out if the test fails

rng shuffle; % shuffle the random number generator seed


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DEFINE PARAMETERS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

WHITE = [255 255 255];
BLACK = [0 0 0];
GREY = [150 150 150];
LGREEN = [100 255 100];
HIGH_TONE = 2000;
MEDIUM_TONE = 150;
LOW_TONE = 80;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% EXPERIMENT DESIGN SET UP %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%IV 1 - Recall cue: particular row (top, med, bot)
%IV 2 - Distractor task: immediate, pictures, 3s delay
%DV: # of correctly-recalled letters, average reaction time

distractor_levels = {'immediate', 'pictures', '3 sec delay'};

nDistLvls = length(distractor_levels);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CREATE STIMULI %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%Import file with letters
letters = importdata('Letters.txt'); 
numLetters = length(letters);


%%Condition order and randomizing it
numTrials = 9;

conditions = zeros(9,1);

A = ones(1,3);
B = repmat(2,1,3);
C = repmat(3,1,3);
nine = [A B C]';

order = randperm(9);
dud = nine;

for j=1:numTrials
    index = find(order==j);
    nine(j) = dud(index);
    conditions(j) = nine(j);
end

fprintf("Conditions\n");
disp(conditions);
fprintf("\n");


%%Get and load images
d = dir('edited_images/*.jpg');
numImages = size(d,1); %# of images
imgs = cell(numImages, 1); %create empty array of appropriate size to hold images

for i=1:numImages %read contents into array
    imgs{i} = double(imread(['edited_images/' d(i).name]));
end

%%Create folder to store subject files
mkdir('subject_data');
addpath('subject_data');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RANDOMIZE PRESENTATION ORDER %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
letterLists{numTrials} = []; %empty array

for i = 1:numTrials
    order = randperm(numLetters); %random order of letters
    letterLists{i}=letters(order(1:12)); %store new random presentation order into array
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% COLLECT SUBJECT INFO %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

NO_GET_INFO = true; %condition

while NO_GET_INFO %while file has not been created yet
    
    prompt = {'Name:','Age:','Gender:'}; %these are the fields that are filled in
    graphTitle = '% of Bounced-Off Responses by Conditions'; %title of graph figure
    numLines = 1; %how many lines each field has

    defaultAns = {'','',''}; 

    subjInput = inputdlg(prompt,graphTitle,numLines,defaultAns);

    res.subjInfo.name = subjInput{1};
    res.subjInfo.Age = str2double(subjInput{2});
    res.subjInfo.Gender = subjInput{3};

    res.response = cell(20,1);
    res.correct = 0;
    res.incorrect = 0;
    res.rt1 = 0;
    res.rt2 = 0;
    res.rt3 = 0;
    res.con1 = 0;
    res.con2 = 0;
    res.con3 = 0;
    res.avgrt1 = 0;
    res.avgrt2 = 0;
    res.avgrt3 = 0;
    res.totalResp = 0;
    
    savename = ['subject_data/finalProj_' res.subjInfo.name '.mat']; %name subject info file

    if exist(savename,'file') %give choice to overwrite file if it already exists

        overwrite = input('A file already exists with that name. Do you want to overwrite? y/n  ','s');
        

        if strcmpi(overwrite,'y') %overwrite

            NO_GET_INFO = false;
        end
        
        
    else %if doesn't exist then create
        NO_GET_INFO = false;
    end
    
    save(savename,'res');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SET UP SCREEN %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

scrnNum = max(Screen('Screens')); %get the screen number

[win, rect] = Screen('OpenWindow',scrnNum,GREY); %fullscreen mode

%get properties of the screen window
[cx, cy] = RectCenter(rect); %central x and y locations
[width, height] = RectSize(rect); %width and height of the opened window

Screen('TextSize', win,65); %set font size to 65
Screen('TextStyle',win,1); %bold

 
Screen('Flip',win); %show screen



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% TASK INSTRUCTIONS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

instructions = ['You will be presented with a set of letters that you have to recall.\n'...
'A particular tone will determine which letters you must recall.\n'...
'High-pitched tone = recall top row only\n'...
'Medium-pitched tone = recall middle row only\n'...
'Low-pitched tone = recall bottom row only\n'...
' \n'...
'Press any key to continue.'];

DrawFormattedText(win, instructions,'center','center',BLACK,[], [], [], 2);
Screen('Flip',win);
KbWait; %wait for a keypress


highText = 'This is an example of a high-pitch tone. Press any key to continue.';
medText = 'This is an example of a medium-pitch tone. Press any key to continue.';
lowText = 'This is an example of a low-pitch tone. Press any key to continue.';
tones = [HIGH_TONE, MEDIUM_TONE, LOW_TONE];
readyToStart = 'You have just listened to each of the sounds. Press any key to begin the experiment.';


%%Play sounds for subjects to hear and then wait for them to start
demo = 1;

while demo
    for i = 1:3 %loop for each of 3 sounds
        
        if i == 1 %set current text
            currText = highText;
        elseif i == 2
            currText = medText;
        elseif i == 3
            currText = lowText;
        end

        currTone = tones(i); %get tone
        
        DrawFormattedText(win, currText,'center','center',BLACK,[], [], [], 2);
        Screen('Flip',win); 
        KbWait;
        Beeper(currTone,.5,.2);
        WaitSecs(1); %space out instruction timing a bit
    end
    
    DrawFormattedText(win, readyToStart,'center','center',BLACK,[], [], [], 2);
    Screen('Flip',win);
    KbWait;
    demo = 0;
    WaitSecs(.5);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DISPLAY THE STIMULI %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

WaitSecs(1);

for i=1:numTrials %%SET TO NUM TRIALS <--------
    
    %%Setting up letters to be displayed2
    Screen('TextSize', win, 65);
    
    bigLetters = upper(letterLists{i}); %convert letters to capital case
    rows=['';'';'']; %empty character array for display of letters
    
    for r = 1:3
        index = 4*r; %use to access 4 elements at a time and move forward in clusters
        row = bigLetters(index-3:index)'; %retrieve 4 elements from letter list for each row and make array horizontal to match rows array
        rows(r,:) = [row{1} '   ' row{2} '   ' row{3} '   ' row{4}]; %each row has 4 letters separated by spaces
    end
    
    
    %%Get current distractor condition
    currDistract = conditions(i);
  
    
    %Display rows of letters
    DrawFormattedText(win, rows(1,:),'center',cy-200,BLACK);
    DrawFormattedText(win, rows(2,:),'center',cy,BLACK);
    DrawFormattedText(win, rows(3,:),'center',cy+200,BLACK);
    
    Screen('Flip',win);
    
    WaitSecs(2);
    
    
    %%Play random tone to cue which row to recall
    randTone = randi(3);
    
    if randTone == 1
        tone = HIGH_TONE;
    elseif randTone == 2
        tone = MEDIUM_TONE;
    elseif randTone == 3
        tone = LOW_TONE;
    end
    
    
    %%Use current distractor condition to determine which distractor to use
    if currDistract == 1 %immediately play tone   
        Screen('Flip',win);
        Beeper(tone,.5,.2);
    elseif currDistract == 2 %show pictures
        Screen('Flip',win);
        for t=1:numImages %display images
            img = imgs{t};
            Screen('PutImage',win,img);
            Screen('Flip',win);
            WaitSecs(1.5);
        end
        Beeper(tone,.5,.2);
    elseif currDistract == 3 %3 sec delay
        Screen('Flip',win);
        WaitSecs(3);
        Beeper(tone,.5,.2);
    end
    
    WaitSecs(0.5);
    
    %%Ask which row they had to remember (1, 2, or 3), present rows
    %%horizontally as answer choices, and record response and RT
    
    inst = 'Which row did you have to recall? Press 1, 2, or 3 to select your row choice.';
    
    Screen('TextSize', win, 40);
    
    DrawFormattedText(win, inst,'center',cy+500,BLACK);
    
    DrawFormattedText(win, rows(1,:),cx+(cx/2),cy,BLACK);
    DrawFormattedText(win, rows(2,:),cx/2,cy,BLACK);
    DrawFormattedText(win, rows(3,:),'center',cy,BLACK);
    
    Screen('Flip',win); 
    
    %%Waiting for keypress
    notPressed = 1;
    
    choice = 0; %to store answer choice
    
    while notPressed
        [secs, keyCode, deltaSecs] = KbWait; %wait for keypress
        key = KbName(keyCode);
        RT = secs - GetSecs; %get reaction time
        
        if any(strcmpi(key,'1!'))           
            notPressed = 0;
            choice = 1;
        end
        
        if any(strcmpi(key,'2@'))
            notPressed = 0;
            choice = 2;
        end
        
        if any(strcmpi(key,'3#'))
            notPressed = 0;
            choice = 3;
        end 
    end
    
    
    %%Save reaction time for each condition
    if currDistract == 1 %immediately play tone
        res.rt1 = res.rt1 + RT;
    elseif currDistract == 2 %show pictures
        res.rt2 = res.rt2 + RT;
    elseif currDistract == 3 %1 sec delay
        res.rt3 = res.rt3 + RT;
    end

    
    %%Store response as part of subject info and save
    res.response{i} = choice;
    res.totalResp = res.totalResp + 1;
    
    if choice == randTone %if choice matches tone
        res.correct = res.correct + 1; %correct
        
        if currDistract == 1 
            res.con1 = res.con1 + 1;
        elseif currDistract == 2 
            res.con2 = res.con2 + 1;
        elseif currDistract == 3 
            res.con3 = res.con3 + 1;
        end
        
    else
        res.incorrect = res.incorrect + 1; %incorrect
    end
    
    save(savename,'res');
    
    
end

%%Get average reaction times for each 3 conditions
res.avgrt1 = res.rt1/3;
res.avgrt2 = res.rt2/3;
res.avgrt3 = res.rt3/3;

save(savename,'res');


%%Display shape and thank you message
circleRect = [cx-200 cy-200 cx+200 cy+200];
Screen('FillOval', win, LGREEN, circleRect, 10);

thanks = 'Thank you for participating in this experiment!';

DrawFormattedText(win, thanks,'center',cy-400,BLACK);
Screen('Flip', win);
WaitSecs(3);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CLEANUP %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% close the window
ShowCursor;
Screen('Close',win);

catch
    ShowCursor;
    Screen('CloseAll');
    psychrethrow(psychlasterror);
end