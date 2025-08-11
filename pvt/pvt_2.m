function [FatigueScore,MotivationScore,reaction_time,time_stamp,horz_eyeMovement,vert_eyeMovement,pupil_size] =  pvt_2(run_time,mainwin,w,h)


% Inputs ---> run_time -> Time until the PVT will execute in minute (varType = double)

addpath(genpath('./'));

% Initialize output variables
FatigueScore=[];
MotivationScore=[];
reaction_time=[];
time_stamp=[];
horz_eyeMovement=[];
vert_eyeMovement=[];
pupil_size=[];

% Experimental parameters
rand('state',sum(100*clock));
bgcolor = [255 255 255]; % set back ground color
textcolor = [0 0 0]; % set font color

grid = 0:w/10:w; grid(1) = [];

% Parameters and Image initialization
im = imread('Dot.jpg'); im = imresize(im,0.45);
imDot = Screen('MakeTexture',mainwin,im);
clear im;
im = imread('FixCross.jpg');
im_cross = Screen('MakeTexture',mainwin,im);
clear im;
im = imread('MentalFatigue_m.jpg');
im = imresize(im,0.4);
imfatigue = Screen('MakeTexture',mainwin,im);
clear im;
im = imread('Motivation_m.jpg');
im = imresize(im,0.4);
imMotivation = Screen('MakeTexture',mainwin,im);
clear im;

%%%%%%%%%%%%%%%%%%%% Subjective Fatigue and Motivation %%%%%%%%%%%%%%%%%%%%

% Fatigue
Screen('TextSize',mainwin,40);
Screen('DrawTexture',mainwin,imfatigue);
Screen('Flip',mainwin);
clicks = 0;
[clicks,x,~,whichButton,~] = GetClicks([],[],[],GetSecs + 15);
if clicks
    if whichButton == 1 && x < grid(1)
        FatigueScore = 0;
        DrawFormattedText(mainwin, ['You Reported your fatigue level as ', ...
            num2str(FatigueScore)], 'center', 'center', 0, 40);
        Screen('Flip',mainwin);
        WaitSecs(2);
    elseif whichButton == 1 && x > grid(1) && x < grid(2)
        FatigueScore = 1;
        DrawFormattedText(mainwin, ['You Reported your fatigue level as ', ...
            num2str(FatigueScore)], 'center', 'center', 0, 40);
        Screen('Flip',mainwin);
        WaitSecs(2);
    elseif whichButton == 1 && x > grid(2) && x < grid(3)
        FatigueScore = 2;
        DrawFormattedText(mainwin, ['You Reported your fatigue level as ', ...
            num2str(FatigueScore)], 'center', 'center', 0, 40);
        Screen('Flip',mainwin);
        WaitSecs(2);
    elseif whichButton == 1 && x > grid(3) && x < grid(4)
        FatigueScore = 3;
        DrawFormattedText(mainwin, ['You Reported your fatigue level as ', ...
            num2str(FatigueScore)], 'center', 'center', 0, 40);
        Screen('Flip',mainwin);
        WaitSecs(2);
    elseif whichButton == 1 && x > grid(4) && x < grid(5)
        FatigueScore = 4;
        DrawFormattedText(mainwin, ['You Reported your fatigue level as ', ...
            num2str(FatigueScore)], 'center', 'center', 0, 40);
        Screen('Flip',mainwin);
        WaitSecs(2);
    elseif whichButton == 1 && x > grid(5) && x < grid(6)
        FatigueScore = 5;
        DrawFormattedText(mainwin, ['You Reported your fatigue level as ', ...
            num2str(FatigueScore)], 'center', 'center', 0, 40);
        Screen('Flip',mainwin);
        WaitSecs(2);
    elseif whichButton == 1 && x > grid(6) && x < grid(7)
        FatigueScore = 6;
        DrawFormattedText(mainwin, ['You Reported your fatigue level as ', ...
            num2str(FatigueScore)], 'center', 'center', 0, 40);
        Screen('Flip',mainwin);
        WaitSecs(2);
    elseif whichButton == 1 && x > grid(7) && x < grid(8)
        FatigueScore = 7;
        DrawFormattedText(mainwin, ['You Reported your fatigue level as ', ...
            num2str(FatigueScore)], 'center', 'center', 0, 40);
        Screen('Flip',mainwin);
        WaitSecs(2);
    elseif whichButton == 1 && x > grid(8) && x < grid(9)
        FatigueScore = 8;
        DrawFormattedText(mainwin, ['You Reported your fatigue level as ', ...
            num2str(FatigueScore)], 'center', 'center', 0, 40);
        Screen('Flip',mainwin);
        WaitSecs(2);
    elseif whichButton == 1 && x > grid(9)
        FatigueScore = 9;
        DrawFormattedText(mainwin, ['You Reported your fatigue level as ', ...
            num2str(FatigueScore)], 'center', 'center', 0, 40);
        Screen('Flip',mainwin);
        WaitSecs(2);
    elseif whichButton == 3
        ShowCursor;
        Screen('CloseAll');
        return;
    end  
