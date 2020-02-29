function stop(record_id,isscan)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fMRI Stop Signal Task

% Authors: Priscilla Perez & Sarah Hennessy, 2018

% Modeled after task used in ABCD study (ePrime), originally created by
% Logan (1994).
% 
% The task will consist of 186 trials (120 Go; 30 Stop; 36 Null) and have an
% adaptive algorithm wherein the Stop Signal Delay on the next Stop trial
% decreases by 50 msec if the subject successfully inhibits on the previous
% Stop trial and increases by 50 msec if subject fails to inhibit on the
% previous Stop trial.  
% 
% RT and accuracy is measured.
% 
% Stop signal reaction time (SSRT) will be measured as the average 'go'
% response time minus the average 'stop' signal presentation time (stop
% signal delay). 
% 
% Post-error slowing will be calculated on go trials
% followed failed inhibitions relative to correct trials. 

% For a full task design, please go to the server: > School Study > Tasks >
% Task Designs > fMRI, or contact Sarah or Priscilla :)

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%setup
clear all;
sca;
close all;
Screen('Preference', 'SkipSyncTests',1);
screens = Screen('Screens'); 

%NEWER VERSIONS OF MATLAB USE:
%screenNumber = max(1);

%FOR OLDER VERSIONS OF MATLAB USE:
screenNumber = max(screens);

white = WhiteIndex(screenNumber); black = BlackIndex(screenNumber);
textcolor=white;

%login prompt

record_id = input('Enter subject name: ', 's');
isscan = input('practice = 0 block = 1:2 : ');

%Create trial orders and randomize thier order
right = 1 + zeros(60,1); %60 right arrows
left = 2 + zeros(60,1); %60 left arrows
rightstop = 3 + zeros(15,1); %15 right stops
leftstop = 4 + zeros(15,1); %15 left stops
nullcount = 5 + zeros(36,1); %36 null fix crosses
blockorders = [right;left;rightstop;leftstop;nullcount]; %put numbers in an array

rng('default')
rng('shuffle')

%LOAD IN STIM ORDERS 
if isscan == 0
    orderlist = Shuffle(blockorders); %shuffle array
    orderlist = orderlist(1:30); %shuffle array
    %orderfile = sprintf([pwd '/stimorderspractice.txt']);
else
    orderlist = Shuffle(blockorders); %shuffle array
    %orderfile = sprintf([pwd '/stimorders.txt']);
end

% format = '%d';
% %label the dif orders 
% [A] = textread(orderfile, format);
% %choose the correct order letter
% orderlist = Shuffle(A);

while orderlist((1)) == 3 || orderlist((1)) == 4
    orderlist = Shuffle(orderlist);
    fprintf('while loop worked')
    %disp(orderlist);
end

%LOAD IN ITI ORDERS
if isscan == 0
    itifile = load('ititimeorderspractice.mat');
else
    itifile = load('ititimeorders.mat');
end

itiorder = Shuffle(itifile.x);
extrafixonset = 0;
extrafixoffset = 0;



%Set up logfiles
if isscan == 0
    %set up practice log
    practicelogfilename = sprintf('%s_practice_stop_run%d.txt',record_id, isscan); %creates or appends information to log file
    fprintf('Opening practice logfile: %s\n',practicelogfilename); %prints string to screen, '%s' is the string identifier ('logfilename')
    practicelogfile = fopen([pwd '/data/practice/', practicelogfilename],'a');
    fprintf (practicelogfile, 'record_id\ttrial\ttrialonset\ttriallength\tstimonset\tstimlength\tfixonset\tfixlength\textrafixonset\textrafixlength\tcondition\tdirection\taccuracy\trt\n'); 
    
else
    logfilename = sprintf('%s_stop_run%d.txt',record_id, isscan); %creates or appends information to log file
    fprintf('Opening experiment logfile: %s\n',logfilename); %prints string to screen, '%s' is the string identifier ('logfilename')
    logfile = fopen([pwd '/data/', logfilename],'a');
    fprintf (logfile, 'record_id\ttrial\ttrialonset\ttriallength\tstimonset\tstimlength\tfixonset\tfixlength\textrafixonset\textrafixlength\tcondition\tdirection\taccuracy\trt\n');
end

%more screen prefs
%[w, ~]=PsychImaging('OpenWindow', screenNumber,0, [0 0 1024 768]);
[w, ~]=PsychImaging('OpenWindow', screenNumber);


%LOAD IMG 
img_signal = imread('stimuli/signal1.png');
img_right = imread('stimuli/go_right.png');
img_left = imread('stimuli/go_left.png');
img_fix = imread('stimuli/fix.png');
instruct1 = imread('instruct/instruct1.png');
instruct2 = imread('instruct/instruct2.png');
instruct3 = imread('instruct/instruct3.png');

%Make images
goRight = Screen('MakeTexture', w, img_right);
goLeft = Screen('MakeTexture', w, img_left);
signalShape = Screen('MakeTexture',w, img_signal);
fix_shape = Screen('MakeTexture',w, img_fix);


