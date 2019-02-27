function [videoEncoder] = ForwardTransform(frame,QP)

%Integer transform matrix
C=[1,1,1,1;
   2,1,-1,-2;
   1,-1,-1,1;
   1,-2,2,-1;
];

%Quantization helper matrix
m=[13107,5243,8066;
    11916,4660,7490;
    10082,4194,6554;
    9362,3647,5825;
    8192,3355,5243;
    7282,2893,4559];

%Quantization Matrix
if QP < 6
    M =[m(QP,1),m(QP,3),m(QP,1),m(QP,3);
        m(QP,3),m(QP,2),m(QP,3),m(QP,2);
        m(QP,1),m(QP,3),m(QP,1),m(QP,3);
        m(QP,3),m(QP,2),m(QP,3),m(QP,2)];
else
    p = mod(QP,6);
    q = 2^(floor(QP/6));
    M =[m(p,1)/q,m(p,3)/q,m(p,1)/q,m(p,3)/q;
        m(p,3)/q,m(p,2)/q,m(p,3)/q,m(p,2)/q;
        m(p,1)/q,m(p,3)/q,m(p,1)/q,m(p,3)/q;
        m(p,3)/q,m(p,2)/q,m(p,3)/q,m(p,2)/q]; 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% perform Integer Transfrom on each 4x4 block
frameTr = integerTransform(frame,C);

% apply quantization
quantized = amulb(frameTr,M);

% apply scaling swift by 15 bits
scaled = round(quantized/2^15);
    
videoEncoder = scaled;	
    
    


