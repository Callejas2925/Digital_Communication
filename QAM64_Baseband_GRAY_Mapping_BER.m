%% Task 4
% Simulate the performance of Gray-Mapping 64-QAM signaling.
% Baseband

% QAM64 Eb/No Ratio
clear;
EbN0_dB = 0:1:18;               % Eb/No in dB
EbN0 = 10.^(EbN0_dB/10);        % Convert EbN0_dB back to the ration Eb/N0

% QAM64 Vector Storage Creation
Numerical_QAM64_GRAY_BER = zeros(1,length(EbN0_dB)); % Stores all QAM64 BER

% Constants
L = 3000;                 % Setup L as the length of the bit sequence
a = sqrt(6/42);           % Make Eb=1

% QAM64 MODEM
for i=1:length(EbN0_dB)
    N0 = 1/EbN0(i);             % with Eb = 1, N0 = 1/(EbN0)
    QAM64_GRAY_Error = 0;       % QAM64 GRAY Error Counter
    noOfL = 0;                  % to count the number of bit sequences sent
    
    % start running the code, I need to count at least 500 bits in error or
    % the number of bit sequences at least 100000. Long run of the code
    % to have enough errors and statistical significance to have smooth
    % curves.
    while (QAM64_GRAY_Error < 500) && (noOfL<1e5)
        % Generate Bit Stream Sequence
        bits = randi([0,1],1,L);    % random bit sequence of length L
        
        % Inphase and Quadrature Bits
        I_bits = zeros(1,L/2);
        Q_bits = zeros(1,L/2);
        
        odd_bits = bits(1:2:end);
        even_bits = bits(2:2:end);
        
        I_Q_Counter = 1;
        for k=1:length(I_bits)/3
            I_bits(3*k-2:3*k)=[odd_bits(I_Q_Counter) even_bits(I_Q_Counter) odd_bits(I_Q_Counter+1)];
            Q_bits(3*k-2:3*k)=[even_bits(I_Q_Counter+1) odd_bits(I_Q_Counter+2) even_bits(I_Q_Counter+2)];
            I_Q_Counter=I_Q_Counter+3;
        end
        
        % QAM64 Modulation
        I_symbols = PAM8_mod_GRAY(I_bits); % PAM8 Modulation (Gray-Mapping)
        Q_symbols = PAM8_mod_GRAY(Q_bits); % PAM8 Modulation (Gray-Mapping)
        symbols = I_symbols + 1i*Q_symbols; % complex symbols scaled by a
        
        % Transmit QAM64 Signal
        QAM64_tx = symbols*a;
        
        % Generate QAM64 Noise
        QAM64_noise = sqrt(N0/2)*(randn(1,length(QAM64_tx)) + 1i*randn(1,length(QAM64_tx)));
        
        % Received QAM64 Signal
        QAM64_rx = QAM64_tx + QAM64_noise;
        QAM64_rx_I_symbols = (1/a)*real(QAM64_rx);
        QAM64_rx_Q_symbols = (1/a)*imag(QAM64_rx);
        
        % QAM64 Detection/Threshold
        I_bits_demod = PAM8_demod_GRAY(QAM64_rx_I_symbols);
        Q_bits_demod = PAM8_demod_GRAY(QAM64_rx_Q_symbols);
        QAM64_GRAY_bits_detect = zeros(1,L);
        
        I_Q_Counter = 1;
        for j=1:6:L
            QAM64_GRAY_bits_detect(j) = I_bits_demod(I_Q_Counter);
            QAM64_GRAY_bits_detect(j+1) = I_bits_demod(I_Q_Counter+1);
            QAM64_GRAY_bits_detect(j+2) = I_bits_demod(I_Q_Counter+2);
            QAM64_GRAY_bits_detect(j+3) = Q_bits_demod(I_Q_Counter);
            QAM64_GRAY_bits_detect(j+4) = Q_bits_demod(I_Q_Counter+1);
            QAM64_GRAY_bits_detect(j+5) = Q_bits_demod(I_Q_Counter+2);
            I_Q_Counter=I_Q_Counter+3;
        end
        
        % Calculate Bits in Error QAM16
        QAM64_GRAY_Error = QAM64_GRAY_Error + sum(bits ~= QAM64_GRAY_bits_detect);
        
        noOfL = noOfL + 1;          % Increment Bit Sequences counter
    end
    
    % Calculate the BER = total_error/total_bits_t
    Numerical_QAM64_GRAY_BER(i) = QAM64_GRAY_Error/L/noOfL; 
end

% Plot Figure 1 Gray-Mapping QAM64
figure(1)
plot(real(QAM64_rx), imag(QAM64_rx), '*');

% Plot  BER
figure(2)
BER_Plot = semilogy(EbN0_dB,Numerical_QAM64_GRAY_BER);
legend('QAM64-GRAY');
xlabel('Eb/No in dB');      % X-Label
ylabel('BER');              % Y-Label