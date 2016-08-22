function [ p_fs ] = get_wk2_ps( avg_pao_beat, r, c, diastolic_start, fs, q_max, p_diastolic_end )
%Get calculated
%   Detailed explanation goes here
t_s = 0:1/fs:(diastolic_start-1)/fs;
t_d = (diastolic_start)/fs:1/fs:(length(avg_pao_beat)-1)/fs;
p_sis = (p_diastolic_end - r*q_max)*exp(-t_s/(c*r)) + r*q_max;
p_fs = p_sis(end);
p_dia = p_fs*exp(-(t_d - t_d(1))/(c*r));

end

