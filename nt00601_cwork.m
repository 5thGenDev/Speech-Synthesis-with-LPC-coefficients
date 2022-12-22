clear all;

%% Read speech file 
FILE_DIR = "/user/HS402/nt00601/Documents/MATLAB/Speech Processing/speech samples/whod_f.wav";
FORMAT = "." + extractAfter(FILE_DIR,".");
Word_Gender = extractBetween(FILE_DIR,"speech samples/", FORMAT);
WORD = extractBefore(Word_Gender,"_");

GENDER = extractAfter(Word_Gender,"_");
if GENDER == "f"
    GENDER = "female";
elseif GENDER == "m"
    GENDER = "male";
end

[xN, fs] = audioread(FILE_DIR);


%% Get 100ms segment starting at different time
%% and plot the magnitudes frequency spectrum 
%% to visually find fundamental frequency F1

startTime = 0.03;
segmentDuration = 0.05;
[xN, t] = segmentSignal(xN, fs, segmentDuration, startTime);

figure(1);
subplot(2,1,1);
plot(t, xN);
grid;
title("xN " +GENDER + " speech. "...
      +"Duration: " +segmentDuration*1000 +" ms. ");
xlabel('Time(s)');
ylabel('Amplitude');

% Pre-processing routine in speech processing
test_xN = preSpeechProcessRoutine(xN);

% Pre-processing routine in frequency spectrum
[xK, Nfft, positive_Nfft] = getFrequencySpectrum(test_xN, fs);

subplot(2,1,2);
plot(positive_Nfft, 10*log10(abs(xK(1:length(positive_Nfft)))));
grid;
title("Spectrum of "+ GENDER...
     +". Duration:" + segmentDuration*1000 +" ms.");
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB/Hz)');

% Assign fundamental frequency F1 by visually looking at the plot
F1 = 199.217;
% F1 = 199.217Hz for female 'whod'
% F1 = 123.047Hz for male 'whod'

% For reference
% Mean F1 for typically developing adult male = 111.86 -> 144.80Hz
% Mean F1 for typically developing adult female = 193.21 -> 214.28Hz 
% https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5270637/ - Table A6


%% LPC coefficients
% there are 3 guidelines number of poles for LPC, either:
% (1) number of poles = 2*(number of formants) + 2
% pole_order = 10;

% (2) number of poles = sample frequency in kHz
pole_order = fs/1e3; % for female
% pole_order = fs/1e3 + 4; % for male, my modification

% (3) number of poles = 50 for female, 54 for male
% pole_order = 54;
Hz_den_coeffs = arcov(test_xN, pole_order);

% plot speech spectrum and spectral envelop
spectral_envelop = freqz(1, Hz_den_coeffs,Nfft, 'whole',fs);

figure(2);
plot(positive_Nfft, 10*log10(abs(xK(1:Nfft/2))));
title(GENDER + " speech spectrum and its spectral envelope");
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB/Hz)');
hold on;

plot(positive_Nfft, 10*log10(abs(spectral_envelop(1:Nfft/2))),'--');
hold off;

%% Find formant frequency and formant bandwidth
poles = roots(Hz_den_coeffs);

figure(3);
zplane([],poles);

% trim off negative-angle poles, it's okay to do this
% because complex conjugate poles are symmetric
poles = poles(imag(poles)>0);

theta = atan2(imag(poles),real(poles));

% Calculate formant frequencies (peaks)
[formant_freq, sort_index] = sort(theta.*(fs/(2*pi)), 'ascend');
% Sort formant frequency in ascending array because the first three
% formants have the lowest frequencies among all other formant frequencies

formant_bandwidth = -0.5*fs/(2*pi)*log(abs(poles(sort_index)));
% Formant_bandwidth is a vector where every sorted element has the same
% index as corresponding element in formant_freq vector. That's why we
% extract sort_index from line 99 above


%% Eliminate false peaks 

% Preallocate vector to increase computation time
% Selected_formants = zeros(1:10);
% Selected_formants_index = 1;
% 
% for formant_freq_index = 1:length(formant_freq)
%     if formant_freq(formant_freq_index) > F1 ...
%        && formant_freq(formant_freq_index) < 3500 ...
%        && formant_bandwidth(formant_freq_index) < 200 ...
%        && formant_bandwidth(formant_freq_index) > 50
%         Selected_formants(Selected_formants_index) = formant_freq(formant_freq_index);
%         Selected_formants_index = Selected_formants_index + 1;
%     end
% end
% 
% Selected_formants = nonzeros(Selected_formants);
Selected_formants = formant_freq(1:3);

%% Excitation generator

% Create glottal impulse (voiced source) 
% with F1 distance between 2 pulses, 
% and same fs as speech sample 
normal_t = 0:1/fs:segmentDuration-1/fs;

% if glottal impulses is dirac-delta impulses
% excitation_pulses = zeros(1,length(t));
% excitation_pulses(1:floor(fs/F1):end) = 1; 
% this code says for every index at fs/F1 between 1:end, plot 1.

% if excitation pulses is sawtooth wave
% excitation_pulses = sawtooth(2*pi*F1*normal_t);

% if excitation pulses is triangle wave
excitation_pulses = sawtooth(2*pi*F1*normal_t,0.5);

figure(4);
subplot(2,1,1);
plot(t, excitation_pulses);
title("Excitation pulses train");
xlabel("Time(s)");
ylabel("Amplitude");

% convolve white noise with glottal impulses with SNR parameter
SNR = 500;
noisy_excitation_pulses = awgn(excitation_pulses,SNR);
subplot(2,1,2);
plot(t, noisy_excitation_pulses);
title("Noisy excitation pulses train");
xlabel("Time(s)");
ylabel("Amplitude");


%% Filter excitation pulses through H(z) to get synthesis speech
synth_xN = filter(1,Hz_den_coeffs, noisy_excitation_pulses);

% Plot synth xN and xN
figure(5); 
plot(t, test_xN/max(test_xN));
grid;
title("Synth xN vs xN, SNR: " +SNR);
xlabel('Time(s)');
ylabel('Normalised Amplitude');
hold on; 

plot(t, synth_xN/max(synth_xN),'--');
hold off;

% compare synth xN vs xN in frequecy-domain
figure(6);
[synth_xK, Nfft] = getFrequencySpectrum(synth_xN, fs);
plot(positive_Nfft, 10*log10(abs(xK(1:Nfft/2))));
grid;
title("Synth xN spectrum vs xN spectrum");
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB/Hz)');
hold on;

plot(positive_Nfft, 10*log10(abs(synth_xK(1:Nfft/2))), '--');
hold off;

% create synthesis file
% SYNTH_FILE_DIR = extractBefore(FILE_DIR,".wav");
% SYNTH_FILE_DIR = SYNTH_FILE_DIR ...
%                  +"_Duration" +segmentDuration*1000 ...
%                  +"_ARorder" +pole_order ...
%                  +"_sawtoothWave" ...
%                  +FORMAT;
% audiowrite(SYNTH_FILE_DIR,synth_xN,fs);
