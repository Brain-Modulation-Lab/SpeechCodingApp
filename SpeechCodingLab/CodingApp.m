
function varargout = CodingApp(varargin)
% CODINGAPP MATLAB code for CodingApp.fig
%      CODINGAPP, by itself, creates a new CODINGAPP or raises the existing
%      singleton*.
%
%      H = CODINGAPP returns the handle to a new CODINGAPP or the handle to
%      the existing singleton*.
%
%      CODINGAPP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CODINGAPP.M with the given input arguments.
%
%      CODINGAPP('Property','Value',...) creates a new CODINGAPP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CodingApp_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CodingApp_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

%Variable names that aren't obvious.
%notesTextBox= notes for current trial
%showWord= toggle button to reveal presented stimuli, marks 1 in
%codingmat{,7}
%showTokenID= toggles to show non-randomized ID number of sample trial
%(i.e. trialnum.samplefilenumber)
%MarkUncodable= 'Uncodable' button; for current trial, replaces CodingMat phonetic 
%code to 'NaN' and writes 'uncodable' in notes (codingmat rows 1 and 8
%respectively).
%axis3=spectrogram of audio
%axis6=phonetic coding on app/prints LaTex image
%IPAbuttons= panel of buttons for IPA
% App variables:
% RandomizedList=permuted list of length num trials...where trueTrialNum=randomizedList(i)
% trial = index of Randomizedlist; back/next are trial ± 1 (i.e.
% trueTrialNum=randomizedList(trial);
% fname=filename 
% CodingMat Rows:
% %1. phonetic code in LaTex separated by '/'.
% % 2. 1st, 2nd, 3rd Syllable error
% %3. Syl onset time
% %4. Syl offset time
% %5. Vowel onset
% %6. Vowel offset
% %7. Preword onset times
% %8. Preword offset times
% %9. Postword onset times
% %10. Postword offset times
% %11. Other onset times
% %12. Other offset times
% %13. Notes for current trial --> change this to all non-task event info
%%14. Stressors binary. [0 0 0] --> change this to all task event info


% Edit the above text to modify the response to help CodingApp
% Last Modified by GUIDE v2.5 21-Jun-2018 12:23:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CodingApp_OpeningFcn, ...
                   'gui_OutputFcn',  @CodingApp_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before CodingApp is made visible.
function CodingApp_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CodingApp (see VARARGIN)

% Choose default command line output for CodingApp
handles.output = hObject;

% Update handles structure
CodingMat=cell(14,120);
setappdata(0,'CodingMat', CodingMat);
warning('off','all')

if ispc
    % dos('set PATH=%PATH%;C:\Program Files (x86)\MiKTex 2.9');
else
path1='/usr/bin:/bin:/usr/sbin:/sbin';
setenv('PATH', [path1 ':/Library/TeX/texbin/']);
end

guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using CodingApp.
set(handles.axes6,'Visible','off')
set(handles.axes6, 'Color', 'none')
setappdata(0,  'CurrentPhoneticCode', '');

if strcmp(get(hObject,'Visible'),'off')
    axes(handles.axes3); 
    plot(rand(1));   
end
set(handles.dropDownStim,'String', ' ');
set(handles.dropDownStim,'Value', 1);

set(handles.figure1, 'KeyPressFcn', @keyboardinput)

% --- Outputs from this function are returned to the command line.
function varargout = CodingApp_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% -------------------------------------------------------------------
% -----------------BASIC FUNCTIONS-----------------
% -------------------------------------------------------------------

function updateoutputcell_Callback(hObject, eventdata, handles)
% hObject    handle to updateoutputcell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%trial=randi(120); %change to actual trial number. 
updateCodingMatrix(hObject, eventdata, handles);

function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function axes6_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to axes6 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% handles=guihandles; % get me current handle definitions
% keypressed=get(handles.figure1,'CurrentCharacter')
% PreviousString=getappdata(0, 'CurrentPhoneticCode');
% 

function showWord_Callback(hObject, eventdata, handles)
% hObject    handle to showWord (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%get word at current trial.
%change using set(h0bject,'String', currentWord)

% Hint: get(hObject,'Value') returns toggle state of showWord
if (get(hObject,'Value') == get(hObject,'Max'))
	WL=getappdata(0, 'WordList');
    trial=getappdata(0, 'trial');
    RandList=getappdata(0, 'RandomizedList');
    hObject.String= WL{RandList(trial)};
    %global CodingMat
    %CodingMat(7,RandList(trial))={1};
else
    hObject.String='Show Stimulus';
end

guidata(hObject, handles);

function writeLog
	% Alert user via the command window and a popup message.
	%user=char( getHostName( java.net.InetAddress.getLocalHost ) );
    version='1.3 (11/07/16)';
    filename=getappdata(0,'fname');
    fid = fopen('log.txt','at');
    fprintf(fid, '%s :: %s modified by [ %s ] using Phonetic Coding App v. %s\n', datestr(now), filename(1:end-4), version);
 	fclose(fid);
  
function MarkUncodable_Callback(hObject, eventdata, handles)
% hObject    handle to MarkUncodable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%         end
%         disp(checked)
% Hint: get(hObject,'Value') returns toggle state of MarkUncodable
%uncodable=get(hObject,'Value');
 if get(hObject,'Value')>0
     setappdata(0, 'CurrentPhoneticCode', ' ');
 end
 guidata(hObject, handles);

% -------------------------------------------------------------------
% -----------------TRIAL SELECTION-----------------
% -------------------------------------------------------------------

function dropDownStim_Callback(hObject, eventdata, handles)
% hObject    handle to dropDownStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns dropDownStim contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dropDownStim

%Executes change trial from dropdown menu.
getpixelposition(hObject);
previousTrial=getappdata(0, 'trial');
trial=get(hObject, 'Value'); %trial is the index of the actual randomized list. 
RandList=getappdata(0, 'RandomizedList');
changeTrial(hObject, eventdata, handles, RandList(trial), RandList(previousTrial));
handles = guidata(hObject);
guidata(hObject,handles);

function dropDownStim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dropDownStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

setappdata(0, 'trial', 1);
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');     
end
guidata(hObject,handles);

function BackButton_Callback(hObject, eventdata, handles)
% hObject    handle to BackButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
currentTrial=getappdata(0, 'trial');
RandList=getappdata(0, 'RandomizedList');
if  (currentTrial-1)>0
changeTrial(hObject, eventdata, handles, RandList(currentTrial-1), RandList(currentTrial))
handles = guidata(hObject);
end;

function NextButton_Callback(hObject, eventdata, handles)
% hObject    handle to NextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
currentTrial=getappdata(0, 'trial');
RandList=getappdata(0, 'RandomizedList');
if (currentTrial+1)<=getappdata(0,'numTrials')
    changeTrial(hObject, eventdata, handles, RandList(currentTrial+1), RandList(currentTrial))
    handles = guidata(hObject);
end
  guidata(hObject,handles);

% -------------------------------------------------------------------
% -----------------FILE OPEN/SAVE/CLOSE------------
% -------------------------------------------------------------------
 
function open_toolbar_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to open_toolbar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fname, path] = uigetfile('*.mat', 'Select Subject Audio file');
if fname~=0
filename=strcat(path, fname);
AudioData=load(filename);
setappdata(0,'trial', 1);
setappdata(0,'AudioSpeed', 1.0);
setappdata(0,'fname', fname);    
if isfield(AudioData, 'cfg')
    setappdata(0,'cfg', AudioData.cfg);
end
if isfield(AudioData, 'SpeechTrials') %for loading preprocessed pilot data
    Afs = unique([AudioData.SpeechTrials{:,2}]);
    setappdata(0,'Afs', min(Afs));
    setappdata(0,'WordList', AudioData.SpeechTrials(:,5));
    if isfield(AudioData, 'CodingMatrix')
        CodingMat=AudioData.CodingMatrix;
        global CodingMat
        if size(CodingMat,1)==8
            CodingMat(9:10,:) = cell(2,size(CodingMat,2));
        end
    else
        if size(AudioData.SpeechTrials,2)==15
            CodingMat=AudioData.SpeechTrials(:,8:15)';
            CodingMat(9:10,:) = cell(2,size(AudioData.SpeechTrials,1));
        elseif size(AudioData.SpeechTrials,2)==17
            CodingMat=AudioData.SpeechTrials(:,8:17)';
        end
    end
    setappdata(0, 'CodingMat', CodingMat);
    %assignin('base', 'CodingMat', CodingMat);
else
    setappdata(0,'Afs', AudioData.Afs); %for U01 data before combining all data types
    setappdata(0,'WordList', AudioData.WordList); %should be 1 x 120 matrix
    if isfield(AudioData, 'CodingMatrix') %if coding has already been completed
        %global CodingMat
        CodingMat=AudioData.CodingMatrix;
        if size(CodingMat,1)==8 %for coding done before vowel marking was added
            CodingMat(9:10,:) = cell(2,size(CodingMat,2));
        end
        setappdata(0, 'CodingMat', CodingMat);
        %assignin('base', 'CodingMat', CodingMat);   %loads matrix to workspace
    end
end
[numTrials, AudioTrials] =LoadAllTrials(AudioData);
randomize = questdlg('Randomize Trials?', ...
	'Trial order', ...
	'Yes','No','Yes');
if strcmp(randomize,'Yes')
    RandomizedList=randperm(numTrials); %permuted trial list w/ length numTrials
else
    RandomizedList=(1:numTrials);
end   
setappdata(0, 'RandomizedList', RandomizedList);
setappdata(0, 'AudioTrials', AudioTrials);
setappdata(0, 'numTrials', numTrials);
%set actual trial number to be first value in permuted list 
changeTrial(hObject, eventdata, handles, RandomizedList(1), 0); 
handles = guidata(hObject);
 for TrialNum=1:numTrials
     ListNames{TrialNum}=sprintf('Word %d', TrialNum);
 end
set(handles.dropDownStim, 'String', ListNames);
set(handles.figure1, 'KeyPressFcn', @keyboardinput)
guidata(hObject,handles);
end

 function save_toolbar_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to save_toolbar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateCodingMatrix(hObject, eventdata, handles);
guidata(hObject,handles);
writeLog
%global CodingMat
CodingMatrix=getappdata(0,'CodingMat');
fname=getappdata(0, 'fname');
if exist(fname, 'file')
    save(fname, 'CodingMatrix', '-append')
    close()
else %if ~exist(fname, 'file')
        selection1 = questdlg(['Can''t find session file ''' fname, '''.', sprintf('\n'), 'Would you like to select the correct output directory?'], 'Select Directory', 'Yes','Quit','Go Back','Go Back') %, opts);
        if strcmp(selection1,'Quit')
            close()
        elseif strcmp(selection2,'Yes')
            folder = uigetdir();
            if ispc
                sname=strcat(folder,'\', fname);
            else
                sname=strcat(folder,'/', fname);
            end
            save(sname, 'CodingMatrix', '-append')
            close()
        end
end %close() 


function EndButton_Callback(hObject, eventdata, handles)
% hObject    handle to EndButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%[filename, pathname] = uiputfile('*.mat', 'Save Workspace as')
selection = questdlg(['Save ' get(handles.figure1,'Name') '?'],...
                     ['Save ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    %return;
    close()
elseif strcmp(selection,'Yes')
    updateCodingMatrix(hObject, eventdata, handles);
    guidata(hObject,handles);
    writeLog
    %global CodingMat
    CodingMatrix=getappdata(0,'CodingMat');
    fname=getappdata(0, 'fname');
    if exist(fname, 'file')
        save(fname, 'CodingMatrix', '-append')
        close()
    else %if ~exist(fname, 'file')
        opts.Default =  'Go Back';
        %opts.Interpreter = 'latex';
        %quest=strcat('Session file ''', fname, ''' can not be found.',  sprintf('\n'), 'Would you like to', sprintf('^{select}'), 'the correct output directory?')
        selection2 = questdlg(['Can''t find session file ''' fname, '''.', sprintf('\n'), 'Would you like to select the correct output directory?'], 'Select Directory', 'Yes','Quit','Go Back','Go Back') %, opts);
        if strcmp(selection2,'Quit')
            close()
        elseif strcmp(selection2,'Yes')
            folder = uigetdir();
            if ispc
                sname=strcat(folder,'\', fname);
            else
                sname=strcat(folder,'/', fname);
            end
            save(sname, 'CodingMatrix', '-append')
            close()
        end
    end
end

% -------------------------------------------------------------------
% -----------------TOGGLE AUDIO------------------
% -------------------------------------------------------------------

function repreataudio_Callback(hObject, eventdata, handles)
% hObject    handle to repreataudio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Player=getappdata(0,'PlayAudio');
AudioSpeed=getappdata(0,'AudioSpeed');
play(Player);
%fprintf('Speed = %f\n',AudioSpeed);
%fprintf('Player sf = %f\n',Player.SampleRate);
guidata(hObject,handles);

function play_Callback(hObject, eventdata, handles)
% hObject    handle to play (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Player=getappdata(0,'PlayAudio');
AudioSpeed=getappdata(0,'AudioSpeed');
resume(Player);
%fprintf('Speed = %f\n',AudioSpeed);
%fprintf('Player sf = %f\n',Player.SampleRate);
guidata(hObject,handles);

function pause_Callback(hObject, eventdata, handles)
% hObject    handle to pause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Player=getappdata(0,'PlayAudio');
AudioSpeed=getappdata(0,'AudioSpeed');
pause(Player);
guidata(hObject,handles);

function PlaySpeedSlider_Callback(hObject, eventdata, handles)
% hObject    handle to PlaySpeedSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

speed = get(hObject,'Value'); %returns position of slider
set(handles.PlaySpeedText, 'String', num2str(speed,'%2.1f'));
setappdata(0, 'AudioSpeed',speed);
player =  getappdata(0, 'PlayAudio');
sf =  getappdata(0, 'sf');
player.SampleRate = speed*sf;
setappdata(0, 'PlayAudio', player);
guidata(hObject,handles);

function PlaySpeedSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PlaySpeedSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function PlaySpeedText_Callback(hObject, eventdata, handles)
% hObject    handle to PlaySpeedText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 speed = str2double(get(hObject,'String')); %returns contents of edit11 as a double
 if speed>0.1 && speed<1.5
     set(handles.PlaySpeedSlider, 'Value', speed);
     setappdata(0, 'AudioSpeed',speed);
     player =  getappdata(0, 'PlayAudio');
     sf =  getappdata(0, 'sf');
     player.SampleRate = speed*sf;
     setappdata(0, 'PlayAudio', player);
 else
     set(hObject, 'String', num2str(AudioSpeed,'%3.2f'));
 end
 guidata(hObject,handles);
 
function PlaySpeedText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PlaySpeedText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% -------------------------------------------------------------------
% -----------------TRANSCRIPTION/BUTTON PRESSES--------------
% -------------------------------------------------------------------

function IPAbuttons_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IPAbuttons (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called 

function codingpanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to codingpanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
hObject.Visible='on';
guidata(hObject,handles);

function keyboardinput(hObject, eventdata, handles)
handles=guidata(hObject); % get me current handle definitions
keypressed=get(handles.figure1,'CurrentCharacter');

if ~isempty(keypressed)
    if isstrprop(keypressed,'alpha') || keypressed=='/'
        addCodeWithButton(keypressed, handles, hObject);
    elseif keypressed==char(8)
        currentCoding=getappdata(0, 'CurrentPhoneticCode');
        ind=[0 regexp(currentCoding, '/','end')]; %where the /'s are     
        if ~isempty(ind) && ~isempty(handles.axes6.Children)
            if length(ind) > 1 && ind(end)<length(currentCoding)%not the last one%the last syllable
                new=currentCoding(1:ind(end));
                setappdata(0, 'CurrentPhoneticCode', new);
            elseif length(ind)>2 &&  ind(end)==length(currentCoding)
                new=currentCoding(1:ind(end-1));
                setappdata(0, 'CurrentPhoneticCode', new);
            elseif isequal(ind,0)  || (length(ind) == 2 &&  ind(end)==length(currentCoding) )
                new=' ';
                setappdata(0, 'CurrentPhoneticCode', '');
            end
            ind=[0 regexp(new, '/','end')];
            axes(handles.axes6);
            h=handles.axes6.Children;
            delete(findobj(h, 'Type', 'image'));
            setappdata(0, 'ind', ind);
            packages= {'graphicx',{'fontenc','T1'},'tipa','tipx'};
            img=lateximage(10,10, new,'EquationOnly',false, 'LatexPackages',packages,'HorizontalAlignment','center','FontSize',20, 'OverSamplingFactor',1);
            axis off;
        end
    end
end
guidata(hObject,handles);

function sym1_Callback(hObject, eventdata, handles)
% hObject    handle to sym1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sym='a\textsci ';
addCodeWithButton(sym, handles, hObject);

function sym2_Callback(hObject, eventdata, handles)
% hObject    handle to sym2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sym='\textscripta ';
addCodeWithButton(sym, handles, hObject);

function sym3_Callback(hObject, eventdata, handles)
% hObject    handle to sym3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sym='\textscripta \textupsilon ';
addCodeWithButton(sym, handles, hObject);

function sym4_Callback(hObject, eventdata, handles)
% hObject    handle to sym4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sym='\textturnscripta ';
addCodeWithButton(sym, handles, hObject);

function sym5_Callback(hObject, eventdata, handles)
% hObject    handle to sym5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sym='\ae ';
addCodeWithButton(sym, handles, hObject);

function sym6_Callback(hObject, eventdata, handles)
% hObject    handle to sym6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sym6='\textturnv ';
addCodeWithButton(sym6, handles, hObject);

function sym65_Callback(hObject, eventdata, handles)
% hObject    handle to sym65 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sym65='\textschwa ';
addCodeWithButton(sym65, handles, hObject);

function sym75_Callback(hObject, eventdata, handles)
% hObject    handle to sym75 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sym75='\textteshlig ';
addCodeWithButton(sym75, handles, hObject);

function sym7_Callback(hObject, eventdata, handles)
% hObject    handle to sym7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sym7='\textdyoghlig ';
addCodeWithButton(sym7, handles, hObject);

function sym8_Callback(hObject, eventdata, handles)
% hObject    handle to sym8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sym8='\dh ';
addCodeWithButton(sym8, handles, hObject);

function sym9_Callback(hObject, eventdata, handles)
% hObject    handle to sym9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sym9='\textopeno ';
addCodeWithButton(sym9, handles, hObject);

function sym10_Callback(hObject, eventdata, handles)
% hObject    handle to sym10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sym10='\textopeno\textsci ';
addCodeWithButton(sym10, handles, hObject);

function sym11_Callback(hObject, eventdata, handles)
% hObject    handle to sym11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sym='\textesh ';
addCodeWithButton(sym, handles, hObject);

function sym12_Callback(hObject, eventdata, handles)
% hObject    handle to sym12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sym='\textyogh ';
addCodeWithButton(sym, handles, hObject);

function sym13_Callback(hObject, eventdata, handles)
% hObject    handle to sym13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sym='\texttheta ';
addCodeWithButton(sym, handles, hObject);

function sym14_Callback(hObject, eventdata, handles)
% hObject    handle to sym14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sym='\textupsilon ';
addCodeWithButton(sym, handles, hObject);

set(handles.figure1,'CurrentObject',findobj(handles.figure1,'Tag', 'codingpanel'))

function sym15_Callback(hObject, eventdata, handles)
% hObject    handle to sym15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sym='\textepsilon ';
addCodeWithButton(sym, handles, hObject);

function sym16_Callback(hObject, eventdata, handles)
% hObject    handle to sym16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sym='\textg ';
addCodeWithButton(sym, handles, hObject);

function sym17_Callback(hObject, eventdata, handles)
% hObject    handle to sym17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sym='\textsci ';
addCodeWithButton(sym, handles, hObject);

function sym18_Callback(hObject, eventdata, handles)
% hObject    handle to sym18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sym='\ng ';
addCodeWithButton(sym, handles, hObject);

function sym19_Callback(hObject, eventdata, handles)
% hObject    handle to sym19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sym='\textglotstop ';
addCodeWithButton(sym, handles, hObject);

function sym20_Callback(hObject, eventdata, handles)
% hObject    handle to sym20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sym='\textrhookschwa ';
addCodeWithButton(sym, handles, hObject);

function Del_Callback(hObject, eventdata, handles)
% hObject    handle to Del (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

currentCoding=getappdata(0, 'CurrentPhoneticCode');
ind=getappdata(0, 'ind'); %where the /'s are

if ~isempty(ind) && ~isempty(handles.axes6.Children)
    if length(ind) > 1 && ind(end)<length(currentCoding)%not the last one%the last syllable
        new=currentCoding(1:ind(end));
        ind=[0 regexp(currentCoding, '/','end')];
        setappdata(0, 'CurrentPhoneticCode', new);
    elseif length(ind)>2 &&  ind(end)==length(currentCoding)
        new=currentCoding(1:ind(end-1));
        ind=[];
        setappdata(0, 'CurrentPhoneticCode', new);      
    elseif isequal(ind,0)  || (length(ind) == 2 &&  ind(end)==length(currentCoding) )
        new=' ';
        ind=[];
        setappdata(0, 'CurrentPhoneticCode', '');
    end
    axes(handles.axes6);
    h=handles.axes6.Children;
    delete(findobj(h, 'Type', 'image'));
        setappdata(0, 'ind', ind);
    packages= {'graphicx',{'fontenc','T1'},'tipa','tipx'};
    img=lateximage(10,10, new,'EquationOnly',false, 'LatexPackages',packages,'HorizontalAlignment','center','FontSize',20, 'OverSamplingFactor',1);
    axis off;
    
end

guidata(hObject,handles);

% -------------------------------------------------------------------
% -----------------TIMING MARKERS-----------------
% -------------------------------------------------------------------

function MarkCat_Callback(hObject, eventdata, handles)
% hObject    handle to MarkCat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns MarkCat contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MarkCat

browsingMarkers(hObject,handles,0,0);

function MarkCat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MarkCat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function MarkOnOff_Callback(hObject, eventdata, handles)
% hObject    handle to MarkOnOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MarkOnOff contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MarkOnOff

browsingMarkers(hObject,handles,0,0);

function MarkOnOff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MarkOnOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String', {'onset'; 'offset'});
guidata(hObject,handles);

function delMark_Callback(hObject, eventdata, handles)
% hObject    handle to delMark (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

browsingMarkers(hObject,handles,2,2);

function MarkInstance_Callback(hObject, eventdata, handles)
% hObject    handle to MarkInstance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns MarkInstance contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MarkInstance
browsingMarkers(hObject,handles,2,0);

function MarkInstance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MarkInstance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function newMark_Callback(hObject, eventdata, handles)
% hObject    handle to newMark (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles = guidata(hObject);
browsingMarkers(hObject,handles,1,0);

function ModMarkers_Callback(hObject, eventdata, handles)
% hObject    handle to ModMarkers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 get(handles.MarkInstance,'Value')
if get(handles.MarkInstance,'Value')>0
browsingMarkers(hObject,handles,2,1);
end

function audioMarking_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to audioMarking (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% -------------------------------------------------------------------
%THIS STUFF IS PROBABLY OLD:
% -------------------------------------------------------------------

function showTokenID_Callback(hObject, eventdata, handles)
% hObject    handle to showTokenID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showTokenID
if (get(hObject,'Value') == get(hObject,'Max'))
    trial=getappdata(0, 'trial');
    RandList=getappdata(0, 'RandomizedList');
    %hObject.String= RandList(trial);
    fname=getappdata(0, 'fname');
    hObject.String= [num2str(RandList(trial)) '.' num2str(fname(end-5:end-4))];
else
    hObject.String='Token ID';
end

guidata(hObject, handles);

function MarkVowelOnset_Callback(hObject, eventdata, handles)
% hObject    handle to MarkVowelOnset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
axes(handles.axes3)
[t,~,button] = ginput(1); %wait for mouse input to mark when analysis should begin

if isfield(handles, 'h_Vonset')
    if ~isempty(handles.h_Vonset) && ...
            any(strcmp(properties(handles.h_Vonset), 'XData'))
        handles.h_Vonset.XData = t*[1 1];
    else
        hold on; h_Vonset = plot(t*[1 1], ylim, 'g', 'linewidth', 1);
        handles.h_Vonset = h_Vonset;
    end
else
    hold on; h_Vonset = plot(t*[1 1], ylim, 'g', 'linewidth', 1);
    handles.h_Vonset = h_Vonset;
end
setappdata(0,'VowelOnset', [t]);
updateCodingMatrix(hObject, eventdata, handles);
guidata(hObject,handles);

function MarkVowelOffset_Callback(hObject, eventdata, handles)
% hObject    handle to MarkVowelOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
axes(handles.axes3)
[t,~,button] = ginput(1); %wait for mouse input to mark when analysis should begin

if isfield(handles, 'h_Voffset')
    if ~isempty(handles.h_Voffset) && ...
            any(strcmp(properties(handles.h_Voffset), 'XData'))
        handles.h_Voffset.XData = t*[1 1];
    else
        hold on; h_Voffset = plot(t*[1 1], ylim, 'r', 'linewidth', 1);
        handles.h_Voffset = h_Voffset;
    end
else
    hold on; h_Voffset = plot(t*[1 1], ylim, 'r', 'linewidth', 1);
    handles.h_Voffset = h_Voffset;
end
setappdata(0,'VowelOffset', [t]);
updateCodingMatrix(hObject, eventdata, handles);
guidata(hObject,handles);

function MarkOnset_Callback(hObject, eventdata, handles)
% hObject    handle to MarkOnset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);
axes(handles.axes3)
[t,~,button] = ginput(1); %wait for mouse input to mark when analysis should begin

if isfield(handles, 'h_onset')
    if ~isempty(handles.h_onset) && ...
            any(strcmp(properties(handles.h_onset), 'XData'))
        handles.h_onset.XData = t*[1 1];
    else
        hold on; h_onset = plot(t*[1 1], ylim, 'k', 'linewidth', 1);
        handles.h_onset = h_onset;
    end
else
    hold on; h_onset = plot(t*[1 1], ylim, 'k', 'linewidth', 1);
    handles.h_onset = h_onset;
end
setappdata(0,'AudioOnset', [t]);
updateCodingMatrix(hObject, eventdata, handles);
guidata(hObject,handles);

function MarkOffset_Callback(hObject, eventdata, handles)
% hObject    handle to MarkOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);
axes(handles.axes3)
[t,~,button] = ginput(1); %wait for mouse input to mark when analysis should begin
if isfield(handles, 'h_offset')
    if ~isempty(handles.h_offset) && ...
            any(strcmp(properties(handles.h_offset), 'XData'))
        handles.h_offset.XData = t*[1 1];
    else
        hold on; h_offset = plot(t*[1 1], ylim, 'b', 'linewidth', 1);
        handles.h_offset = h_offset;
    end
else
    hold on; h_offset = plot(t*[1 1], ylim, 'b', 'linewidth', 1);
    handles.h_offset = h_offset;
end
setappdata(0,'AudioOffset', [t]);
updateCodingMatrix(hObject, eventdata, handles);
guidata(hObject,handles);

function C1errorInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to C1errorInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function C1errorInput_Callback(hObject, eventdata, handles)
% hObject    handle to C2errorInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of C2errorInput as text
%        str2double(get(hObject,'String')) returns contents of C2errorInput as a double

function VerrorInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VerrorInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function VerrorInput_Callback(hObject, eventdata, handles)
% hObject    handle to C2errorInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of C2errorInput as text
%        str2double(get(hObject,'String')) returns contents of C2errorInput as a double

function C2errorInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to C2errorInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function C2errorInput_Callback(hObject, eventdata, handles)
% hObject    handle to C2errorInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of C2errorInput as text
%        str2double(get(hObject,'String')) returns contents of C2errorInput as a double

% -------------------------------------------------------------------
% -----------------NON-TASK EVENTS---------------
% -------------------------------------------------------------------

function post_type_Callback(hObject, eventdata, handles)
% hObject    handle to post_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function post_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to post_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pre_type_Callback(hObject, eventdata, handles)
% hObject    handle to pre_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns pre_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pre_type

function pre_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pre_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in other_type1.
function other_type1_Callback(hObject, eventdata, handles)
% hObject    handle to other_type1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns other_type1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from other_type1


% --- Executes during object creation, after setting all properties.
function other_type1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to other_type1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function other_type2_Callback(hObject, eventdata, handles)
% hObject    handle to other_type1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns other_type1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from other_type1

function other_type2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to other_type1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in other_type3.
function other_type3_Callback(hObject, eventdata, handles)
% hObject    handle to other_type3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns other_type3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from other_type3


% --- Executes during object creation, after setting all properties.
function other_type3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to other_type3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function notesTextBox_Callback(hObject, eventdata, handles)
% hObject    handle to notesTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of notesTextBox as text
%        str2double(get(hObject,'String')) returns contents of notesTextBox as a double

% --- Executes during object creation, after setting all properties.
function notesTextBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to notesTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------
% -----------------ANNOTATION DETAILS------------
% -------------------------------------------------------------------

% --- Executes on button press in C1_incorrect.
function C1_incorrect_Callback(hObject, eventdata, handles)
% hObject    handle to C1_incorrect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of C1_incorrect

function V1_incorrect_Callback(hObject, eventdata, handles)
% hObject    handle to V1_incorrect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of V1_incorrect

function C2_incorrect_Callback(hObject, eventdata, handles)
% hObject    handle to C2_incorrect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of C2_incorrect

function V2_incorrect_Callback(hObject, eventdata, handles)
% hObject    handle to V2_incorrect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of V2_incorrect


function C3_incorrect_Callback(hObject, eventdata, handles)
% hObject    handle to C3_incorrect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of C3_incorrect

function V3_incorrect_Callback(hObject, eventdata, handles)
% hObject    handle to V3_incorrect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of V3_incorrect

function C1_disorder_Callback(hObject, eventdata, handles)
% hObject    handle to C1_disorder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns C1_disorder contents as cell array
%        contents{get(hObject,'Value')} returns selected item from C1_disorder

function C1_disorder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to C1_disorder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function C2_disorder_Callback(hObject, eventdata, handles)
% hObject    handle to C2_disorder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns C2_disorder contents as cell array
%        contents{get(hObject,'Value')} returns selected item from C2_disorder

function C2_disorder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to C2_disorder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function C3_disorder_Callback(hObject, eventdata, handles)
% hObject    handle to C3_disorder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns C3_disorder contents as cell array
%        contents{get(hObject,'Value')} returns selected item from C3_disorder

function C3_disorder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to C3_disorder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function V1_disorder_Callback(hObject, eventdata, handles)
% hObject    handle to V1_disorder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns V1_disorder contents as cell array
%        contents{get(hObject,'Value')} returns selected item from V1_disorder

function V1_disorder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to V1_disorder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function V2_disorder_Callback(hObject, eventdata, handles)
% hObject    handle to V2_disorder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns V2_disorder contents as cell array
%        contents{get(hObject,'Value')} returns selected item from V2_disorder

function V2_disorder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to V2_disorder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function V3_disorder_Callback(hObject, eventdata, handles)
% hObject    handle to V3_disorder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns V3_disorder contents as cell array
%        contents{get(hObject,'Value')} returns selected item from V3_disorder

function V3_disorder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to V3_disorder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function stress1_Callback(hObject, eventdata, handles)
% hObject    handle to stress1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of stress1

function stress2_Callback(hObject, eventdata, handles)
% hObject    handle to stress2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of stress2

function stress3_Callback(hObject, eventdata, handles)
% hObject    handle to stress3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of stress3


% --- Executes when TaskAnnot is resized.
function TaskAnnot_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to TaskAnnot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when IPAbuttons is resized.
function IPAbuttons_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to IPAbuttons (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
