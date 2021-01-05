%% Task 3
% Simulate the performance of Gray-Mapping 16-QAM signaling.
% Passband

% QAM16 Eb/No Ratio
clear;
EbN0_dB = 0:1:12;               % Eb/No in dB
EbN0 = 10.^(EbN0_dB/10);        % Convert EbN0_dB back to the ration Eb/N0

% QAM16 Vector Storage Creation
Numerical_QAM16_GRAY_BER = zeros(1,length(EbN0_dB)); % Stores all QAM16 BER

% PAM4 Vector Storage Creation
Numerical_PAM_BER = zeros(1,length(EbN0_dB));        % Stores all PAM4 BER

% We use 100 samples to form the basis function of during 1 second
% These 100 samples are used to represent 1 symbol only
sampPerSym = 100;
time=0.1;                       % symbol time
Ts=time/sampPerSym;             % sampling interval
t=0:Ts:time-Ts;                 % time vector

% Cosine and Sine Basis Functions
f=100;
phi_1 = cos(2*pi*f*t);
phi_2 = sin(2*pi*f*t);

% Normalize the basis functions - each function last for 1 second
phi_1 = phi_1/norm(phi_1);
phi_2 = phi_2/norm(phi_2);

I_corr = fliplr(phi_1);   % flip with correlator to have the matched filter
Q_corr = fliplr(phi_2);   % flip with correlator to have the matched filter

% Constants
L = 1000;                       % Setup L as the length of the bit sequence
a = sqrt(2/5);                  % Make Eb=1

% QAM16 MODEM
for i=1:length(EbN0_dB)
    N0 = 1/EbN0(i);             % with Eb = 1, N0 = 1/(EbN0)
    QAM16_GRAY_Error = 0;       % QAM16 GRAY Error Counter
    PAM4_error = 0;             % PAM4 Error Counter
    noOfL = 0;                  % to count the number of bit sequences sent
    
    % start running the code, I need to count at least 500 bits in error or
    % the number of bit sequences at least 100000. Long run of the code
    % to have enough errors and statistical significance to have smooth
    % curves.
    while (QAM16_GRAY_Error < 500) && (noOfL<1e5)
        % Generate Bit Stream Sequence
        bits = randi([0,1],1,L);    % random bit sequence of length L
        
        % Inphase and Quadrature Bits
        I_bits = zeros(1,L/2);
        Q_bits = zeros(1,L/2);
        
        odd_bits = bits(1:2:end);
        even_bits = bits(2:2:end);
        
        I_Q_Counter = 1;
        for k=1:length(I_bits)/2
            I_bits(2*k-1:2*k)=[odd_bits(I_Q_Counter) even_bits(I_Q_Counter)];
            Q_bits(2*k-1:2*k)=[odd_bits(I_Q_Counter+1) even_bits(I_Q_Counter+1)];
            I_Q_Counter=I_Q_Counter+2;
        end
        
        % PAM4 Modulation
        Non_Gray_symbols = PAM4_mod(bits);  % PAM4 Modulation (Non-Gray)
        
        % QAM16 Modulation
        I_symbols = PAM4_mod_GRAY(I_bits); % PAM4 Modulation (Gray-Mapping)
        Q_symbols = PAM4_mod_GRAY(Q_bits); % PAM4 Modulation (Gray-Mapping)
        
        % Upsampling I and Q (DAC)
        I_symbols_upsampled = upsample(I_symbols,sampPerSym);
        Q_symbols_upsampled = upsample(Q_symbols,sampPerSym);
        
        % Transmit PAM4 Signal
        PAM4_tx = Non_Gray_symbols*a;
        
        % Transmit QAM16 Signal (Mixer)
        PBS1 = filter(phi_1,1,I_symbols_upsampled);  
        PBS2 = filter(phi_2,1,Q_symbols_upsampled);
        QAM16_tx = PBS1 + PBS2;
        QAM16_tx = QAM16_tx*a;
        
        % Generate PAM4 Noise
        noise = sqrt(N0/2)*randn(1,L/2); % Gaussian Noise;
        
        % Generate QAM16 Noise
        QAM16_noise = sqrt(N0/2)*randn(1,length(QAM16_tx)); % Gaussian Noise;
        
        % Received PAM4 Signal
        PAM4_rx = PAM4_tx + noise;
        PAM4_rx = PAM4_rx*(1/a);
        
        % Received QAM16 Signal
        QAM16_rx = QAM16_tx + QAM16_noise;
        QAM16_rx = QAM16_rx * (1/a);
        
        I_filtered = filter(I_corr,1,QAM16_rx); % pass signal to through matched filter
        Q_filtered = filter(Q_corr,1,QAM16_rx); % pass signal to through matched filter
        
        % Sample the filtered signal at every second (1 sample for every 100 samples)
        QAM16_rx_I_symbols = I_filtered(sampPerSym:sampPerSym:end); 
        QAM16_rx_Q_symbols = Q_filtered(sampPerSym:sampPerSym:end);
        
        % PAM4 Detection/Threshold
        PAM4_bits_detect = PAM4_demod(PAM4_rx);
        
        % QAM16 Detection/Threshold
        I_bits_demod = PAM4_demod_GRAY(QAM16_rx_I_symbols);
        Q_bits_demod = PAM4_demod_GRAY(QAM16_rx_Q_symbols);
        QAM16_GRAY_bits_detect = zeros(1,L);
        
        I_Q_Counter = 1;
        for j=1:4:L
            QAM16_GRAY_bits_detect(j) = I_bits_demod(I_Q_Counter);
            QAM16_GRAY_bits_detect(j+1) = I_bits_demod(I_Q_Counter+1);
            QAM16_GRAY_bits_detect(j+2) = Q_bits_demod(I_Q_Counter);
            QAM16_GRAY_bits_detect(j+3) = Q_bits_demod(I_Q_Counter+1);
            I_Q_Counter=I_Q_Counter+2;
        end
        
        % Calculate Bits in Error PAM4
        PAM4_error = PAM4_error + sum(bits ~= PAM4_bits_detect);
        
        % Calculate Bits in Error QAM16
        QAM16_GRAY_Error = QAM16_GRAY_Error + sum(bits ~= QAM16_GRAY_bits_detect);
        
        noOfL = noOfL + 1;          % Increment Bit Sequences counter
    end
    
    % Calculate the BER = total_error/total_bits_tx
    Numerical_PAM_BER(i) = PAM4_error/L/noOfL;   
    Numerical_QAM16_GRAY_BER(i) = QAM16_GRAY_Error/L/noOfL;
end

% Plot Power Spectrum
figure(1)
plotspec(QAM16_tx,Ts);

% Plot BER
figure(2)
BER_Plot = semilogy(EbN0_dB,Numerical_PAM_BER,'.-',EbN0_dB,Numerical_QAM16_GRAY_BER,'.-');
legend('PAM4-NON-GRAY','QAM16-GRAY');
xlabel('Eb/No in dB');      % X-Label
ylabel('BER');              % Y-Label