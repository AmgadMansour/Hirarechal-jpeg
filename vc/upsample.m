function [uUp vUp] = upsample(imUV)
%4:2:0 chroma upsampling using linear interpolation
U = imUV(:,:,1);
V = imUV(:,:,2);
[r c d] = size(imUV);
tmp = zeros(2*r, 2*c, 2);
tmp(1:2:2*r,1:2:2*c,1:2) = imUV(:,:,1:2);

% size(tmp)
% size(tmp(1:2:2*r,2:2:(2*c-2),1:2))
% size(tmp(1:2:2*r,1:2:(2*c-2),1:2))
% size(tmp(1:2:2*r,3:2:(2*c-1),1:2))
% 
% 
% size(tmp(2:2:2*r,1:1:(2*c-2),1:2))
% size(tmp(1:2:2*r,1:1:(2*c-2),1:2))
% size(tmp(2:2:2*r,1:1:(2*c-2),1:2))


tmp(1:2:2*r,2:2:(2*c-2),1:2) = (double(tmp(1:2:2*r,1:2:(2*c-2),1:2))+double(tmp(1:2:2*r,3:2:2*c,1:2)))/2;
tmp(2:2:2*r,1:1:(2*c-2),1:2) = (double(tmp(1:2:2*r,1:1:(2*c-2),1:2))+double(tmp(2:2:2*r,1:1:(2*c-2),1:2)))/2;
uUp = tmp(:,:,1);
vUp = tmp(:,:,2);
