function test_xN = preSpeechProcessRoutine(xN)
    % Pre-processing routine in speech processing
    test_xN = xN.*hamming(length(xN)); %Hamming window
    
    % high-pass filter to boost amplitudes at higher frequency bands and
    % suppress amplitudes at lower frequency bands. The assumption is that higher 
    % frequencies are more important to formants occur. Which generally holds 
    % true because average F1 of adults' are high enough for high-pass filter. 
    high_filter = [1 0.63];
    test_xN = filter(1,high_filter,test_xN);
return;