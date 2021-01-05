%% PAM8_Mod_Gray.m Function
% This function will do 8-PAM modulation
% It's will map: (Gray mapping)
%   000 into -7
%   001 into -5
%   011 into -3
%   010 into -1
%   110 into 1
%   111 into 3
%   101 into 5
%   100 into 7
% The modulated symbol is then energy adjusted (multiplied by sqrt(Eb/21)) 
% to have the average energy-per-bit of Eb

function code = PAM8_mod_GRAY(bits)
if rem(length(bits),2) == 1
    bits = [bits, 0];
end

code = zeros(1,length(bits)/3);
for i=1:length(code)
    if bits(3*i-2:3*i) == [0 0 0]
         code(i) = -7;
    elseif bits(3*i-2:3*i) == [0 0 1]
         code(i) = -5;
    elseif bits(3*i-2:3*i) == [0 1 1]
         code(i) = -3;
    elseif bits(3*i-2:3*i) == [0 1 0]
        code(i) = -1;
    elseif bits(3*i-2:3*i) == [1 1 0]
        code(i) = 1;
    elseif bits(3*i-2:3*i) == [1 1 1]
        code(i) = 3;
    elseif bits(3*i-2:3*i) == [1 0 1]
        code(i) = 5;
    else
        code(i) = 7;
    end
end