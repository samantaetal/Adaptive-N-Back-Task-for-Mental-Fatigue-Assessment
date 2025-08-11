function trialList = nBackCreateTrialList(n, trials, targets)
% Creates stimuli list for n-back task.

%  First try of creating trial list with targetsPerBlock
targetCount    = 0; % Variable counting the n-back targets in a block
trialList(1, 1:trials) = randi(9,1,trials); % Indicating stimulus number
trialList(2, 1:trials) = zeros(1, trials); % Indicating target status

for position = 1:length(trialList)
    if position > n
        if trialList(1, position) == trialList(1, position - n)
            targetCount = targetCount + 1;
            trialList(2, position) = 1;
        end
    end
end

moreThanThree = 0;
for i = 1:length(trialList) - 4 % Checking whether a stimulus more than three times
    if trialList(1, i + 1) ==  trialList(1, i + 2) &&  trialList(1, i + 1) == trialList(1, i + 3) &&  trialList(1, i + 1) == trialList(1, i + 4)
        moreThanThree = 1;
    end
end

if targetCount < targets || moreThanThree == 1 % Not equal so do it again
    while targetCount <= targets || moreThanThree == 1
        targetCount    = 0;
        moreThanThree  = 0;
        trialList(1, 1:trials) = randi(9,1,trials);
        trialList(2, 1:trials) = zeros(1, trials);
        for position = 1:length(trialList)
            if position > n
                if trialList(1, position) == trialList(1, position - n)
                    targetCount = targetCount + 1;
                    trialList(2, position) = 1;
                end
            end
        end
        for i = 1:length(trialList) - 4 % Checking whether a stimulus is repeated more than three times
            if trialList(1, i + 1) ==  trialList(1, i + 2) &&  trialList(1, i + 3) == trialList(1, i + 1) &&  trialList(1, i + 1) == trialList(1, i + 4)
                moreThanThree = 1;
            end
        end
    end
end
end