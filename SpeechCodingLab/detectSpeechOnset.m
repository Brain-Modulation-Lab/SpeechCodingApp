function tonset = detectSpeechOnset(spect, t, f, baseWind, earliest)
pb = 0;
base = spect(:,baseWind);
basestd = std(base,0,2);
basemean = mean(base,2);
thresh = basemean + 3*basestd;
thresh = repmat(thresh, 1, size(spect,2));
loud = spect > thresh;
howloud = sum(loud);

isloud = howloud > 2.5;
loudlabel = bwlabel(isloud);
tthresh = 10;
onseti = -1;
for ii = 1:(length(unique(loudlabel))-1)
    sect = find(loudlabel == ii);
    if length(sect) >= tthresh && onseti==-1 && sect(1) >= earliest
        onseti = sect(1);
    end
end


if onseti ~= -1
    tonset = onseti;
    if pb == 1
        figure;
        pcolor(t, f, spect); shading flat;
        ah = gca;
        hold on; plot([t(tonset) t(tonset)], ah.YLim, 'k');
    end
else
    disp('Nothing detected');
    tonset = -1;
end