else
    FatigueScore = nan;
    DrawFormattedText(mainwin, 'You have not reported your fatigue score this time',...
        'center', 'center', 0, 40);
    Screen('Flip',mainwin);
    WaitSecs(2);
end

% Motivation
Screen('DrawTexture',mainwin,imMotivation);
Screen('Flip',mainwin);
clicks = 0;
[clicks,x,~,whichButton,~] = GetClicks([],[],[],GetSecs + 15); 
if clicks
    if whichButton == 1 && x < grid(1)
        MotivationScore = 9;
        DrawFormattedText(mainwin, ['You Reported your motivation level as ', ...
            num2str(MotivationScore)], 'center', 'center', 0, 40);
        Screen('Flip',mainwin);
        WaitSecs(2);
    elseif whichButton == 1 && x > grid(1) && x < grid(2)
        MotivationScore = 8;
        DrawFormattedText(mainwin, ['You Reported your motivation level as ', ...
            num2str(MotivationScore)], 'center', 'center', 0, 40);
        Screen('Flip',mainwin);
        WaitSecs(2);
    elseif whichButton == 1 && x > grid(2) && x < grid(3)
        MotivationScore = 7;
        DrawFormattedText(mainwin, ['You Reported your motivation level as ', ...
            num2str(MotivationScore)], 'center', 'center', 0, 40);
        Screen('Flip',mainwin);
        WaitSecs(2);
    elseif whichButton == 1 && x > grid(3) && x < grid(4)
        MotivationScore = 6;
        DrawFormattedText(mainwin, ['You Reported your motivation level as ', ...
            num2str(MotivationScore)], 'center', 'center', 0, 40);
        Screen('Flip',mainwin);
        WaitSecs(2);
    elseif whichButton == 1 && x > grid(4) && x < grid(5)
        MotivationScore = 5;
        DrawFormattedText(mainwin, ['You Reported your motivation level as ', ...
            num2str(MotivationScore)], 'center', 'center', 0, 40);
        Screen('Flip',mainwin);
        WaitSecs(2);
    elseif whichButton == 1 && x > grid(5) && x < grid(6)
        MotivationScore = 4;
        DrawFormattedText(mainwin, ['You Reported your motivation level as ', ...
            num2str(MotivationScore)], 'center', 'center', 0, 40);
        Screen('Flip',mainwin);
        WaitSecs(2);
    elseif whichButton == 1 && x > grid(6) && x < grid(7)
        MotivationScore = 3;
        DrawFormattedText(mainwin, ['You Reported your motivation level as ', ...
            num2str(MotivationScore)], 'center', 'center', 0, 40);
        Screen('Flip',mainwin);
        WaitSecs(2);
    elseif whichButton == 1 && x > grid(7) && x < grid(8)
        MotivationScore = 2;
        DrawFormattedText(mainwin, ['You Reported your motivation level as ', ...
            num2str(MotivationScore)], 'center', 'center', 0, 40);
        Screen('Flip',mainwin);
        WaitSecs(2);
    elseif whichButton == 1 && x > grid(8) && x < grid(9)
        MotivationScore = 1;
        DrawFormattedText(mainwin, ['You Reported your motivation level as ', ...
            num2str(MotivationScore)], 'center', 'center', 0, 40);
        Screen('Flip',mainwin);
        WaitSecs(2);
    elseif whichButton == 1 && x > grid(9)
        MotivationScore = 0;
        DrawFormattedText(mainwin, ['You Reported your motivation level as ', ...
            num2str(MotivationScore)], 'center', 'center', 0, 40);
        Screen('Flip',mainwin);
        WaitSecs(2);
    elseif whichButton == 3
        ShowCursor;
        Screen('CloseAll');
        return;
    end  
