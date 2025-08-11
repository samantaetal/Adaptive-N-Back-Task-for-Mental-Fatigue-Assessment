function [reaction_time,N,sequence,ground_truth,Acc,FatigueScore,MotivationScore] = nBack(run_time)

addpath(genpath('./'))

reaction_time=[];
sequence=[];
N=[];
ground_truth=[];
Acc=[];
FatigueScore=[];
MotivationScore=[];

% Experimental parameters
rand('state',sum(100*clock));
Screen('Preference','SkipSyncTests',1);

KbName('UnifyKeyNames');
spaceKey = KbName('space'); escKey = KbName('ESCAPE');
keyZero = KbName('0)'); keyOne = KbName('1!'); keyTwo = KbName('2@'); keyThree = KbName('3#'); keyFour = KbName('4$');...
    keyFive = KbName('5%');keySix = KbName('6^'); keySeven = KbName('7&'); keyEight = KbName('8*'); keyNine = KbName('9(');
keyZeroNum = KbName('0'); keyOneNum = KbName('1'); keyTwoNum = KbName('2'); keyThreeNum = KbName('3'); keyFourNum = KbName('4');...
    keyFiveNum = KbName('5');keySixNum = KbName('6'); keySevenNum = KbName('7'); keyEightNum = KbName('8'); keyNineNum = KbName('9');

bgcolor = [255 255 255]; % set back ground color
textcolor = [0 0 0]; % set font color

% Screen Parameters
[mainwin, screenrect] = Screen(0,'OpenWindow');
Screen('FillRect',mainwin,bgcolor);
center = [screenrect(3)/2,screenrect(4)/2];
Screen(mainwin,'Flip');

% Load Stim and other images
im = imread('FixCross.jpg');
im_cross = Screen('MakeTexture',mainwin,im);
clear im;
im = imread('MentalFatigue.jpg');
im = imresize(im,0.4);
imfatigue = Screen('MakeTexture',mainwin,im);
clear im;
im = imread('Motivation.jpg');
im = imresize(im,0.4);
imMotivation = Screen('MakeTexture',mainwin,im);
clear im;
for i = 0:5
    im = imread(['N_cue_',num2str(i),'.jpg']);
    im_N{i+1} = Screen('MakeTexture',mainwin,im);
    clear im;
end
for i = 0:9
    im = imread([num2str(i),'.jpg']);
    im_stim{i+1} = Screen('MakeTexture',mainwin,im);
    clear im;
end

% Set the runtime duration (in seconds) and number of maximum stimulus
runtime_duration = run_time*60;
NumStim = run_time * 60;

times_n_change = randi([60,100],1,1); % Maximum possible number of time N will change
minSTim = 76;  % Minimum stimuli after which N will be changed (in seconds)
maxSTim = 84; % Maximum stimuli after which N will be changed (in seconds)

rndm_Stim = randi([minSTim,maxSTim],times_n_change,1);  % Random time intervals after which N will be changed in seconds
rndm_N = 2; % Initial value of N for the first block

sequence = [];
ground_truth = [];

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
            ShowCursor;
            Screen('CloseAll');
            return;
        end
    end
end

% Task instructions
Screen('DrawText',mainwin,'Press Spacebar if you detect a repetition after the value of N (will be shown shortly)',...
    center(1)-700,center(2)-20,textcolor);
Screen('Flip',mainwin);
WaitSecs(5)

% Display of fixation cross
Screen('DrawTexture',mainwin,im_cross);
Screen('Flip',mainwin);
WaitSecs(2);

