# Speech-Synthesis-with-LPC-coefficients
Specification that guides the whole coursework is in Assignment1 file. 

Natural speeches are wav file with short file name, the first part is the word sample, the second part is the gender that said the word.

Artifial speeches created by LPC function have different parameters 
-- (1) AR:Autoregression pole order, 
-- (2) Segment length: we segment speech to short segments at different starting points to see how it might affect speech synthesis quality
-- (3) Impulse waveform: conventional wisdom says that triangle wave should bring the most quality synthesis. Well that's not the case here!
