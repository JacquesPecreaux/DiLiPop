function [tmp_seg]=dechorionator(tmp_seg)

global param;

tmp_seg = Dechorionator_core(tmp_seg, param.chorion_radius, param.chorion_width, param.resol, param.max_chorion_solidity, param.Chorion_tolerance_EccentricityRatio);