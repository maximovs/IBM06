function [ compliance, p_fs, pp_d ] = get_compliance_via_ppm( avg_pao_beat, r, initial_compliance, sistolic_end, fs, q_max, p_diastolic_end, pp_a )
%Get calculated
%   Detailed explanation goes here
compliance = initial_compliance;
last_compliance = compliance;
delta_c = 0.001;
distance = (get_wk2_pp(avg_pao_beat, r, compliance, sistolic_end, fs, q_max, p_diastolic_end) - pp_a)/pp_a;
next_distance = (get_wk2_pp(avg_pao_beat, r, compliance - delta_c, sistolic_end, fs, q_max, p_diastolic_end) - pp_a)/pp_a;
if abs(next_distance) > abs(distance)
    delta_c = delta_c * -1;
end
last_distance = abs(distance) + 1;
while abs(distance) < abs(last_distance)
    last_compliance = compliance;
    compliance = last_compliance - delta_c;
    p_fs = get_wk2_ps(avg_pao_beat, r, compliance, sistolic_end, fs, q_max, p_diastolic_end);
    pp_d = get_wk2_pp(avg_pao_beat, r, compliance, sistolic_end, fs, q_max, p_diastolic_end);
    last_distance = distance;
    distance = (pp_d - pp_a)/pp_a;
end
end

