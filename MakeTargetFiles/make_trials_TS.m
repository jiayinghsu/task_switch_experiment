% Make Trial File -- Mirror Task
% SDM: Feb 3rd, Berkeley, 2016

function  make_trials_TS(SN, dir)
%dir = '/Users/arohisaxena/Dropbox/VICE/JT/TASK_SWITCH/';
%dir = '/Users/newxjy/Dropbox/VICE/JT/TASK_SWITCH/';
cd([dir, 'TargetFiles']); 
% turn off warnings 
warning('off','all')
ri = 1; 
%% desired session length
while ri < 2
    
    numTrials = 120; % number of trial
    num_set = [1, 2, 3, 4, 6, 7, 8, 9]; % which numbers do you want
    let_set = 1:8; % how many letters do you want
    let_map = ['A','E', 'I', 'U', 'M', 'G','K', 'R'];
    rep_cond = 80; % repitition per condition
    transition_set = repmat(1:3, [1, rep_cond])';
    stim_set =  CombVec(num_set, let_set)';
    
    % initialize
    T = table();
    T.trial_num(1) = 1;
    T.number(1) = stim_set(1, 1);
    T.letter(1) = let_map ( stim_set(1, 2) );
    T.trans(1) = 1;
    T.trial_type(1) = 1;
    transition_set(1) = [];
    
    trial = 2;
    
    while trial < numTrials + 1
        
        stim = stim_set ( randi( size(stim_set, 1) ), :);
        row_trans = randi( size(transition_set, 1) );
        trans = transition_set ( row_trans );
        
        if stim(1) == T.number(trial - 1) | let_map ( stim(2) ) == T.letter(trial - 1)
            
        else
            T.number(trial) = stim(1);
            T.letter(trial) = let_map ( stim(2) ) ;
            T.trans(trial) = trans;
            transition_set(row_trans) = [];
            trial = trial + 1;
        end
        
    end
    
    
    % Determine Trial Type Based on Transition
    
    % TRANSITIONS conditions:
    % 1: SAME SAME N1 -> N1
    % 2: SAME DIFFERENT N1 -> N2
    % 3: DIFFERENT DIFFERENT N1 -> L3
    
    % Trial_Type =
    % N1 = odd/even,
    % N2 = > or < 5,
    % L3 = Cons or Vowel
    m = 2;
    while m < numTrials + 1
        
        if T.trans(m) == 1 & T.trial_type(m - 1) == 1
            T.trial_type(m) = 1;
        elseif T.trans(m) == 1 & T.trial_type(m - 1) == 2
            T.trial_type(m) = 2;
        elseif T.trans(m) == 1 & T.trial_type(m - 1) == 3
            T.trial_type(m) = 3;
        elseif T.trans(m) == 2 & T.trial_type(m - 1) == 1
            T.trial_type(m) = 2;
        elseif T.trans(m) == 2 & T.trial_type(m - 1) == 2
            T.trial_type(m) = 1;
        elseif T.trans(m) == 2 & T.trial_type(m - 1) == 3
            % nothing in this condition
            T(m, :) = [];
            m = m - 1;
            numTrials = numTrials - 1;
        elseif T.trans(m) == 3 & T.trial_type(m - 1) == 1
            T.trial_type(m) = 3;
        elseif T.trans(m) == 3 & T.trial_type(m - 1) == 2
            T.trial_type(m) = 3;
        elseif T.trans(m) == 3 & T.trial_type(m - 1) == 3
            T.trial_type(m) = randi([1, 2]);
        end
        m = m + 1;
    end
    
    if sum(T.trial_type == 1) >= sum(T.trial_type == 2) - 2 & ...
            sum(T.trial_type == 1) <= sum(T.trial_type == 2) + 2 & ...
            sum(T.trial_type == 1) >= sum(T.trial_type == 3) - 2 & ...
            sum(T.trial_type == 1) <= sum(T.trial_type == 3) + 2
        
        ri = ri + 1;
        
        sum(T.trans == 1)
        sum(T.trans == 2)
        sum(T.trans == 3)
        
        sum(T.trial_type == 1)
        sum(T.trial_type == 2)
        sum(T.trial_type == 3)
    end
    
    % correct response:
    % 0 is right, 1 is left
    % N1: Odd = Right key press, Even = Left Key Press
    % N2: >5 = Right key press, < 5 = Left Key Press
    % L3: Consonant = Right key press, Vowel = Left Key Press
    
    T.correct = ones(numTrials, 1);
    T.correct(T.trial_type == 1 & mod(T.number, 2) ~= 0) = 0;
    T.correct(T.trial_type == 2 & T.number > 5) = 0;
    T.correct(T.trial_type == 3 & T.letter == 'M') = 0;
    T.correct(T.trial_type == 3 & T.letter == 'G') = 0;
    T.correct(T.trial_type == 3 & T.letter == 'K') = 0;
    T.correct(T.trial_type == 3 & T.letter == 'R') = 0;
    T.trial_num = [1:size(T, 1)]';
end
writetable(T, ['TS_', SN, '.csv']);
end