%SETUP KEY CODES
KbName('UnifyKeyNames');
key_l = KbName('l');
key_r = KbName('r');
escKey = KbName('q');
[keyIsDown, keyTime, keyCode] = KbCheck;


%instruct
Screen('FillRect',w,black); %setbackground

img = Screen ('MakeTexture', w, instruct1); %read the image file for the instructions
Screen ('DrawTexture', w, img); %write to buffer
Screen(w, 'Flip'); %plot on screen
fprintf('\nPress any key to continue');
KbWait(-1);
WaitSecs(0.5);


img = Screen ('MakeTexture', w, instruct2); %read the image file for the instructions
Screen ('DrawTexture', w, img); %write to buffer
Screen(w, 'Flip'); %plot on screen
fprintf('\nPress any key to continue');
KbWait(-1);
WaitSecs(0.5);

img = Screen ('MakeTexture', w, instruct3); %read the image file for the instructions
Screen ('DrawTexture', w, img); %write to buffer
Screen(w, 'Flip'); %plot on screen
fprintf('\nPress any key to continue to trigger screen');
KbWait(-1);
WaitSecs(0.5);

%wait for scanner trigger
fprintf('\nwaiting for scanner trigger...\n');
DrawFormattedText(w, 'Get Ready!', 'center', 'center', 255);
Screen('Flip', w);
doneCode=KbName('6^');
%doneCode=KbName('5%');   %Set scanner trigger key here
    
    while 1
        [ keyIsDown, timeSecs, keyCode ] = KbCheck(-1);
        if keyIsDown  
            index=find(keyCode);
            if (index==doneCode)
                timeStart = timeSecs; % Record start time 
                break;   
            end
        end
    end   
  
  
%PRESENT initial fixation cross
    Screen('DrawTexture',w,fix_shape);
    Screen('Flip',w);
    WaitSecs(5);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic; 
%BEGIN LOOPTY
%set initial ssd and sd
ssd = .05;


