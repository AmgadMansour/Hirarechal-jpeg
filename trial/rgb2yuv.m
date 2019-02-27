function imYUV = rgb2yuv(imRGB)
% convert rgb [0,255] to yuv [0,255]

imRGB = double(imRGB); % imread is in uint8??????????
R = imRGB(:,:,1);
G = imRGB(:,:,2);
B = imRGB(:,:,3);
Y = 0.299 * R + 0.587 * G + 0.114 * B;
U = -0.14713 * R - 0.28886 * G + 0.436 * B;
V = 0.615 * R - 0.51499 * G - 0.10001 * B;
imYUV = cat(3,Y,U,V); % should I deal with it in the rest of code as double????
class(imYUV);