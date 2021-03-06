function [ output ] = avg_filter( window, times, input )
%Filters the vector by using the average of n points many times
    output = input;
    for i = 1:times
        output = filtfilt(ones(window,1)/window,1,output);
    end
end

