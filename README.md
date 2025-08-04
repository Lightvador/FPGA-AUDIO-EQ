# FPGA-AUDIO-EQ
 Audio equalization is a fundamental digital signal processing (DSP)  technique used to enhance sound quality by adjusting the amplitude of  different frequency bands. FPGA-based real-time equalizers allow low latency processing, making them suitable for audio enhancement  applications. 
 <br>
 The project required a Zynq-7000 board, a pmod DA2, a pmod AMP2 
and a pmod MIC.
<br>
The mic uses an SPI (Serial Peripheral Interface) which is commonly 
used for short distance communication. I made a separate module 
for it and instantiated it.
<br>
 The DACused anSPI-like protocol where the user could select one of
 two DAC 121S101. I made a separate module for it and instantiated 
it as well. An AMP2 was used to amplify the analog output to a 
speaker.
<br>
 Lastly, I used a module to make 3 FIR bandpass filters
 corresponding to high (3.5kHz-16kHz), medium(400 Hz- 3.5kHz) and
 low frequencies(0-400 Hz).

