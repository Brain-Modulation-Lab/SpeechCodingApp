function browsingMarkers(hObject,handles,toDo, modifyMarker);

if isempty(get(handles.MarkCat, 'Value')) || isempty( get(handles.MarkOnOff, 'Value'))
    set(handles.MarkInstance, 'Value', []);
    set(handles.MarkInstance, 'String', []);
end
if ~isempty(get(handles.MarkCat, 'Value')) && ~isempty(get(handles.MarkOnOff, 'Value'))
    cfg=getappdata(0,'cfg');
    currCFG=cfg{get(handles.MarkCat,'Value'),get(handles.MarkOnOff, 'Value')} ;
    listName=currCFG{1};
    handName=currCFG{2};
    lineColor=currCFG{3};
    lineStyle=currCFG{4};
    marks=getappdata(0, listName);
    if toDo == 0 %toDo=0 shows list of marks for given type/on/off 
        set(handles.MarkInstance, 'String', marks);
        set(handles.MarkInstance,'Value', []);
        guidata(hObject,handles);
    end
    if toDo == 1 %toDo=1 creates a new marker with button click
        %fprintf('this should make a new marker')
        axes(handles.axes3) %select spectrogram
        [t,~] = ginput(1);
        nMarked=length(marks);
        if nMarked==0 %not sure why this is needed...
            fprintf('nMarked==0')
            marks={num2str(t)};
        else
            %when nMarked~=0, a new mark is added.
            marks(nMarked+1)={num2str(t)};
        end
        YLim=[0 10000];
        %plot new line with tag handName + mark number (ex. h_onset2)
        hold on; plotMarker(nMarked+1) = plot(handles.axes3, t*[1 1], YLim, lineColor, ...
            'linewidth', 1, 'LineStyle', lineStyle,'Tag', [handName num2str(nMarked+1)]);
        set(handles.MarkInstance, 'String', marks)
        setappdata(0, listName, marks) %saved list of marks
        guidata(hObject,handles) ;
    elseif toDo == 2 %selects the time a specifc time/marker
        %fprintf('this should grab the current marker')
        %get listbox string
        set(findobj(handles.axes3.Children,'LineWidth', 1.5),'LineWidth',1);
        marks=get(handles.MarkInstance, 'String');
        selectedValue=get(handles.MarkInstance, 'Value');
        if selectedValue>0
            set(findobj(handles.axes3.Children,'Tag', [handName num2str(selectedValue)]),'LineWidth', 1.5);
        end
        if modifyMarker ==1 %allows to change the selected marker to a new selection
            fprintf('modifyMarker==1')
            [t,~] = ginput(1);
            set(findobj(handles.axes3.Children,'Tag', [handName num2str(selectedValue)]),'XData', [t t]);
            marks(selectedValue)={num2str(t)};
        elseif modifyMarker == 2 %deletes the marker
            fprintf('modifyMarker==2')
            delete(findobj(handles.axes3.Children,'Tag', [handName num2str(selectedValue)]));
            marks(selectedValue)=[];
            set(handles.MarkInstance, 'Value', []);
        end
        set(handles.MarkInstance, 'String', marks);
        setappdata(0, listName, marks); %saved list of marks
        guidata(hObject,handles) ;
    end
end
end