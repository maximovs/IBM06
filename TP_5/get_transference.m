function [ h, H ] = get_transference( input, output, n )
%GET_TRANSFERENCE Summary of this function goes here
%   Detailed explanation goes here
Input = fft(input, n);
Output = fft(output, n);
H = Output./Input;
h = ifft(H);

end

