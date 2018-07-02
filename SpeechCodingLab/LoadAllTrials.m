function [numTrials, AudioTrials] =LoadAllTrials(AudioData) 

EventsPerTrial = 3;
if isfield(AudioData, 'SpeechTrials')    
    numTrials = size(AudioData.SpeechTrials,1);   
    allAfs = unique([AudioData.SpeechTrials{:,2}]);
    if length(allAfs)>1
        Afs = min(allAfs);
        %AudioTrials before was SpeechTrials
        AudioTrials = cellfun(@(x,y) resample(x, Afs, y), ...
            AudioData.SpeechTrials(:,4), AudioData.SpeechTrials(:,2), ...
            'uniformoutput', false); 
    else
        AudioTrials = AudioData.SpeechTrials(:,4);
        %SpeechTrials = AudioData.SpeechTrials(:,4);
    end
    %AudioTrials = SpeechTrials;   
else
    numTrials=floor((length(AudioData.EventTimes)-AudioData.SkipEvents)/EventsPerTrial);
    EventTimes1 = [AudioData.EventTimes AudioData.EventTimes(end)+2];
    AudioTrials=cell(1,numTrials);
    for i=1:numTrials      
        StimulusEvent1 = AudioData.SkipEvents + EventsPerTrial*i;
        StimulusEvent2 = AudioData.SkipEvents + EventsPerTrial*i + 1;        
        sf=AudioData.Afs;        
        preStim = 0;
        postStim = 1;
        AudioTrials{i} = AudioData.Audio((round(sf*(EventTimes1(StimulusEvent1)-preStim))+1): ...
            min([round(sf*(EventTimes1(StimulusEvent2)+postStim)) length(AudioData.Audio)]));        
        %CurrAudioTrial = AudioData.Audio((round(sf*(EventTimes1(StimulusEvent1)-preStim))+1): ...
        %    min([round(sf*(EventTimes1(StimulusEvent2)+postStim)) length(AudioData.Audio)]));        
        %AudioTrials{i} = CurrAudioTrial;
    end
end
AudioTrials = cellfun(@(x) (2*(x - mean(x))/ (max(x) - min(x))), AudioTrials, 'uniformoutput',false);

