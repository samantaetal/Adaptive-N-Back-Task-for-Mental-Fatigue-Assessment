%% Demographic information of the participant

prompt = {'Outputfile','Subject number ','Session ','age','gender','PVT Runtime(in Minutes)','N-Back Runtime(in Minutes)'};
defaults = {'N_back_MEG_Data','0','0','NotSpecified','NotSpecified','10','40'};
answer = inputdlg(prompt,'N_back_RespTime',2,defaults);
[outputFileName,sub_id,session,sub_age,gender,pvt_runtime,nBack_runtime] = deal(answer{:});
pvt_runtime = str2double(pvt_runtime);
nBack_runtime = str2double(nBack_runtime);
Participant.sub_id = str2double(sub_id);
Participant.session = str2double(session);
Participant.gender = gender;
sub_age1 = str2double(sub_age);
if isnan(sub_age1) == false
    Participant.age = sub_age1;
else 
    Participant.age = sub_age;
end
clear prompt defaults answer sub_age1 sub_age gender;

%% Trigger Informations (Event Markers)

StartSession              = uint8(50);
EndSession                = uint8(51);
StartRestingPeriod        = uint8(20);
EndRestingPeriod          = uint8(21);
StartPVT                  = uint8(15);
EndPVT                    = uint8(16);
NbackStart                = uint8(30);
NbackEnd                  = uint8(31);

%% Initialize parallel port commucation and UDP communication port for Eyetracker

% UDP objects
IPAddress = '192.168.8.1'; % IP adress of the terget computer
Port = 3001;
udpSend = dsp.UDPSender('RemoteIPPort',Port,'RemoteIPAddress',IPAddress);

% open the parallel port communication
addpath(genpath('C:\Users\sb00896414\OneDrive - Ulster University\MEG Machine Inferface\'));
ioObj = io64;
status = io64(ioObj);
address = hex2dec('C100');
io64(ioObj,address,255);
pause(3);
io64(ioObj,address,0);

%% Complete Paradigm

addpath(genpath('./functions/'))

% Initialize stimulus screen
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);
screen = max(Screen('Screens'));
PsychImaging('PrepareConfiguration');
win = PsychImaging('OpenWindow', screen, [1, 1, 1]);
[w, h] = Screen('WindowSize', win);
Screen('Blendfunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Start Session
udpSend(StartSession);
WaitSecs(0.5)
udpSend(uint8(0));
io64(ioObj,address,StartSession);
io64(ioObj,address,0);

% Cue resting state
Screen('TextSize',win,70);
DrawFormattedText(win, 'Stay relaxed and maintain your focus on the "+" sign on the screen',...
    'center','center',0,40);
Screen('Flip',win);

% Starting of Resting State (Export Event Marker)
udpSend(StartRestingPeriod);
io64(ioObj,address,StartRestingPeriod);
io64(ioObj,address,0);

WaitSecs(2);

% Resting State Screen
Screen('TextSize',win,400);
DrawFormattedText(win, '+','center','center',0,1);
Screen('Flip',win);
timeLimit = 30; % in seconds

% Countdown (Last 5 Seconds)
t0 = GetSecs;
while GetSecs - t0 < timeLimit
    if GetSecs - t0 < timeLimit - 5
        WaitSecs(1);
    else
        DrawFormattedText(win, num2str(round(timeLimit - (GetSecs - t0))),...
            'center','center',0,40);
        Screen('Flip',win);
        WaitSecs(1);
    end
end

% Ending of Resting State (Export Event Marker)
udpSend(EndRestingPeriod);
io64(ioObj,address,EndRestingPeriod);
io64(ioObj,address,0);

% Pre-task subjective and objective mental fatigue scoring by PVT
udpSend(StartPVT);
WaitSecs(0.5)
udpSend(uint8(0));
io64(ioObj,address,StartPVT);
io64(ioObj,address,0);

[preTestFatigueScore,preTestMotivationLevel,preTask_reaction_time,...
    preTask_time_stamp,preTask_horz_eyeMovement,preTask_vert_eyeMovement,...
    preTask_pupil_size] = pvt_2(pvt_runtime,win,w,h);

udpSend(EndPVT);
WaitSecs(0.5)
udpSend(uint8(0));
io64(ioObj,address,EndPVT);
io64(ioObj,address,0);

% N-back Task
udpSend(NbackStart);
WaitSecs(0.5)
udpSend(uint8(0));
io64(ioObj,address,NbackStart);
io64(ioObj,address,0);
[Reaction_time,N,Stim_sequence,Ground_truth,Acc,IntraTaskFatigueScore,...
    IntraTaskMotivationScore,IntraTask_horz_eyeMovement,...
    IntraTask_vert_eyeMovement,IntraTask_pupil_size] = nBack2(nBack_runtime,win,w);

udpSend(NbackEnd);
WaitSecs(0.5)
udpSend(uint8(0));
io64(ioObj,address,NbackEnd);
io64(ioObj,address,0);

% Post-task subjective and objective mental fatigue scoring by PVT
udpSend(StartPVT);
WaitSecs(0.5)
udpSend(uint8(0));
io64(ioObj,address,StartPVT);
io64(ioObj,address,0);

[postTask_FatigueScore,postTask_MotivationLevel,postTask_reaction_time,...
    postTask_time_stamp,postTask_horz_eyeMovement,postTask_vert_eyeMovement,...
    postTask_pupil_size] = pvt_2(pvt_runtime,win,w,h);

udpSend(EndPVT);
WaitSecs(0.5)
udpSend(uint8(0));
io64(ioObj,address,EndPVT);
io64(ioObj,address,0);

% End of the Session
Screen('TextSize',win,70);
DrawFormattedText(win, 'END of the session', 'center', 'center', 0, 40);
Screen('Flip',win);
WaitSecs(1);

udpSend(EndSession);
WaitSecs(0.5)
udpSend(uint8(0));
io64(ioObj,address,EndSession);
io64(ioObj,address,0);

DrawFormattedText(win, 'Thank you for your participation!!!','center','center',0,40);
Screen('Flip',win);
WaitSecs(2);

% Close screens
Screen('CloseAll');

%% Saving Data
clear ans;
save([outputFileName,'_Sub_',sub_id,'_session_',session,'.mat']);