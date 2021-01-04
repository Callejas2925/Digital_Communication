%% PAM4_Mod_Gray.m Function
% This function will do 4-PAM modulation
% It's will map: (Gray mapping)
%   00 into -3
%   01 into -1
%   11 into 1
%   10 into 3
% The modulated symbol is then energy adjusted (multiplied by sqrt(Eb/5)) 
% to have the average energy-per-bit of Eb
function code = PAM4_mod_GRAY(bits)
if rem(length(bits),2) == 1
    bits = [bits, 0];
end

code = zeros(1,length(bits)/2);
for i=1:length(code)
    if bits(2*i-1:2*i) == [0 0]
         code(i) = -3;
    elseif bits(2*i-1:2*i) == [0 1]
         code(i) = -1;
    elseif bits(2*i-1:2*i) == [1 1]
         code(i) = 1;
    else
        code(i) = 3;
    end
end