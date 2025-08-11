function [reaction_time,N,sequence,ground_truth,Acc,FatigueScore,MotivationScore,horz_eyeMovement,vert_eyeMovement,pupil_size] = nBack2(run_time,mainwin,w)

addpath(genpath('./'))

% Initialize output variables
reaction_time=[];
N=[];
sequence=[];
ground_truth=[];
Acc=[];
FatigueScore=[];
MotivationScore=[];
horz_eyeMovement=[];
vert_eyeMovement=[];
pupil_size=[];

% Experimental parameters
rand('state',sum(100*clock));
bgcolor = [255 255 255]; % set back ground color
textcolor = [0 0 0]; % set font color

grid = 0:w/10:w; grid(1) = [];
Screen(mainwin,'Flip');

% Load Stim and other images
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
NumStim = run_time * 60 * 2;

times_n_change = randi([60,100],1,1); % Maximum possible number of time N will change
minSTim = 76;  % Minimum stimuli after which N will be changed (in seconds)
maxSTim = 84; % Maximum stimuli after which N will be changed (in seconds)

rndm_Stim = randi([minSTim,maxSTim],times_n_change,1);  % Random stimulus after which N will be changed in seconds
rndm_N = 1; % Initial value of N for the first block


% Experimental instructions
Screen('FillRect',mainwin,bgcolor);
Screen('TextSize',mainwin,50);
DrawFormattedText(mainwin, ['If you are ready press "Left Click Button of the Mouse" to start or ' ...
    'press "Scroll Button" to leave'],'center', 'center', 0, 80);
Screen('Flip',mainwin);

[~,~,~,whichButton,~] = GetClicks;
if whichButton == 3
    ShowCursor;
    Screen('CloseAll');
    return;
end

% Task instructions
DrawFormattedText(mainwin, ['Press Left Click Button if you detect a repetition after' ...
    ' the value of N (will be shown shortly)'],'center', 'center', 0, 80);
Screen('Flip',mainwin);
WaitSecs(3);

% Display of fixation cross
Screen('DrawTexture',mainwin,im_cross);
Screen('Flip',mainwin);
WaitSecs(1);

t0 = GetSecs; % Initialize clock
idx = 1;

