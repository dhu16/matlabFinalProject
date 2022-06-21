clear; close all;   % clear variables and close windows
AssertOpenGL;       % make sure we have OpenGL which we need for displaying 
                    % stimuli; most computers come with it now
KbName('UnifyKeyNames'); % Ensure PTB recognizes keys on all OSs
Screen('Preference', 'SkipSyncTests', 1); % Skip sync tests, so we're not 
% forced out if the test fails
rng shuffle; % shuffle the random number generator seed



try
    d = dir('subject_data/*.mat'); %load all files into here
    numFiles = size(d,1);
    a = cell(numFiles, 1); %create empty array of appropriate size to hold files
    
    for i=1:numFiles
        a{i} = load(d(i).name);
    end
    
    s1 = struct2cell(a{1});
    s2 = struct2cell(a{2});
    s3 = struct2cell(a{3});
    s4 = struct2cell(a{4});
    s5 = struct2cell(a{5});
    
    %Calculate average of average RT for all subjects
    totalAvgRT1 = (s1{1}.avgrt1 + s2{1}.avgrt1 + s3{1}.avgrt1 + s4{1}.avgrt1 + s5{1}.avgrt1)/5;
    totalAvgRT2 = (s1{1}.avgrt2 + s2{1}.avgrt2 + s3{1}.avgrt2 + s4{1}.avgrt2 + s5{1}.avgrt2)/5;
    totalAvgRT3 = (s1{1}.avgrt3 + s2{1}.avgrt3 + s3{1}.avgrt3 + s4{1}.avgrt3 + s5{1}.avgrt3)/5;
    
    %Calculate avg correct answers for each condition
    totalAvgCon1 = (s1{1}.con1 + s2{1}.con1 + s3{1}.con1 + s4{1}.con1 + s5{1}.con1)/5;
    totalAvgCon2 = (s1{1}.con2 + s2{1}.con2 + s3{1}.con2 + s4{1}.con2 + s5{1}.con2)/5;
    totalAvgCon3 = (s1{1}.con3 + s2{1}.con3 + s3{1}.con3 + s4{1}.con3 + s5{1}.con3)/5;  
    
    %Graph RT averages
    figure(1);
    subplot(2,1,1);
    rtGraph = [totalAvgRT1 totalAvgRT2 totalAvgRT3];
    bar(rtGraph);
    xticklabels({'Immediate' 'Pictures' '3 sec delay'});
    xlabel('Conditions');
    ylabel('Reaction times');
    ylim([-.005,0]);
    title("Reaction Time Averages");
    
    %Graph correct answers avg
    ansGraph = [totalAvgCon1 totalAvgCon2 totalAvgCon3];
    subplot(2,1,2);
    bar(ansGraph);
    xticklabels({'Immediate' 'Pictures' '3 sec delay'});
    xlabel('Conditions');
    ylabel('# of Correct Choices');
    ylim([0,3]);
    title("Average # of Correct Choices Per Condition");
    
    %Descriptive statistics
    gMean = mean(ansGraph);
    gMedian = median(ansGraph);
    gSD = std(ansGraph);
    
    stat = [gMean gMedian gSD];
    
    statsTable = array2table(stat, 'VariableNames', ["Mean", "Median",... 
        "SD"]);
    
    
    %Hypothesis test
    NullMean = 0; 
    [h,p,ci,stats] = ttest(ansGraph,NullMean);
    tTestOutput = [stats.tstat stats.df ci stats.sd h p ];
    tTable  = array2table(tTestOutput, 'VariableNames', ["t", "df", "lower_bound",...
    "upper_bound", "sd", "h", "p"]);

    %if null is rejected or not
    if h == 1
        fprintf('Null hypothesis is rejected. ')
    elseif h == 0
        fprintf('Null hypothesis is retained. ')
    end
    
    
    SumStats.stat = statsTable;
    SumStats.h = h;
    SumStats.p = p;
    SumStats.ci = ci;
    SumStats.stats = stats;
    save('Data_Stats', 'ansGraph', 'SumStats');
    
    sca;
catch
    sca;
    psychrethrow(psychlasterror);
end