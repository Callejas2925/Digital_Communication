%% PAM4_Demod_Gray.m Function
% This function will do 4-PAM demodulation
% It's will demapping for Gray mapping
%   -3 into 00 
%   -1 into 01
%    1 into 11
%    3 into 10

function bits = PAM4_demod_GRAY(code)
bits = zeros(1,2*length(code));

for i=1:length(code)
    if code(i) < -2
        bits(2*i-1:2*i) = [0 0];
    elseif code(i) < 0
        bits(2*i-1:2*i) = [0 1];
    elseif code(i) < 2
        bits(2*i-1:2*i) = [1 1];
    else
        bits(2*i-1:2*i) = [1 0];
    end
end