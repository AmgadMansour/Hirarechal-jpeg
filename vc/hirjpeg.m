function hirjpeg = hirjpeg(img,q,handles)
tic
PathName = '/Users/macbookair/Desktop/Multimedia Systems/Ass 1- Hirarechal JPEG/results'
imRGB = imread(img);%'lenna.png');%'vanc.jpg'); 
[r c d] = size(imRGB);
Folder = '/Users/macbookair/Desktop/Multimedia Systems/Ass 1- Hirarechal JPEG/results';
File   = 'orig.png';
imwrite(imRGB, fullfile(Folder, File));



%% level 1
 
% first out (downsampled by 4, f4)
imRGBdown2 = down(imRGB);
imRGBdown4 = down(imRGBdown2);
File   = 'lvl1_down4.png';
imwrite(imRGBdown4,fullfile(Folder, File));
imshow(fullfile(PathName, File), 'Parent', handles.axes1);

% 4:2:0 chroma subsampling
imYUV = rgb2yuv(imRGBdown4);
imUV = imYUV(:,:,2:3);
[uDown2 vDown2] = downsample(imUV);

%encoding (F4)
imYUVd4 = struct('Y',imYUV(:,:,1),'U',uDown2,'V',vDown2);
imYUVd4Enc = jpegenc(imYUVd4,q);

%decoding (~F4)
imYUVd4Dec = jpegdec(imYUVd4Enc,q);

%chroma upsampling
[uUp2 vUp2] = upsample(cat(3,imYUVd4Dec.U,imYUVd4Dec.V));
File   = 'lvl1_down4_dec.png';
imYUVd4Dec.U = uUp2;
imYUVd4Dec.V = vUp2;
imYUVd4DecFinal = cat(3,imYUVd4Dec.Y,imYUVd4Dec.U,imYUVd4Dec.V);
imwrite(yuv2rgb(imYUVd4DecFinal),fullfile(Folder, File));
imshow(fullfile(PathName, File), 'Parent', handles.axes3);






%% level 2

%downsampling
File   = 'lvl2_down2.png';
imwrite(imRGBdown2,fullfile(Folder, File));
imshow(fullfile(PathName, File), 'Parent', handles.axes4);


% 4:2:0 chroma subsampling
clear imYUV imUV uDown2 vDown2
imYUV = rgb2yuv(imRGBdown2);
imUV = imYUV(:,:,2:3); 
imYUVd4DecUp2 = up(imYUVd4DecFinal);
imY = imYUV(:,:,1) -  imYUVd4DecUp2(:,:,1);
[uDown2 vDown2] = downsample(imUV-imYUVd4DecUp2(:,:,2:3));

%encoding (D2)
imYUVd2 = struct('Y',imY,'U',uDown2,'V',vDown2);
imYUVd2Enc = jpegenc(imYUVd2,q);


%decoding (~d4)
imYUVd2Dec = jpegdec(imYUVd2Enc,q);

%chroma upsampling
clear uUp2 vUp2
[uUp2 vUp2] = upsample(cat(3,imYUVd2Dec.U,imYUVd2Dec.V));
File   = 'lvl2_down2_dec.png';
imYUVd2Dec.U = uUp2;
imYUVd2Dec.V = vUp2;
imYUVd2DecFinal = cat(3,imYUVd2Dec.Y,imYUVd2Dec.U,imYUVd2Dec.V) + imYUVd4DecUp2;
imwrite(yuv2rgb(imYUVd2DecFinal),fullfile(Folder, File));
imshow(fullfile(PathName, File), 'Parent', handles.axes6);






%% level 3

imshow(fullfile(PathName, 'orig.png'), 'Parent', handles.axes7);

% 4:2:0 chroma subsampling
clear imYUV imUV imY uDown2 vDown2
imYUV = rgb2yuv(imRGB);
imUV = imYUV(:,:,2:3); 
imYUVd2DecUp2 = up(imYUVd2DecFinal);
imY = imYUV(:,:,1) -  imYUVd2DecUp2(:,:,1);
[uDown2 vDown2] = downsample(imUV-imYUVd2DecUp2(:,:,2:3));

%encoding (D2)
imYUVd1 = struct('Y',imY,'U',uDown2,'V',vDown2);
imYUVd1Enc = jpegenc(imYUVd1,q);

%decoding (~d4)
imYUVd1Dec = jpegdec(imYUVd1Enc,q);

%chroma upsampling
clear uUp2 vUp2
[uUp2 vUp2] = upsample(cat(3,imYUVd1Dec.U,imYUVd1Dec.V));
File   = 'lvl3_dec.png';
imYUVd1Dec.U = uUp2;
imYUVd1Dec.V = vUp2;
imYUVd1DecFinal = cat(3,imYUVd1Dec.Y,imYUVd1Dec.U,imYUVd1Dec.V) + imYUVd2DecUp2;
imwrite(yuv2rgb(imYUVd1DecFinal),fullfile(Folder, File));
imshow(fullfile(PathName, File), 'Parent', handles.axes9);





toc
