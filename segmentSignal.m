function [xN, t] = segmentSignal(xN, fs, segmentDuration, startTime)
    xN = xN(fs*startTime+1 : fs*startTime +fs*segmentDuration);
    % xN = xN(i:n) = trim vector from index i to index n. 
    % fs*segmentDuration = N samples for segment as index counts from 1
    % fs*startTime = Index at startTime
    
    % creating t axis to plot segmented signal
    % t vector size = xN vector size
    % Without -1/fs at the end, t vector size = N+1 samples
    t = startTime : 1/fs : startTime+segmentDuration - 1/fs;

return;