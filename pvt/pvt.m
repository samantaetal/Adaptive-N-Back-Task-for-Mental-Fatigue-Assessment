function [reaction_time,time_stamp] =  pvt(run_time)
% Parameters and Image initialization
im_start = imread('Initial_pvt.jpg');
[x,y,~] = size(im_start);
im_end = imread('End_pvt.jpg');
im_end = imresize(im_end,[x,y]);

% Run time of the task (in seconds) <should not be touched>
runtime_duration = run_time*60;

figure('WindowState','fullscreen','MenuBar', 'none','ToolBar', 'none');

% Prompting the participant
imshow(im_start)
pause;
dtclr = 0.85;
plot(0,0,'+', 'LineWidth',25, 'MarkerSize',100,'MarkerEdgeColor',[0 0 0]);
axis off
set(gca,'xtick',[],'xticklabel',[],'ytick',[],'xticklabel',[])
xlim([-1,1])
ylim([-1,1])
pause(2)

t0 = clock;
for stim = 1:inf
    a = -0.9;
    b = 0.9;
    x = (b-a).*rand(1,1) + a;
    y = (b-a).*rand(1,1) + a;
    if etime(clock, t0) < runtime_duration
        time_stamp(stim) = etime(clock, t0);
        plot(x, y, '.', 'MarkerSize',100,'MarkerEdgeColor',[dtclr dtclr dtclr]);
        axis off
        set(gca,'xtick',[],'xticklabel',[],'ytick',[],'xticklabel',[])
        xlim([-2,2])
        ylim([-2,2])
        tic
        pause()
        reaction_time(stim) = toc;
        plot(0, 0, ' ', 'MarkerSize',100,'MarkerEdgeColor',[dtclr dtclr dtclr]);
        axis off
        set(gca,'xtick',[],'xticklabel',[],'ytick',[],'xticklabel',[])
        xlim([-2,2])
        ylim([-2,2])
        pause(randi([1,6]))
    else
        break;
    end
end
pause(0.2)
% close
figure('WindowState','fullscreen','MenuBar', 'none','ToolBar', 'none');
imshow(im_end);
pause(3)
close all;
end