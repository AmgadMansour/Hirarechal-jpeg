function [intra_blk,intra_mode]=intra_coding(im,i,j)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%The function perofrms intra coding on block (i,j) of size 4, we apply three
%modes and choose the one with smallest Sum of Absolute Difference.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N = 4;
[height, width, dim] = size(im);
SAD = zeros (1,3);          
r =(i-1)*N+1;
c =(j-1)*N+1;
cur_block = double(im(r:r+N-1,c:c+N-1));

for k=1:N
    T(k)=im(r,c+k-1); %TOP pixels above the block
    L(k)=im(r+k-1,c); %LEFT pixels before the block
end

% Call Different Mode Functions for N=4
c0=mode0(T,N);   %Vertical Replication
c1=mode1(L,N);   %Horizonatal Replication
c2=mode2(L,T,N); %Mean / DC
  
   
% Calculte Sum of Absolute difference for each block from the modes
SAD(1,1) =  sum(sum(abs(c0-cur_block)));
SAD(1,2) =  sum(sum(abs(c1-cur_block)));
SAD(1,3) =  sum(sum(abs(c2-cur_block)));
 
% Selection based on Min SAD
min_SAD = min(SAD);
switch min_SAD
    case SAD(1,1)
            intra_blk=c0;  
            intra_mode='Mode 0';
    case SAD(1,2)
            intra_blk=c1;
            intra_mode='Mode 1';
    case SAD(1,3)
            intra_blk=c2;
            intra_mode='Mode 2';        
end
 
end   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%MODE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=mode0(T,N)
    for x=1:N
       for y=1:N
            out(x,y)=T(x); % Vertical Replication
        end
    end
end

function out=mode1(L,N)
    for x=1:N
        for y=1:N
           out(x,y)=L(x);  % Horizonatal Replication
        end
    end
end

function out=mode2(L,T,N))
    for x=1:N
        for y=1:N
            out(x,y)=round(mean([L(1:N) T(1:N) 4]));  % Mean / DC
        end
    end
end
