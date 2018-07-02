function    changeSpectrogram(AudioTrial, sf, speed, axes3) %hObject, handles)
%makes matrix of all data needed for plotting spectrograms;
% [h_onset, h_offset, h_Vonset, h_Voffset, h_PreOnset, h_PreOffset, h_PostOnset, h_PostOffset, h_OOnset, h_OOffset]
%global CodingMat
AudioStart=1;
[~,f,t,p] = spectrogram(AudioTrial, 128,7/8*128, [], sf, 'power', 'yaxis');
p0 = mean(reshape(p(1:100, :), 1, [])); %baseline signal
p = 20*log10(p./p0); %decibel calculation
axes(axes3); %all axes3 references used to be handles.axes3
hold off
pcolor(t, f, p); ylim([0 10000]); shading interp; colormap jet;
hold on;
h= plot([0 0], ylim, 'k', 'linewidth', 1);
cfg=getappdata(0,'cfg');
for catag=1:5
    for timing=1:2;
        if ~isempty(getappdata(0, cfg{catag,timing}{1}))
            marks=getappdata(0, cfg{catag,timing}{1});
            for i=1:length(marks);
                hold on; h_onset(i) = plot(axes3, [str2num(marks{i}) str2num(marks{i})], ylim, cfg{catag,timing}{3}, 'linewidth', 1,  'LineStyle', cfg{catag,timing}{4}, 'Tag', [cfg{catag,timing}{2} num2str(i)]);
            end
        end
    end
end
drawnow;
%% setup the timer for the audioplayer object
player = audioplayer(AudioTrial(AudioStart:end), (speed*sf));
player.TimerFcn = {@plotMarker, player, h, sf}; % timer callback function
player.TimerPeriod =0.1; % period of the timer in seconds
setappdata(0, 'sf', sf);
setappdata(0, 'PlayAudio', player);
  
    

%% the timer callback function definition
function plotMarker(...
    obj, ...            % refers to the object that called this function (necessary parameter for all callback functions)
    eventdata, ...      % this parameter is not used but is necessary for all callback functions
    player, ...         % audioplayer object to the callback function
    h, ...              % marker handle
    fs)                 % sampling frequency

% check if sound is playing, then only plot new marker
if strcmp(player.Running, 'on')

    % update marker
    h.XData = player.CurrentSample*[1 1]/fs;%player.SampleRate;

end
    
