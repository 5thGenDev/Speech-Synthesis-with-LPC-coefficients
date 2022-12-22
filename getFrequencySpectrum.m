function [xK, Nfft, positive_Nfft] = getFrequencySpectrum(xN, fs)
    % Compute the number of DFT points that doesn't cause aliasing
    Nfft = 2^nextpow2(length(xN));
    % This says Nfft >= 2*signal frequency in normalised scaling [0;1]

    xK = fft(xN, Nfft); 

    % this is a loop to plot frequency-axis, not its index. Otherwise
    % MATLAB would have called error because index cannot start from 0.
    positive_Nfft = (0:Nfft/2-1)*(fs/Nfft); 
    % Plot only positive DFT points because of the spectrum is symmetric
    % on both side of 0, where each side has Nfft/2 DFT points to plot
    % But we count 0 as index 1 so the last positive DFT point = Nfft/2 - 1. 
    % Finally, we scale normalised DFT points 0->1->2->...->Nfft/2-1
    % by its sampling rate 0->fs/Nfft->2fs/Nfft->...->fs/2-fs/Nfft
return;