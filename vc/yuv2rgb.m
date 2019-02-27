function imRGB = yuv2rgb(imYUV)
% convert yuv [0,255] to rgb [0,255]

imYUV = double(imYUV);
Y = imYUV(:,:,1);
U = imYUV(:,:,2);
V = imYUV(:,:,3);
R = Y + 1.13983 * V;
G = -0.58060 * V -0.39465 * U + Y;
B = Y + 2.03211 * U; 
imRGB = uint8(cat(3,R,G,B)); % it was double so need 0..1 range for imshow