for Nidx = 1 : times_n_change
    if GetSecs - t0 < runtime_duration
        sq = [];
        grnd_truth = [];
        N(Nidx) = rndm_N;
        trialList = nBackCreateTrialList(rndm_N+1,NumStim,NumStim*0.1);
        stim_seq = trialList(1,:);
        Screen('DrawTexture',mainwin,im_N{rndm_N+1});
        Screen('Flip',mainwin);
        WaitSecs(1);
        stm = 1;
        for stim = 1 : NumStim
            clicks = 0;
            if stm <= rndm_Stim(Nidx)
                sequence{Nidx}(stim) = stim_seq(stim);
                ground_truth{Nidx}(stim) = trialList(2,stim);
                Screen('DrawTexture',mainwin,im_stim{stim_seq(stim)+1});
                Screen('Flip',mainwin);
                timestart = GetSecs;
                [clicks,~,~,whichButton,clickTime] = GetClicks([],0,[],GetSecs + 1);

                if clicks
                    if whichButton == 1
                        reaction_time{Nidx}(stim) = clickTime - timestart;
                        WaitSecs(0.2)
                    elseif whichButton == 2
                        ShowCursor;
                        Screen('CloseAll');
                        return;
                    end  
                else
                    reaction_time{Nidx}(stim) = nan;
                end
                Screen('FillRect',mainwin,bgcolor);
                Screen('Flip',mainwin);
                WaitSecs(0.2);
                stm = stm+1;
            else
                break;
            end
        end

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
        clear grnd_truth;
        if acc <= 25
            DrawFormattedText(mainwin, ['Accuracy = ',num2str(acc),'% Focus on the task !!!'],...
                'center', 'center', 0, 40);
            Screen('Flip',mainwin);
            WaitSecs(1);
            rndm_N = 0;
        elseif acc > 25 && acc <= 70
            DrawFormattedText(mainwin, ['Accuracy = ',num2str(acc),'% You are doing well keep it up !!!'],...
                'center', 'center', 0, 40);
            Screen('Flip',mainwin);
            WaitSecs(1);
            if rndm_N ~= 0
                rndm_N = rndm_N-1;
            else
                rndm_N = 0;
            end
         elseif acc > 70 && acc <= 85
            DrawFormattedText(mainwin, ['Accuracy = ',num2str(acc),'% You are doing well keep it up !!!'],...
                'center', 'center', 0, 40);
            Screen('Flip',mainwin);
            WaitSecs(1);
            rndm_N = rndm_N;
        elseif acc > 85 && acc <= 100
            DrawFormattedText(mainwin, ['Accuracy = ',num2str(acc),'% You are flying through it !!!'],...
                'center', 'center', 0, 40);
            Screen('Flip',mainwin);
            WaitSecs(1);
            if rndm_N <= 3
                rndm_N = rndm_N + 1;
            else
                rndm_N = 5;
            end
        end
        Screen('DrawTexture',mainwin,imfatigue);
        Screen('Flip',mainwin);
        clicks = 0;
        [clicks,x,~,whichButton,~] = GetClicks([],0,[],GetSecs + 5);
        if clicks
            if whichButton == 1 && x < grid(1)
                FatigueScore(Nidx) = 0;
                DrawFormattedText(mainwin, ['You Reported your fatigue level as ', ...
                    num2str(FatigueScore(Nidx))], 'center', 'center', 0, 40);
                Screen('Flip',mainwin);
                WaitSecs(1);
            elseif whichButton == 1 && x > grid(1) && x < grid(2)
                FatigueScore(Nidx) = 1;
                DrawFormattedText(mainwin, ['You Reported your fatigue level as ', ...
                    num2str(FatigueScore(Nidx))], 'center', 'center', 0, 40);
                Screen('Flip',mainwin);
                WaitSecs(1);
            elseif whichButton == 1 && x > grid(2) && x < grid(3)
                FatigueScore(Nidx) = 2;
                DrawFormattedText(mainwin, ['You Reported your fatigue level as ', ...
                    num2str(FatigueScore(Nidx))], 'center', 'center', 0, 40);
                Screen('Flip',mainwin);
                WaitSecs(1);
            elseif whichButton == 1 && x > grid(3) && x < grid(4)
                FatigueScore(Nidx) = 3;
                DrawFormattedText(mainwin, ['You Reported your fatigue level as ', ...
                    num2str(FatigueScore(Nidx))], 'center', 'center', 0, 40);
                Screen('Flip',mainwin);
                WaitSecs(1);
            elseif whichButton == 1 && x > grid(4) && x < grid(5)
                FatigueScore(Nidx) = 4;
                DrawFormattedText(mainwin, ['You Reported your fatigue level as ', ...
                    num2str(FatigueScore(Nidx))], 'center', 'center', 0, 40);
                Screen('Flip',mainwin);
                WaitSecs(1);
            elseif whichButton == 1 && x > grid(5) && x < grid(6)
                FatigueScore(Nidx) = 5;
                DrawFormattedText(mainwin, ['You Reported your fatigue level as ', ...
                    num2str(FatigueScore(Nidx))], 'center', 'center', 0, 40);
                Screen('Flip',mainwin);
                WaitSecs(1);
            elseif whichButton == 1 && x > grid(6) && x < grid(7)
                FatigueScore(Nidx) = 6;
                DrawFormattedText(mainwin, ['You Reported your fatigue level as ', ...
                    num2str(FatigueScore(Nidx))], 'center', 'center', 0, 40);
                Screen('Flip',mainwin);
                WaitSecs(1);
            elseif whichButton == 1 && x > grid(7) && x < grid(8)
                FatigueScore(Nidx) = 7;
                DrawFormattedText(mainwin, ['You Reported your fatigue level as ', ...
                    num2str(FatigueScore(Nidx))], 'center', 'center', 0, 40);
                Screen('Flip',mainwin);
                WaitSecs(1);
            elseif whichButton == 1 && x > grid(8) && x < grid(9)
                FatigueScore(Nidx) = 8;
                DrawFormattedText(mainwin, ['You Reported your fatigue level as ', ...
                    num2str(FatigueScore(Nidx))], 'center', 'center', 0, 40);
                Screen('Flip',mainwin);
                WaitSecs(1);
            elseif whichButton == 1 && x > grid(9)
                FatigueScore(Nidx) = 9;
                DrawFormattedText(mainwin, ['You Reported your fatigue level as ', ...
                    num2str(FatigueScore(Nidx))], 'center', 'center', 0, 40);
                Screen('Flip',mainwin);
                WaitSecs(1);
            elseif whichButton == 2
                ShowCursor;
                Screen('CloseAll');
                return;
            end  
        else
            FatigueScore(Nidx) = nan;
            DrawFormattedText(mainwin, 'You have not reported your fatigue score this time',...
                'center', 'center', 0, 40);
            Screen('Flip',mainwin);
            WaitSecs(1);
        end
        
        % Motivation
        Screen('DrawTexture',mainwin,imMotivation);
        Screen('Flip',mainwin);
        clicks = 0;
        [clicks,x,~,whichButton,~] = GetClicks([],0,[],GetSecs + 5); 
        if clicks
            if whichButton == 1 && x < grid(1)
                MotivationScore(Nidx) = 9;
                DrawFormattedText(mainwin, ['You Reported your motivation level as ', ...
                    num2str(MotivationScore(Nidx))], 'center', 'center', 0, 40);
                Screen('Flip',mainwin);
                WaitSecs(1);
            elseif whichButton == 1 && x > grid(1) && x < grid(2)
                MotivationScore(Nidx) = 8;
                DrawFormattedText(mainwin, ['You Reported your motivation level as ', ...
                    num2str(MotivationScore(Nidx))], 'center', 'center', 0, 40);
                Screen('Flip',mainwin);
                WaitSecs(1);
            elseif whichButton == 1 && x > grid(2) && x < grid(3)
                MotivationScore(Nidx) = 7;
                DrawFormattedText(mainwin, ['You Reported your motivation level as ', ...
                    num2str(MotivationScore(Nidx))], 'center', 'center', 0, 40);
                Screen('Flip',mainwin);
                WaitSecs(1);
            elseif whichButton == 1 && x > grid(3) && x < grid(4)
                MotivationScore(Nidx) = 6;
                DrawFormattedText(mainwin, ['You Reported your motivation level as ', ...
                    num2str(MotivationScore(Nidx))], 'center', 'center', 0, 40);
                Screen('Flip',mainwin);
                WaitSecs(1);
            elseif whichButton == 1 && x > grid(4) && x < grid(5)
                MotivationScore(Nidx) = 5;
                DrawFormattedText(mainwin, ['You Reported your motivation level as ', ...
                    num2str(MotivationScore(Nidx))], 'center', 'center', 0, 40);
                Screen('Flip',mainwin);
                WaitSecs(1);
            elseif whichButton == 1 && x > grid(5) && x < grid(6)
                MotivationScore(Nidx) = 4;
                DrawFormattedText(mainwin, ['You Reported your motivation level as ', ...
                    num2str(MotivationScore(Nidx))], 'center', 'center', 0, 40);
                Screen('Flip',mainwin);
                WaitSecs(1);
            elseif whichButton == 1 && x > grid(6) && x < grid(7)
                MotivationScore(Nidx) = 3;
                DrawFormattedText(mainwin, ['You Reported your motivation level as ', ...
                    num2str(MotivationScore(Nidx))], 'center', 'center', 0, 40);
                Screen('Flip',mainwin);
                WaitSecs(1);
            elseif whichButton == 1 && x > grid(7) && x < grid(8)
                MotivationScore(Nidx) = 2;
                DrawFormattedText(mainwin, ['You Reported your motivation level as ', ...
                    num2str(MotivationScore(Nidx))], 'center', 'center', 0, 40);
                Screen('Flip',mainwin);
                WaitSecs(1);
            elseif whichButton == 1 && x > grid(8) && x < grid(9)
                MotivationScore(Nidx) = 1;
                DrawFormattedText(mainwin, ['You Reported your motivation level as ', ...
                    num2str(MotivationScore(Nidx))], 'center', 'center', 0, 40);
                Screen('Flip',mainwin);
                WaitSecs(1);
            elseif whichButton == 1 && x > grid(9)
                MotivationScore(Nidx) = 0;
                DrawFormattedText(mainwin, ['You Reported your motivation level as ', ...
                    num2str(MotivationScore(Nidx))], 'center', 'center', 0, 40);
                Screen('Flip',mainwin);
                WaitSecs(1);
            elseif whichButton == 2
                ShowCursor;
                Screen('CloseAll');
                return;
            end  
        else
            MotivationScore(Nidx) = nan;
            DrawFormattedText(mainwin, 'You have not reported your motivation score this time',...
                'center', 'center', 0, 40);
            Screen('Flip',mainwin);
            WaitSecs(1);
        end
    end
end
Screen('TextSize',mainwin,70);
DrawFormattedText(mainwin, 'End of N-Back task', 'center', 'center', 0, 40);
Screen('Flip',mainwin);
WaitSecs(2);