tic;
DisableKeysForKbCheck(doneCode);
for i = 1:length(orderlist)
    ss = 1-ssd;
    
    trialonset = GetSecs-timeStart;
  	
    Screen('DrawTexture',w,fix_shape);
    Screen('Flip',w);
    fixonset = GetSecs-timeStart;    
    WaitSecs(itiorder((i)));
    fixoffset = GetSecs-timeStart; 
    fixlength = fixoffset-fixonset;
    
    if orderlist((i)) == 1
        Screen('DrawTexture',w,goRight);
        answer = 1;
        condition = 'go';
        answer_log = 'right';
        direction = 'right';
    elseif orderlist((i)) == 2
        Screen('DrawTexture',w,goLeft);
        answer = 2;
        condition = 'go';
        direction = 'left';
        answer_log = 'left';
    elseif orderlist((i)) == 3
        answer = 0;
        Screen('DrawTexture',w,goRight);
        condition = 'stoparrow';
        direction = 'right';  
        answer_string_go = 'right ';
        Screen('Flip',w);
        stoponset_getsec = GetSecs; %this is for potential solution
        WaitSecs(ssd)
        Screen('DrawTexture',w,signalShape);
        condition = 'stopsignal';
        answer_string = 'stop signal';
        answer_log = strcat(answer_string_go, answer_string);
    elseif orderlist((i)) == 4
        answer = 0;
        Screen('DrawTexture',w,goLeft);
        condition = 'stoparrow';
        direction = 'left';
        answer_string_go = 'left ';
        Screen('Flip',w);
        stoponset_getsec = GetSecs; %this is for potential solution
        WaitSecs(ssd)
        Screen('DrawTexture',w,signalShape);
        condition = 'stopsignal';
        answer = 0;
        answer_string = 'stop signal';
        answer_log = strcat(answer_string_go, answer_string);
    elseif orderlist((i)) == 5
        Screen('DrawTexture',w,fix_shape);
        answer = 3;
        condition = 'null';
        direction = 'null';
        answer_log = 'null';
    else
        fprintf('\n something went wrong \n')
    end
   
    [vbl, timeStart2] = Screen('Flip',w);
    %stimonset = GetSecs-timeStart; % for stop signal, this would be onset of up arrow, not onset of arrow before
    %Potential solution
    if answer == 0
        stimonset = stoponset_getsec - timeStart;
        
    elseif answer == 1 || answer == 2 || answer == 3
        stimonset = GetSecs - timeStart;
    end 
    
    tellme = GetSecs-timeStart;
    
        %set initial time variables
    rt = 0;
    keypressed = 0;
    cue = 1;

    %RESP WINDOW
    while 1
        if answer == 1 || answer == 2 || answer == 3
            if ((GetSecs - timeStart2) > cue)
                Screen('Flip',w);
                stimoffset = GetSecs-timeStart;
                break;
            end
        elseif answer == 0  
            if ((GetSecs - timeStart2) > ss) % this does not take into account the time the side arrow is on the screen, b/c timestart2 is the time the up arrow is fliped 
                % why is this a problem? probably not a problem
                Screen('Flip',w);
                stimoffset = GetSecs-timeStart;
                break;
            end
            
        end
        %RESPONSE KEY CODES for keyboard
        [keyIsDown, keyTime, keyCode] = KbCheck(-1);
        if (find(keyCode)== KbName('1!') | find(keyCode)== KbName('2@') | find(keyCode)== KbName('3#') | find(keyCode)== KbName('4$'))
            if answer == 1 || answer == 2
                Screen('Flip',w);
                stimoffset = GetSecs-timeStart;
            elseif answer == 3
                stimoffset = GetSecs-timeStart;
            elseif answer == 0
                if ((GetSecs - timeStart2) > ssd)
                    Screen('Flip',w);
                   stimoffset = GetSecs-timeStart;
                 elseif (GetSecs - timeStart2) < ssd 
                     stimoffset = GetSecs-timeStart;
                end
            end
            break;
        end      
    end
    
    
    
    stimlength = stimoffset-stimonset;
    
    %AFTER RESPONSE, confirm key press
    if  keyCode(KbName('1!'))
        keypressed = 2;
    elseif keyCode(KbName('3#'))
        keypressed = 2;
    elseif keyCode(KbName('2@'))
        keypressed = 1;
    elseif keyCode(KbName('4$'))
        keypressed = 1;
    elseif keyCode(escKey)
        ShowCursor;
        fclose(outfile);
        Screen('CloseAll'); return
    end
   

   %determine if keypresses are correct
    if keypressed == 1 
        rt = 1000.*(keyTime-timeStart2);
        rt_string = 'yes pressed';
        if answer == 1
            ans_correct = 1;
        elseif (answer == 2 || answer == 0 || answer == 3)
            ans_correct = 0;
        end
    elseif keypressed == 2
        rt = 1000.*(keyTime-timeStart2);
        rt_string = 'yes pressed';
        if answer == 2
            ans_correct = 1;
        elseif (answer == 1 || answer == 0 || answer == 3)
            ans_correct = 0;
        end
    elseif keypressed == 0
        rt = 0;
        rt_string = 'no keypressed';
        if (answer == 1 || answer == 2)
            ans_correct = 0;
        elseif answer == 0 || answer == 3
            ans_correct = 1;
        end
    end
    
    %determine extra fixation time
    if keypressed ~= 0
       Screen('DrawTexture',w,fix_shape);
       Screen('Flip',w); 
       extrafixonset = GetSecs-timeStart;
        if answer == 0 
            WaitSecs(1 - (ss + ssd));
        elseif (answer ==1 || answer == 2 || answer == 3) %&& keypressed
            WaitSecs(1-(rt/1000));
        end 
    elseif keypressed == 0
        extrafixonset = GetSecs-timeStart;
    end
    
    extrafixoffset = GetSecs-timeStart;
    
    
    toldyou = (GetSecs-timeStart)- tellme;
    fprintf('\n told you is: %d', toldyou);
    
     %add time if answer is right, decrease time if answer is wrong
    if answer == 0
        if ssd < 0
            ssd = 0;
        elseif ssd >= 0.9
            ssd = 0.9;
        elseif keypressed == 0
            ssd = ssd + .50;
        elseif keypressed == 1
            ssd = ssd - .50;
        end
    end
    
    if ans_correct == 1
        corrString = 'correctly';
    elseif ans_correct == 0
        corrString = 'incorrectly';
    end
    
    extrafixlength = extrafixoffset- extrafixonset;
    
    fprintf('\nTrial Number: %d\ncondition currently shown: %s\n',i,answer_log);
    fprintf('\n Subject  answered: %s\n', corrString);
    fprintf('\n Subject  RT: %s\t %d', rt_string, rt);
    
    trialoffset = GetSecs-timeStart;
    triallength = trialoffset-trialonset;
   
    %Write to Log File
    if isscan == 0
        fprintf(practicelogfile, '\n%s\t%d\t%.8f\t%.8f\t%.8f\t%.8f\t%.8f\t%.8f\t%.8f\t%.8f\t%s\t%s\t%d\t%.8f\t', record_id,i, trialonset, triallength,stimonset, stimlength, fixonset, fixlength, extrafixonset, extrafixlength,condition, direction, ans_correct, rt);
    else
        fprintf(logfile, '\n%s\t%d\t%.8f\t%.8f\t%.8f\t%.8f\t%.8f\t%.8f\t%.8f\t%.8f\t%s\t%s\t%d\t%.8f\t',record_id,i, trialonset, triallength, stimonset, stimlength, fixonset, fixlength,extrafixonset,extrafixlength, condition,direction, ans_correct, rt);
    end

    
end 
toc
%end everything 
Screen('FillRect',w,black);
DrawFormattedText(w,'Great job! This concludes the session.','center','center', white);
Screen('Flip',w);
WaitSecs(3);

toc;
totaltime = toc/60;
fprintf('\n total time for this block was: %d minutes',totaltime);


Screen('CloseAll');
sca;

  