t0 = clock; % Initialize clock
idx = 1;
for Nidx = 1 : times_n_change
    if etime(clock, t0) < runtime_duration
        sq = [];
        grnd_truth = [];
        N(Nidx) = rndm_N;
        trialList = nBackCreateTrialList(rndm_N+1,NumStim,NumStim*0.1);
        stim_seq = trialList(1,:);
        count = 0;
        Screen('DrawTexture',mainwin,im_N{rndm_N+1});
        Screen('Flip',mainwin);
        WaitSecs(1);
        RestrictKeysForKbCheck([spaceKey,escKey]);
        ListenChar(2);
        stm = 1;
        for stim = 1 : NumStim
            keyIsDown = 0;
            if stm <= rndm_Stim(Nidx)
                sequence{Nidx}(stim) = stim_seq(stim);
                ground_truth{Nidx}(stim) = trialList(2,stim);
                Screen('DrawTexture',mainwin,im_stim{stim_seq(stim)+1});
                Screen('Flip',mainwin);
                timestart = GetSecs;
                timedout = false;
                while ~timedout
                    [ keyIsDown, keyTime, keyCode ] = KbCheck; 
                    if keyIsDown
                        if keyCode(spaceKey)
                            reaction_time{Nidx}(stim) = GetSecs - timestart;
                            WaitSecs(1)
                            break;
                        elseif keyCode(escKey)
                            ShowCursor;
                            Screen('CloseAll');
                            return;
                        end  
                    elseif((keyTime - timestart) > 1)
                        reaction_time{Nidx}(stim) = nan;
                        timedout = true;
                    else
                        reaction_time{Nidx}(stim) = nan;
                    end
                end
                idx = idx+1;
                count = count + 1;
                Screen('FillRect',mainwin,bgcolor);
                Screen('Flip',mainwin);
                WaitSecs(0.8);
                stm = stm+1;
            end
        end
        RestrictKeysForKbCheck;
        ListenChar(1);
        Ytrue = find(ground_truth{Nidx});
        Ypred = find(~isnan(reaction_time{Nidx}));
        correct_resp = 0;
        for resp = 1:numel(Ytrue)
            if ismember(Ytrue(resp),Ypred(:))
                correct_resp = correct_resp + 1;
            end
        end
        incorrect_resp = 0;
        for resp = 1:numel(Ypred)
            if ismember(Ypred(resp),Ytrue(:)) == false
                incorrect_resp = incorrect_resp + 1;
            end
        end
        if numel(Ytrue) > numel(Ypred)
            missed_stim = numel(Ytrue) - numel(Ypred);
        else
            missed_stim = 0;
        end
        if (isempty(Ypred))
            acc = 0;
        else
            acc = (correct_resp/(correct_resp + incorrect_resp + missed_stim))*100;
        end
        Acc(Nidx) = acc;
        clear grnd_truth
        if acc <= 25
            Screen('DrawText',mainwin,...
                ['Accuracy = ',num2str(acc),'% Focus on the task !!!'],...
                center(1)-350,center(2)-20,textcolor);
            Screen('Flip',mainwin);
            WaitSecs(2);
            rndm_N = 0;
