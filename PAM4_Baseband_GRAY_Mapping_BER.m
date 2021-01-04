%% Task 1
% Simulate the performance of Gray-Mapping 4-PAM signaling.

% PAM4 Eb/No Ratio
clear;
EbN0_dB = 0:1:12;               % Eb/No in dB
EbN0 = 10.^(EbN0_dB/10);        % Convert EbN0_dB back to the ration Eb/N0

% PAM4 Vector Storage Creation
Numerical_PAM_BER = zeros(1,length(EbN0_dB));       % Stores all PAM4 BER
Numerical_PAM4_GRAY_BER = zeros(1,length(EbN0_dB)); % Stores all PAM4 Gray BER

% Constants
L = 3000;                       % Setup L as the length of the bit sequence
a = sqrt(2/5);                  % Make Eb=1
y = zeros(1,L/2);

% PAM4 MODEM
for i=1:length(EbN0_dB)
    N0 = 1/EbN0(i);             % with Eb = 1, N0 = 1/(EbN0)
    PAM4_GRAY_error = 0;        % PAM4 GRAY Error Counter
    PAM4_error = 0;             % PAM4 Non-GRAY Error Counter
    noOfL = 0;                  % to count the number of bit sequences sent
    
    % start running the code, I need to count at least 500 bits in error or
    % the number of bit sequences at least 100000. Long run of the code
    % to have enough errors and statistical significance to have smooth
    % curves.
    while (PAM4_GRAY_error < 500) && (noOfL<1e5)
        % Generate Bit Stream Sequence
        bits = randi([0,1],1,L);    % random bit sequence of length L
        
        % PAM4 Modulation
        Non_Gray_symbols = PAM4_mod(bits);  % PAM4 Modulation (Non-Gray)
        
        % PAM4_GRAY Modulation
        Gray_symbols = PAM4_mod_GRAY(bits); % PAM4 Modulation (Gray-Mapping)
        
        % Generate Noise
        noise = sqrt(N0/2)*randn(1,L/2); % Gaussian Noise;
        
        % Transmit PAM4 Signal
        PAM4_tx = Non_Gray_symbols*a;
        
        % Transmit PAM4_GRAY Signal
        PAM4_GRAY_tx = Gray_symbols*a;
        
        % Received PAM4 Signal
        PAM4_rx = PAM4_tx + noise;
        PAM4_rx = PAM4_rx*(1/a);
        
        % Received PAM4_GRAY Signal
        PAM4_GRAY_rx = PAM4_GRAY_tx + noise;
        PAM4_GRAY_rx = PAM4_GRAY_rx*(1/a);
        
        % PAM4 Detection/Threshold
        PAM4_bits_detect = PAM4_demod(PAM4_rx);
        
        % PAM4_GRAY Detection/Threshold
        PAM4_GRAY_bits_detect = PAM4_demod_GRAY(PAM4_GRAY_rx);
        
        % Calculate Bits in Error PAM4
        PAM4_error = PAM4_error + sum(bits ~= PAM4_bits_detect);
        
        % Calculate Bits in Error PAM4_GRAY
        PAM4_GRAY_error = PAM4_GRAY_error + sum(bits~=PAM4_GRAY_bits_detect);
      
        noOfL = noOfL + 1;          % Increment Bit Sequences counter
    end
    
    % Calculate the BER = total_error/total_bits_tx
    Numerical_PAM_BER(i) = PAM4_error/L/noOfL;            
    Numerical_PAM4_GRAY_BER(i) = PAM4_GRAY_error/L/noOfL;
end

% Plot Figure 1 Gray-Mapping
figure(1)
scatter(PAM4_GRAY_rx,y,'*');

% Plot  BER
figure(2)
BER_Plot = semilogy(EbN0_dB,Numerical_PAM_BER,'.-',EbN0_dB,Numerical_PAM4_GRAY_BER,'.-');
legend('PAM4-NON-GRAY','PAM4-GRAY');
xlabel('Eb/No in dB');      % X-Label
ylabel('BER');              % Y-Label