function [videoDecoder]=InverseTransform(frame,QP)

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
    V =[v(QP,1),v(QP,3),v(QP,1),v(QP,3);
        v(QP,3),v(QP,2),v(QP,3),v(QP,2);
        v(QP,1),v(QP,3),v(QP,1),v(QP,3);
        v(QP,3),v(QP,2),v(QP,3),v(QP,2)];
else
    p = mod(QP,6);
    q = 2^(floor(QP/6));
    V =[v(p,1)*q,v(p,3)*q,v(p,1)*q,v(p,3)*q;
        v(p,3)*q,v(p,2)*q,v(p,3)*q,v(p,2)*q;
        v(p,1)*q,v(p,3)*q,v(p,1)*q,v(p,3)*q;
        v(p,3)*q,v(p,2)*q,v(p,3)*q,v(p,2)*q]; 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% apply dequantization
dequantized = amulb(frame,V);

% perform Integer Transfrom on each 4x4 block
frameItr = inverseIntegerTransform(dequantized,C);

% apply scaling swift by 15 bits
scaled = round(frameItr/2^6);
    
videoDecoder = scaled;	
    
    


