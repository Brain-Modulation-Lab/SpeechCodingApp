function addCodeWithButton(codeInput,handles,hObject);
%adds each IPA symbol to transcription.
axes(handles.axes6); %set(handles.axes6, 'Color', 'none')
CurrentPhoneticCode=getappdata(0, 'CurrentPhoneticCode');
if ~isempty(CurrentPhoneticCode) && ~strcmp(' ',CurrentPhoneticCode)
    new=[getappdata(0, 'CurrentPhoneticCode'), codeInput];
elseif isempty(CurrentPhoneticCode) || isstrprop(CurrentPhoneticCode,'wspace')
    new=[codeInput];
end
ind=[0 regexp(new, '/','end')];
newLength=length(codeInput);
setappdata(0, 'ind', ind);
setappdata(0, 'newLength', newLength);
setappdata(0, 'PreviousCode', CurrentPhoneticCode);
setappdata(0, 'CurrentPhoneticCode', new); 
h=handles.axes6.Children;
if ~isempty(h)
    delete(findobj(h, 'Type', 'image'))
end
%packages= {'graphicx',{'fontenc','T1'},'tipa','tipx'};
img=lateximage(10,10, new,'EquationOnly',false, 'LatexPackages', ...
    {'graphicx',{'fontenc','T1'},'tipa','tipx'},'HorizontalAlignment','center','FontSize',20, 'OverSamplingFactor',1);
axis off
%figure(handles.figure1)
guidata(hObject, handles);   
end