else
    MotivationScore = nan;
    DrawFormattedText(mainwin, 'You have not reported your motivation score this time',...
        'center', 'center', 0, 40);
    Screen('Flip',mainwin);
    WaitSecs(2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PVT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Potential locations to place the dot
nrow = 12; ncolumn = 12; cellsize = 50;
for ncells = 1:nrow.*ncolumn
    xnum = (mod(ncells-1, ncolumn)+1)-3.5;
    ynum = ceil(ncells/nrow)-3.5;
    cellcenter(ncells,1) = (w/2)+xnum.*cellsize;
    cellcenter(ncells,2) = (h/2)+ynum.*cellsize;
end

% Run time of the task (in seconds) <should not be touched>
runtime_duration = run_time*60;

% Experimental instructions
Screen('TextSize',mainwin,50);
Screen('FillRect',mainwin,bgcolor);
DrawFormattedText(mainwin, ['If you are ready press "Left Click Button of the Mouse" to start or ' ...
    'press "Scroll Button" to leave'],'center', 'center', 0, 80);
Screen('Flip',mainwin);

[~,~,~,whichButton,~] = GetClicks;
if whichButton == 2
    ShowCursor;
    Screen('CloseAll');
    return;
end

% Task instructions
DrawFormattedText(mainwin,'Press Left Click Button if you detect a gray dot on the screen',...
    'center', 'center', 0, 80);
Screen('Flip',mainwin);
WaitSecs(1);

% Display of fixation cross
Screen('DrawTexture',mainwin,im_cross);
Screen('Flip',mainwin);
WaitSecs(1.5);

stim = 1;
StartingTime = GetSecs;

while GetSecs - StartingTime < runtime_duration

    time_stamp(stim) = GetSecs;
    cellindex = Shuffle(1:nrow.*ncolumn);
    dotloc = [cellcenter(cellindex(1),1)-cellsize/2, cellcenter(cellindex(1),2)-cellsize/2,...
            cellcenter(cellindex(1),1)+cellsize/2, cellcenter(cellindex(1),2)+cellsize/2];
    Screen('FillRect',mainwin,bgcolor);

    Screen('DrawTexture',mainwin,imDot,[],dotloc);
    Screen('Flip',mainwin);

    timestart = GetSecs; % timer starts to capture response time
    [clicks,~,~,whichButton,~] = GetClicks([],0,[],GetSecs + 5);
    if clicks
        if whichButton == 1
            reaction_time(stim) = GetSecs - timestart;
        elseif whichButton == 2
            ShowCursor;
            Screen('CloseAll');
            return;
        end  
    else
        reaction_time(stim) = nan;
    end

    stim = stim + 1;
    Screen('FillRect',mainwin,bgcolor);
    Screen('Flip',mainwin);
    t = randi([1,6]);
    WaitSecs(t);
end

pause(0.2);
Screen('TextSize',mainwin,70);
DrawFormattedText(mainwin, 'End of PVT', 'center', 'center', 0, 40);
Screen('Flip',mainwin);
WaitSecs(2);