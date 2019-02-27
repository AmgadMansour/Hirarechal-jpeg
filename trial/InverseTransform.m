function [videoDecoder]=InverseTransform(frame,QP)

%Integer Transform 
 frameY = frame.Y; 
 frameU = frame.U; 
 frameV = frame.V;

%Integer transform matrix
C=[1,1,1,1;
   1,1/2,-1/2,-1;
   1,-1,-1,1;
   1/2,-1,1,-1/2;
];

%Quantization helper matrix
v=[10,16,13
    11,18,14;
    13,20,16;
    14,23,18;
    16,25,20;
    18,29,23];

%Quantization Matrix
if QP < 6
    V =[v(QP,0),v(QP,2),v(QP,0),v(QP,2);
        v(QP,2),v(QP,1),v(QP,2),v(QP,1);
        v(QP,0),v(QP,2),v(QP,0),v(QP,2);
        v(QP,2),v(QP,1),v(QP,2),v(QP,1)];
else
    p = mod(QP,6);
    q = pow(2,floor(QP/6));
    V =[v(p,0)*q,v(p,2)*q,v(p,0)*q,v(p,2)*q;
        v(p,2)*q,v(p,1)*q,v(p,2)*q,v(p,1)*q;
        v(p,0)*q,v(p,2)*q,v(p,0)*q,v(p,2)*q;
        v(p,2)*q,v(p,1)*q,v(p,2)*q,v(p,1)*q]; 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% apply dequantization
dequantizedY = blockproc(frameY,[4 4],'amulb',V);
dequantizedU = blockproc(frameU,[4 4],'amulb',V);
dequantizedV = blockproc(frameV,[4 4],'amulb',V);

% perform Integer Transfrom on each 4x4 block
frameITrY = blockproc(dequantizedY,[4 4],'inverseIntegerTransform',C);
frameITrU = blockproc(dequantizedU,[4 4],'inverseIntegerTransform',C);
frameITrV = blockproc(dequantizedV,[4 4],'inverseIntegerTransform',C);

% apply scaling swift by 15 bits
scaledY = round(frameITrY/pow(2,6));
scaledU = round(frameITrU/pow(2,6));
scaledV = round(frameITrV/pow(2,6));
    

    
videoDecoder = struct('Y',scaledY,'U',scaledU,'V',scaledV);	
    
    


