%% PAM8_Demod_Gray.m Function
% This function will do 8-PAM demodulation
% It's will demapping for Gray mapping
%   -7 into 000 
%   -5 into 001
%   -3 into 011
%   -1 into 010
%    1 into 110
%    3 into 111
%    5 into 101
%    7 into 100

function bits = PAM8_demod_GRAY(code)
bits = zeros(1,3*length(code));

for i=1:length(code)
    if code(i) < -6
        bits(3*i-2:3*i) = [0 0 0];
    elseif code(i) < -4
        bits(3*i-2:3*i) = [0 0 1];
    elseif code(i) < -2
        bits(3*i-2:3*i) = [0 1 1];
    elseif code(i) < 0
        bits(3*i-2:3*i) = [0 1 0];
    elseif code(i) < 2
        bits(3*i-2:3*i) = [1 1 0];
    elseif code(i) < 4
        bits(3*i-2:3*i) = [1 1 1];
    elseif code(i) < 6
        bits(3*i-2:3*i) = [1 0 1];
    else
        bits(3*i-2:3*i) = [1 0 0];
    end
end