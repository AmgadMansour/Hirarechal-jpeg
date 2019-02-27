function [uDown vDown] = downsample(imUV)
% 4:2:0 chroma subsampling for YUV inputs
U = imUV(:,:,1);
V = imUV(:,:,2);
[r c d] = size(imUV);
uDown = U(1:2:r,1:2:c);
vDown = V(1:2:r,1:2:c);
