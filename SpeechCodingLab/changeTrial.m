function changeTrial(hObject, eventdata, handles, trial, previous)
% trial= new trial. when randomized will be the next in perm. list: ex:
% random trial 4 = true trial 23, previous trial 3 = true trial 90;

% %trial here is the randomized trial (i.e. RandomizedTrial(trial)), not
% %actual trial number.
CodingMat=getappdata(0, 'CodingMat');

if trial>0 && trial<=getappdata(0,'numTrials');
    if ~previous==0 %make sure doesnt go out of bounds
        updateCodingMatrix(hObject, eventdata, handles);
    end
    if sum(~cellfun('isempty',CodingMat(2:end,trial)))==0 %if there was no info about new trial previously, set to []
        %set(hAnnotChildren, 'String', []); %I dont know what this is any more.
        set(handles.C1errorInput, 'String', []);
        set(handles.VerrorInput, 'String', []);
        set(handles.C2errorInput, 'String', []);
        setappdata(0,'AudioOnset', []);
        setappdata(0,'AudioOffset', []);
        setappdata(0,'VowelOnset', []);
        setappdata(0,'VowelOffset', []);
        setappdata(0,'PreOnset', []);
        setappdata(0,'PreOffset', []);
        setappdata(0,'PostOnset', []);
        setappdata(0,'PostOffset', []);
        setappdata(0,'OOnset', []);
        setappdata(0,'OOffset', []);
        set(handles.notesTextBox, 'String', []);
        set(handles.pre_type,'Value',1);
        set(handles.post_type,'Value',1);
        set(handles.other_type1,'Value',1);
        set(handles.other_type2,'Value',1); 
        set(handles.other_type3,'Value',1); 
        set(handles.C1_incorrect,'Value',0);
        set(handles.C2_incorrect,'Value',0);
        set(handles.C3_incorrect,'Value',0);
        set(handles.V1_incorrect,'Value',0);
        set(handles.V2_incorrect,'Value',0);
        set(handles.V3_incorrect,'Value',0);
        set(handles.C1_disorder,'Value',1);
        set(handles.C2_disorder,'Value',1);
        set(handles.C3_disorder,'Value',1);
        set(handles.V1_disorder,'Value',1);
        set(handles.V2_disorder,'Value',1);
        set(handles.V3_disorder,'Value',1);
        set(handles.stress1,'Value', 0);
        set(handles.stress2,'Value', 0);
        set(handles.stress3,'Value', 0);
    else %sets appdata to what was coded before for new trial
        set(handles.C1errorInput, 'String', CodingMat{2,trial}{1,1}); %set(handles.C1errorInput, 'String', CodingMat{2,trial});
        set(handles.VerrorInput, 'String', CodingMat{2,trial}{1,2}); %set(handles.VerrorInput, 'String', CodingMat{3,trial});
        set(handles.C2errorInput, 'String', CodingMat{2,trial}{1,3}); %set(handles.C2errorInput, 'String', CodingMat{4,trial});
        setappdata(0,'AudioOnset', CodingMat{3,trial});
        setappdata(0,'AudioOffset', CodingMat{4,trial});
        setappdata(0,'VowelOnset', CodingMat{5,trial});
        setappdata(0,'VowelOffset', CodingMat{6,trial});
        setappdata(0,'PreOnset', CodingMat{7,trial});
        setappdata(0,'PreOffset', CodingMat{8,trial});
        setappdata(0,'PostOnset', CodingMat{9,trial});
        setappdata(0,'PostOffset', CodingMat{10,trial});
        setappdata(0,'OOnset', CodingMat{11,trial});
        setappdata(0,'OOffset', CodingMat{12,trial});
        if size(CodingMat{14,trial},1)==5
            set(handles.stress1,'Value', CodingMat{14,trial}(1,1));
            set(handles.stress2,'Value', CodingMat{14,trial}(1,2));
            set(handles.stress3,'Value', CodingMat{14,trial}(1,3));
            set(handles.C1_incorrect,'Value', CodingMat{14,trial}(2,1));
            set(handles.C2_incorrect,'Value', CodingMat{14,trial}(2,2));
            set(handles.C3_incorrect,'Value', CodingMat{14,trial}(2,3));
            set(handles.V1_incorrect,'Value', CodingMat{14,trial}(3,1));
            set(handles.V2_incorrect,'Value', CodingMat{14,trial}(3,2));
            set(handles.V3_incorrect,'Value', CodingMat{14,trial}(3,3));
            set(handles.C1_disorder,'Value', CodingMat{14,trial}(4,1));
            set(handles.C2_disorder,'Value', CodingMat{14,trial}(4,2));
            set(handles.C3_disorder,'Value', CodingMat{14,trial}(4,3));
            set(handles.V1_disorder,'Value', CodingMat{14,trial}(5,1));
            set(handles.V2_disorder,'Value', CodingMat{14,trial}(5,2));
            set(handles.V3_disorder,'Value', CodingMat{14,trial}(5,3));
        elseif isequal(size(CodingMat{14,trial}),[1,3])
            set(handles.stress1,'Value', CodingMat{14,trial}(1));
            set(handles.stress2,'Value', CodingMat{14,trial}(2));
            set(handles.stress3,'Value', CodingMat{14,trial}(3));
            set(handles.C1_incorrect,'Value',0);
            set(handles.C2_incorrect,'Value',0);
            set(handles.C3_incorrect,'Value',0);
            set(handles.V1_incorrect,'Value',0);
            set(handles.V2_incorrect,'Value',0);
            set(handles.V3_incorrect,'Value',0);
            set(handles.C1_disorder,'Value',1);
            set(handles.C2_disorder,'Value',1);
            set(handles.C3_disorder,'Value',1);
            set(handles.V1_disorder,'Value',1);
            set(handles.V2_disorder,'Value',1);
            set(handles.V3_disorder,'Value',1);
        end
        if ischar(CodingMat{13,trial})
            set(handles.notesTextBox, 'String', CodingMat{13,trial});
            set(handles.pre_type,'Value',1);
            set(handles.post_type,'Value',1);
            set(handles.other_type1,'Value',1);
            set(handles.other_type2,'Value',1); 
            set(handles.other_type3,'Value',1); 
        else
            set(handles.notesTextBox, 'String', CodingMat{13,trial}{1});
            set(handles.pre_type,'Value',CodingMat{13,trial}{2}(1));
            set(handles.post_type,'Value',CodingMat{13,trial}{2}(2));
            set(handles.other_type1,'Value',CodingMat{13,trial}{2}(3));
            set(handles.other_type2,'Value',CodingMat{13,trial}{2}(4));
            set(handles.other_type3,'Value',CodingMat{13,trial}{2}(5));
        end
    end


    if isempty(CodingMat{1,trial})
        setappdata(0, 'CurrentPhoneticCode', ' ');
        set(handles.MarkUncodable,'Value',0)
    elseif isnan(CodingMat{1,trial})
        set(handles.MarkUncodable,'Value',3)
        setappdata(0, 'CurrentPhoneticCode', ' ');
    else
        setappdata(0, 'CurrentPhoneticCode', CodingMat{1,trial});
        set(handles.MarkUncodable,'Value',0)
    end

    %the value here for trial is the actual trial so it needs to be
    %converted back to the randomized form using (find(randtrial==trial))
    RandList=getappdata(0, 'RandomizedList');
    set(handles.dropDownStim,'Value', find(RandList==trial));
    setappdata(0, 'trial', find(RandList==trial));
    
    %reset checkboxes/radiobuttons
    set(handles.showWord,'Value',0);
    set(handles.showTokenID,'Value',0);
    set(handles.showTokenID, 'String', 'Token ID')
    set(handles.showWord, 'String', 'Show Stimulus')
    set(handles.MarkOnOff,'Value', [])
    set(handles.MarkCat, 'Value', [])
    set(handles.MarkInstance, 'Value', []);
    set(handles.MarkInstance, 'String',[]);
    
    %set new trial's phonetic code
    axes(handles.axes6);
    h=handles.axes6.Children;
    new=getappdata(0, 'CurrentPhoneticCode');
    
    if ~isempty(new)
        setappdata(0, 'ind', [0 regexp(new, '/','end')]);
    else
        setappdata(0, 'ind', []);
    end
    
    
    if ~isempty(h)
        delete(findobj(h, 'Type', 'image'));
    end
    
    packages= {'graphicx',{'fontenc','T1'},'tipa','tipx'};
    img=lateximage(10,10, new,'EquationOnly',false, 'LatexPackages',packages,'HorizontalAlignment','center','FontSize',20, 'OverSamplingFactor',1);
    axis off

    AudioTrials=getappdata(0,'AudioTrials');
    sf = getappdata(0,'Afs');
    updateCodingMatrix(hObject, eventdata, handles);
    setappdata(0,'AudioSpeed',1)
    set(handles.PlaySpeedText, 'String', '1.0')
    %changeSpectrogram(AudioTrials{trial}, sf, getappdata(0, 'AudioSpeed'), hObject, handles);
    changeSpectrogram(AudioTrials{trial}, sf, getappdata(0, 'AudioSpeed'), handles.axes3);
    play(getappdata(0,'PlayAudio'));
    guidata(hObject,handles);
end

