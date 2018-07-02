function updateCodingMatrix(hObject, eventdata, handles)
% Updates CodingMatrix for the current trial transcribed (before moving to
% next trial or closing)
%[takes whatever is coded currently and saves it to the]
trial=getappdata(0, 'trial');
RandList=getappdata(0, 'RandomizedList');
CodingMat=getappdata(0, 'CodingMat');

%speed=getappdata(0, 'AudioSpeed');
%global CodingMat;

%Coding Mat Rows:
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
% %13. Notes for current trial
%%14. Stressors binary. [0 0 0]

CodingMat(1:12,RandList(trial))= ...
    {getappdata(0,'CurrentPhoneticCode'); ...
     {get(handles.C1errorInput, 'String'), ...
     get(handles.VerrorInput, 'String'), ...
     get(handles.C2errorInput, 'String')}; ...
     getappdata(0, 'AudioOnset'); ...
     getappdata(0, 'AudioOffset'); 
    getappdata(0, 'VowelOnset'); ...
    getappdata(0, 'VowelOffset'); ...
    getappdata(0, 'PreOnset'); ...
        getappdata(0, 'PreOffset'); ...
        getappdata(0, 'PostOnset');...
        getappdata(0, 'PostOffset'); ...
        getappdata(0, 'OOnset'); ...
       getappdata(0, 'OOffset')};

%------sets coding for non-task events
%CodingMat(13, RandList(trial))={get(handles.notesTextBox, 'String')};
CodingMat{13, RandList(trial)}={[get(handles.notesTextBox, 'String')];[get(handles.pre_type,'Value'), ...
    get(handles.post_type,'Value'),get(handles.other_type1,'Value'),get(handles.other_type2,'Value'), ...
    get(handles.other_type3,'Value')]};

%------sets coding for 
%CodingMat{14,RandList(trial)}=[get(handles.stress1,'Value'), get(handles.stress2,'Value'), get(handles.stress3,'Value')];
CodingMat{14,RandList(trial)}= [get(handles.stress1,'Value'), get(handles.stress2,'Value'), get(handles.stress3,'Value');
    get(handles.C1_incorrect,'Value'), get(handles.C2_incorrect,'Value') ,get(handles.C3_incorrect,'Value');
    get(handles.V1_incorrect,'Value'), get(handles.V2_incorrect,'Value') ,get(handles.V3_incorrect,'Value');
    get(handles.C1_disorder,'Value'),get(handles.C2_disorder,'Value'),get(handles.C3_disorder,'Value');
    get(handles.V1_disorder,'Value'), get(handles.V2_disorder,'Value'),get(handles.V3_disorder,'Value')];

if get(handles.MarkUncodable,'Value')>0
     CodingMat{1,RandList(trial)}=NaN;
end

setappdata(0, 'CodingMat', CodingMat);
guidata(hObject, handles);