%         elseif acc > 25 && acc <= 50
%             Screen('DrawText',mainwin,...
%                 ['Accuracy = ',num2str(acc),'% You can do better, keep it up !!!'],...
%                 center(1)-350,center(2)-20,textcolor);
%             Screen('Flip',mainwin);
%             WaitSecs(2);
%             if rndm_N >= 2
%                 rndm_N = rndm_N-1;
%             else
%                 rndm_N = 0;
%             end
        elseif acc > 25 && acc <= 70
            Screen('DrawText',mainwin,...
                ['Accuracy = ',num2str(acc),'% You are doing well keep it up !!!'],...
                center(1)-350,center(2)-20,textcolor);
            Screen('Flip',mainwin);
            WaitSecs(2);
            if rndm_N ~= 0
                rndm_N = rndm_N-1;
            else
                rndm_N = 0;
            end
         elseif acc > 70 && acc <= 85
            Screen('DrawText',mainwin,...
                ['Accuracy = ',num2str(acc),'% You are doing well keep it up !!!'],...
                center(1)-350,center(2)-20,textcolor);
            Screen('Flip',mainwin);
            WaitSecs(2);
            rndm_N = rndm_N;
        elseif acc > 85 && acc <= 100
            Screen('DrawText',mainwin,...
                ['Accuracy = ',num2str(acc),'% You are flying through it !!!'],...
                center(1)-350,center(2)-20,textcolor);
            Screen('Flip',mainwin);
            WaitSecs(2);
            if rndm_N <= 3
                rndm_N = rndm_N + 2;
            else
                rndm_N = 5;
            end
        end
        Screen('Flip',mainwin);
        WaitSecs(0.8);
        RestrictKeysForKbCheck([keyZero,keyZeroNum,keyOne,keyOneNum,keyTwo,keyTwoNum,keyThree,keyThreeNum,keyFour,keyFourNum, ...
            keyFive,keyFiveNum,keySix,keySixNum,keySeven,keySevenNum,keyEight,keyEightNum,keyNine,keyNineNum,escKey]);
        ListenChar(2);
        Screen('DrawTexture',mainwin,imfatigue);
        Screen('Flip',mainwin);
        SubjectiveFatigueTimer = GetSecs;
        timerFlag = false;

        while ~timerFlag
            [ keyIsDown, keyTime, keyCode ] = KbCheck; 
            if keyIsDown
                if keyCode(keyZero) || keyCode(keyZeroNum)
                    FatigueScore(Nidx) = 0;
                    Screen('DrawText',mainwin,...
                        ['You Reported your fatigue level as ', num2str(FatigueScore(Nidx))],...
                        center(1)-350,center(2)-20,textcolor);
                    Screen('Flip',mainwin);
                    WaitSecs(2);
                    break;
                elseif keyCode(keyOne) || keyCode(keyOneNum)
                    FatigueScore(Nidx) = 1;
                    Screen('DrawText',mainwin,...
                        ['You Reported your fatigue level as ', num2str(FatigueScore(Nidx))],...
                        center(1)-350,center(2)-20,textcolor);
                    Screen('Flip',mainwin);
                    WaitSecs(2);
                    break;
                elseif keyCode(keyTwo) || keyCode(keyTwoNum)
                    FatigueScore(Nidx) = 2;
                    Screen('DrawText',mainwin,...
                        ['You Reported your fatigue level as ', num2str(FatigueScore(Nidx))],...
                        center(1)-350,center(2)-20,textcolor);
                    Screen('Flip',mainwin);
                    WaitSecs(2);
                    break;
                elseif keyCode(keyThree) || keyCode(keyThreeNum)
                    FatigueScore(Nidx) = 3;
                    Screen('DrawText',mainwin,...
                        ['You Reported your fatigue level as ', num2str(FatigueScore(Nidx))],...
                        center(1)-350,center(2)-20,textcolor);
                    Screen('Flip',mainwin);
                    WaitSecs(2);
                    break;
                elseif keyCode(keyFour) || keyCode(keyFourNum)
                    FatigueScore(Nidx) = 4;
                    Screen('DrawText',mainwin,...
                        ['You Reported your fatigue level as ', num2str(FatigueScore(Nidx))],...
                        center(1)-350,center(2)-20,textcolor);
                    Screen('Flip',mainwin);
                    WaitSecs(2);
                    break;
                elseif keyCode(keyFive) || keyCode(keyFiveNum)
                    FatigueScore(Nidx) = 5;
                    Screen('DrawText',mainwin,...
                        ['You Reported your fatigue level as ', num2str(FatigueScore(Nidx))],...
                        center(1)-350,center(2)-20,textcolor);
                    Screen('Flip',mainwin);
                    WaitSecs(2);
                    break;
                elseif keyCode(keySix) || keyCode(keySixNum)
                    FatigueScore(Nidx) = 6;
                    Screen('DrawText',mainwin,...
                        ['You Reported your fatigue level as ', num2str(FatigueScore(Nidx))],...
                        center(1)-350,center(2)-20,textcolor);
                    Screen('Flip',mainwin);
                    WaitSecs(2);
                    break;
                elseif keyCode(keySeven) || keyCode(keySevenNum)
                    FatigueScore(Nidx) = 7;
                    Screen('DrawText',mainwin,...
                        ['You Reported your fatigue level as ', num2str(FatigueScore(Nidx))],...
                        center(1)-350,center(2)-20,textcolor);
                    Screen('Flip',mainwin);
                    WaitSecs(2);
                    break;
                elseif keyCode(keyEight) || keyCode(keyEightNum)
                    FatigueScore(Nidx) = 8;
                    Screen('DrawText',mainwin,...
                        ['You Reported your fatigue level as ', num2str(FatigueScore(Nidx))],...
                        center(1)-350,center(2)-20,textcolor);
                    Screen('Flip',mainwin);
                    WaitSecs(2);
                    break;
                elseif keyCode(keyNine) || keyCode(keyNineNum)
                    FatigueScore(Nidx) = 9;
                    Screen('DrawText',mainwin,...
                        ['You Reported your fatigue level as ', num2str(FatigueScore(Nidx))],...
                        center(1)-350,center(2)-20,textcolor);
                    Screen('Flip',mainwin);
                    WaitSecs(2);
                    break;
                elseif keyCode(escKey)
                    RestrictKeysForKbCheck;
                    ListenChar(1);
                    ShowCursor;
                    Screen('CloseAll');
                    return;
                end  
            elseif((keyTime - SubjectiveFatigueTimer) > 5)
                FatigueScore(Nidx) = nan;
                Screen('DrawText',mainwin,...
                    'You have not reported your fatigue score this time',...
                    center(1)-450,center(2)-20,textcolor);
                Screen('Flip',mainwin);
                WaitSecs(2);
                break;
            end
        end
        RestrictKeysForKbCheck([keyZero,keyZeroNum,keyOne,keyOneNum,keyTwo,keyTwoNum,keyThree,keyThreeNum,keyFour,keyFourNum, ...
            keyFive,keyFiveNum,keySix,keySixNum,keySeven,keySevenNum,keyEight,keyEightNum,keyNine,keyNineNum,escKey]);
        ListenChar(2);
        Screen('DrawTexture',mainwin,imMotivation);
        Screen('Flip',mainwin);
        SubjectiveMotivationTimer = GetSecs;
        timerFlag = false;

        while ~timerFlag
            [ keyIsDown, keyTime, keyCode ] = KbCheck; 
            if keyIsDown
                if keyCode(keyZero) || keyCode(keyZeroNum)
                    MotivationScore(Nidx) = 0;
                    Screen('DrawText',mainwin,...
                        ['You Reported your motivation level as ', num2str(MotivationScore(Nidx))],...
                        center(1)-350,center(2)-20,textcolor);
                    Screen('Flip',mainwin);
                    WaitSecs(2);
                    break;
                elseif keyCode(keyOne) || keyCode(keyOneNum)
                    MotivationScore(Nidx) = 1;
                    Screen('DrawText',mainwin,...
                        ['You Reported your motivation level as ', num2str(MotivationScore(Nidx))],...
                        center(1)-350,center(2)-20,textcolor);
                    Screen('Flip',mainwin);
                    WaitSecs(2);
                    break;
                elseif keyCode(keyTwo) || keyCode(keyTwoNum)
                    MotivationScore(Nidx) = 2;
                    Screen('DrawText',mainwin,...
                        ['You Reported your motivation level as ', num2str(MotivationScore(Nidx))],...
                        center(1)-350,center(2)-20,textcolor);
                    Screen('Flip',mainwin);
                    WaitSecs(2);
                    break;
                elseif keyCode(keyThree) || keyCode(keyThreeNum)
                    MotivationScore(Nidx) = 3;
                    Screen('DrawText',mainwin,...
                        ['You Reported your motivation level as ', num2str(MotivationScore(Nidx))],...
                        center(1)-350,center(2)-20,textcolor);
                    Screen('Flip',mainwin);
                    WaitSecs(2);
                    break;
                elseif keyCode(keyFour) || keyCode(keyFourNum)
                    MotivationScore(Nidx) = 4;
                    Screen('DrawText',mainwin,...
                        ['You Reported your motivation level as ', num2str(MotivationScore(Nidx))],...
                        center(1)-350,center(2)-20,textcolor);
                    Screen('Flip',mainwin);
                    WaitSecs(2);
                    break;
                elseif keyCode(keyFive) || keyCode(keyFiveNum)
                    MotivationScore(Nidx) = 5;
                    Screen('DrawText',mainwin,...
                        ['You Reported your motivation level as ', num2str(MotivationScore(Nidx))],...
                        center(1)-350,center(2)-20,textcolor);
                    Screen('Flip',mainwin);
                    WaitSecs(2);
                    break;
                elseif keyCode(keySix) || keyCode(keySixNum)
                    MotivationScore(Nidx) = 6;
                    Screen('DrawText',mainwin,...
                        ['You Reported your motivation level as ', num2str(MotivationScore(Nidx))],...
                        center(1)-350,center(2)-20,textcolor);
                    Screen('Flip',mainwin);
                    WaitSecs(2);
                    break;
                elseif keyCode(keySeven) || keyCode(keySevenNum)
                    MotivationScore(Nidx) = 7;
                    Screen('DrawText',mainwin,...
                        ['You Reported your motivation level as ', num2str(MotivationScore(Nidx))],...
                        center(1)-350,center(2)-20,textcolor);
                    Screen('Flip',mainwin);
                    WaitSecs(2);
                    break;
                elseif keyCode(keyEight) || keyCode(keyEightNum)
                    MotivationScore(Nidx) = 8;
                    Screen('DrawText',mainwin,...
                        ['You Reported your motivation level as ', num2str(MotivationScore(Nidx))],...
                        center(1)-350,center(2)-20,textcolor);
                    Screen('Flip',mainwin);
                    WaitSecs(2);
                    break;
                elseif keyCode(keyNine) || keyCode(keyNineNum)
                    MotivationScore(Nidx) = 9;
                    Screen('DrawText',mainwin,...
                        ['You Reported your motivation level as ', num2str(MotivationScore(Nidx))],...
                        center(1)-350,center(2)-20,textcolor);
                    Screen('Flip',mainwin);
                    WaitSecs(2);
                    break;
                elseif keyCode(escKey)
                    RestrictKeysForKbCheck;
                    ListenChar(1);
                    ShowCursor;
                    Screen('CloseAll');
                    return;
                end  
            elseif((keyTime - SubjectiveMotivationTimer) > 5)
%                 timerFlag = true;
                MotivationScore(Nidx) = nan;
                Screen('DrawText',mainwin,...
                    'You have not reported your motivation score this time',...
                    center(1)-450,center(2)-20,textcolor);
                Screen('Flip',mainwin);
                WaitSecs(2);
                break;
            end
        end
    end
end
RestrictKeysForKbCheck;
ListenChar(1);
WaitSecs(2);
ShowCursor;
Screen('CloseAll');
return;