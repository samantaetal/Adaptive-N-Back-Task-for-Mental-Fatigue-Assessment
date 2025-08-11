function [reaction_time,time_stamp] =  pvt2(run_time)

addpath(genpath('./'))

% Experimental parameters
rand('state',sum(100*clock));
Screen('Preference','SkipSyncTests',1);
bgcolor = [255 255 255]; % set back ground color
textcolor = [0 0 0]; % set font color

% Screen Parameters
[mainwin, screenrect] = Screen(0,'OpenWindow');
Screen('FillRect',mainwin,bgcolor);
center = [screenrect(3)/2,screenrect(4)/2];
Screen(mainwin,'Flip');

% Key Parameters
KbName('UnifyKeyNames');
spaceKey = KbName('space'); escKey = KbName('ESCAPE');

% Parameters and Image initialization
im = imread('Dot.jpg'); %im = imresize(im,0.2);
imDot = Screen('MakeTexture',mainwin,im);
clear im;
im = imread('FixCross.jpg');
im_cross = Screen('MakeTexture',mainwin,im);
clear im;

% Potential locations to place the dot
nrow = 12; ncolumn = 12; cellsize = 50;
for ncells = 1:nrow.*ncolumn
    xnum = (mod(ncells-1, ncolumn)+1)-3.5;
    ynum = ceil(ncells/nrow)-3.5;
    cellcenter(ncells,1) = center(1)+xnum.*cellsize;
    cellcenter(ncells,2) = center(2)+ynum.*cellsize;
end

% Run time of the task (in seconds) <should not be touched>
runtime_duration = run_time*60;

RestrictKeysForKbCheck([spaceKey,escKey]);
ListenChar(2);

%  Experimental instructions
Screen('FillRect',mainwin,bgcolor);
Screen('TextSize',mainwin,40);
Screen('DrawText',mainwin,['If you are ready press "Spacebar" to start or ' ...
    'press "Esc" to leave'],center(1)-550,center(2)-20,textcolor);
Screen('Flip',mainwin);

keyIsDown = 0;
while 1
    [keyIsDown,~,keyCode] = KbCheck;
    if keyIsDown
        if keyCode(spaceKey)
            break;
        elseif keyCode(escKey)
            RestrictKeysForKbCheck;
            ListenChar(1);
            ShowCursor;
            Screen('CloseAll');
            return;
        end
    end
end

% Task instructions
Screen('DrawText',mainwin,'Press Spacebar if you detect a gray dot on the screen',...
    center(1)-450,center(2)-20,textcolor);
Screen('Flip',mainwin);
WaitSecs(1)

% Display of fixation cross
Screen('DrawTexture',mainwin,im_cross);
Screen('Flip',mainwin);
WaitSecs(1.5);

t0 = clock;

for stim = 1:inf
    if etime(clock, t0) < runtime_duration
        time_stamp(stim) = etime(clock, t0);
        cellindex = Shuffle(1:nrow.*ncolumn);
        dotloc = [cellcenter(cellindex(1),1)-cellsize/2, cellcenter(cellindex(1),2)-cellsize/2,...
            cellcenter(cellindex(1),1)+cellsize/2, cellcenter(cellindex(1),2)+cellsize/2];
        Screen('FillRect',mainwin,bgcolor);

        Screen('DrawTexture',mainwin,imDot,[],dotloc);
        Screen('Flip',mainwin);

        timestart = GetSecs; % timer starts to capture response time
        timedout = false;
        while ~timedout
            [ keyIsDown, keyTime, keyCode ] = KbCheck; 
            if keyIsDown
                if keyCode(spaceKey)
                    reaction_time(stim) = GetSecs - timestart;
                    break;
                elseif keyCode(escKey)
                    RestrictKeysForKbCheck;
                    ListenChar(1);
                    ShowCursor;
                    Screen('CloseAll');
                    return;
                end  
            elseif((keyTime - timestart) > 10)
                reaction_time(stim) = nan;
                timedout = true;
            end
        end
        Screen('FillRect',mainwin,bgcolor);
        Screen('Flip',mainwin);
        WaitSecs(randi([1,6]))
    else
        break;
    end
end
pause(0.2)

Screen('DrawText',mainwin,'END',...
    center(1)-1000,center(2)-20,textcolor);
Screen('Flip',mainwin);
WaitSecs(2)

RestrictKeysForKbCheck;
ListenChar(1);
ShowCursor;
Screen('CloseAll');
end