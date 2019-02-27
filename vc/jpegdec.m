function [imDec] = jpegdec(imYUV,qf)
%JPEG decoding
 picY = imYUV.Y; 
 picU = imYUV.U; 
 picV = imYUV.V;
    
QL=[16,  11,  10,  16,  24,  40,  51,  61,
    12,  12,  14,  19,  26,  58,  60,  55,
    14,  13,  16,  24,  40,  57,  69,  56,
    14,  17,  22,  29,  51,  87,  80,  62,
    18,  22,  37,  56,  68, 109, 103,  77,
    24,  35,  55,  64,  81, 104, 113,  92,
    49,  64,  78,  87, 103, 121, 120, 101,
    72,  92,  95,  98, 112, 100, 103,  99
];
QC=[17,  18,  24,  47,  99,  99,  99,  99,
    18,  21,  26,  66,  99,  99,  99,  99,
    24,  26,  56,  99,  99,  99,  99,  99,
    47,  66,  99,  99,  99,  99,  99,  99,
    99,  99,  99,  99,  99,  99,  99,  99,
    99,  99,  99,  99,  99,  99,  99,  99,
    99,  99,  99,  99,  99,  99,  99,  99,
    99,  99,  99,  99,  99,  99,  99,  99
];
QC = round(QC.*qf);		
QL = round(QL.*qf);		


    %apply dequantization
	iquantizedY=blkproc(picY,[8 8],'amulb',QL);
	iquantizedU=blkproc(picU,[8 8],'amulb',QC);
	iquantizedV=blkproc(picV,[8 8],'amulb',QC);
    
	%applyIDCT
	decFun = @idct2;
	newPicY = blkproc(iquantizedY, [8 8], decFun);
	newPicU = blkproc(iquantizedU, [8 8], decFun);
	newPicV = blkproc(iquantizedV, [8 8], decFun);
    
    imDec = struct('Y',newPicY,'U',newPicU,'V',newPicV);
