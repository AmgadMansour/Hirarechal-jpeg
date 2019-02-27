
function intra_blk_decoded =intra_decoding(im,intra_mode,i,j)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function performs the intra decoding, current block (i,j) of size 4.
% The function returns the reconstructed block based on the mode selected earlier
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N = 4;
r =(i-1)*N+1;
c =(j-1)*N+1;
for k=1:N
    T(k)=im(r,c+k-1); %TOP pixels above the block
    L(k)=im(r+k-1,c); %LEFT pixels before the block
end

 switch intra_mode
        case 'Mode 0'
            recons = mode0(T,N);
        case 'Mode 1'     
            recons = mode1(L,N);
        case 'Mode 2'
            recons = mode2(L,T,N);
 end

intra_blk_decoded = uint8(recons);
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%MODE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=mode0(T,N)
    for i=1:N
       for j=1:N
            out(i,j)=T(i); % Vertical Replication
        end
    end
end
function out=mode1(L,N)
    for i=1:N
        for j=1:N
           out(i,j)=L(i);  % Horizonatal Replication
        end
    end
end
function out=mode2(L,T,N)
    for i=1:N
        for j=1:N
            out(i,j)=round(mean([L(1:N) T(1:N) 4]));  % Mean / DC
        end
    end
end
