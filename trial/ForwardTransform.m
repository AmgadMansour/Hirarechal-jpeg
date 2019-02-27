function [videoEncoder]=ForwardTransform(frame,QP)

%Integer Transform 
 frameY = frame.Y; 
 frameU = frame.U; 
 frameV = frame.V;

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
    M =[m(QP,0),m(QP,2),m(QP,0),m(QP,2);
        m(QP,2),m(QP,1),m(QP,2),m(QP,1);
        m(QP,0),m(QP,2),m(QP,0),m(QP,2);
        m(QP,2),m(QP,1),m(QP,2),m(QP,1)];
else
    p = mod(QP,6);
    q = pow(2,floor(QP/6));
    M =[m(p,0)/q,m(p,2)/q,m(p,0)/q,m(p,2)/q;
        m(p,2)/q,m(p,1)/q,m(p,2)/q,m(p,1)/q;
        m(p,0)/q,m(p,2)/q,m(p,0)/q,m(p,2)/q;
        m(p,2)/q,m(p,1)/q,m(p,2)/q,m(p,1)/q]; 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% perform Integer Transfrom on each 4x4 block
frameTrY = blockproc(frameY,[4 4],'integerTransform',C);
frameTrU = blockproc(frameU,[4 4],'integerTransform',C);
frameTrV = blockproc(frameV,[4 4],'integerTransform',C);

% apply quantization
quantizedY = blockproc(frameTrY,[4 4],'amulb',M);
quantizedU = blockproc(frameTrU,[4 4],'amulb',M);
quantizedV = blockproc(frameTrV,[4 4],'amulb',M);

% apply scaling swift by 15 bits
scaledY = round(quantizedY/pow(2,15));
scaledU = round(quantizedU/pow(2,15));
scaledV = round(quantizedV/pow(2,15));
    

    
videoEncoder = struct('Y',scaledY,'U',scaledU,'V',scaledV);	
    
    


