
function binVector = str2bin(textStr)

% STR2BIN Convert text string to binary vector
%
%     Syntax:           binVector = str2bin(textStr)
%
%     Example:          aStr = 'The Language of Technical Computing';
%                       B = str2bin(aStr);
%                       figure;
%                       stairs(B);
%                       ylim([-0.2 1.2]);
%
%
%     Written by:       Rick Rosson, 2007 September 12
%     Last Revised:     Rick Rosson, 2007 December 20
%
%
%     Copyright (c) 2007 The MathWorks, Inc.  All rights reserved.
%
%

    AsciiCode = uint8(textStr);
    
    binStr = transpose(dec2bin(AsciiCode,8));
    binStr = binStr(:);
    
    N = length(binStr);
    binVector = zeros(N,1);

    for k = 1:N
        binVector(k) = str2double(binStr(k));
    end

    binVector = logical(binVector);

end
