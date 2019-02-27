function [orig_blk_bnds]=intra_decoding(diff_blk_bnds,intra_modes_bnds)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%The function performs intra decoding on the given macrblock of size 16x16
%original decoded block is calcuated as sum of difference block and the regenerated
%intra coded block
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for band = 1:3
    
    diff_blk = diff_blk_bnds(:,:,band);
    intra_modes = intra_modes_bnds(:,:,band);
    
    i = 1;
    j = 1;
    %(i,j) represent which 4x4 block we are at 
    intra_blk = zeros(16,16);
    orig_blk = zeros(16,16);
    intra_blk(1,1:16) = diff_blk(1,1:16);
    intra_blk(1:16,1) = diff_blk(1:16,1);

    for i = 1:4
        for j = 1:4
    r = 4*i-3;
    c = 4*j-3;
    cur_block = double(intra_blk(r:r+3,c:c+3));

    if i ~= 1 && j ~= 1	
      T = intra_blk(r-1,c:c+3); %TOP pixels above the block
      Lt = intra_blk(r:r+3,c-1); %LEFT pixels before the block
    elseif i == 1 && j == 1
      T = intra_blk(1,1:4);
      Lt = intra_blk(1:4,1);
    elseif i == 1
      T = intra_blk(1,c:c+3);
      Lt = intra_blk(r:r+3,c-1);
    elseif j == 1
      T = intra_blk(r-1,c:c+3);
      Lt = intra_blk(r:r+3,1);  
    end

    L = transpose(Lt);


% Selection based on given modes
    mode = intra_modes(i,j);
switch mode
    case 0
            intra=mode0(T,j,cur_block);  
    case 1
            intra=mode1(L,i,cur_block);
    case 2
            intra=mode2(L,T,i,j,cur_block);
end

intra_blk(r:r+3,c:c+3) = intra;
    end   
    end 

    orig_blk = intra_blk - diff_blk;
    orig_blk(1,1:16) = diff_blk(1,1:16);
    orig_blk(1:16,1) = diff_blk(1:16,1);
    orig_blk_bnds(:,:,band) = orig_blk;

end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%MODE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=mode0(T,j,cb)
    for x=1:4
       for y=1:4
           if y == 1 && j == 1 
           out(x,y) =  cb(x,y);   
           else 
           out(x,y)=T(1,y); % Vertical Replication
           end
        end
    end
end

function out=mode1(L,i,cb)
    for x=1:4
        for y=1:4
            if x == 1 &&  i == 1
                out(x,y) =  cb(x,y); 
            else
                out(x,y)=L(1,y);  % Horizonatal Replication
            end
        end
    end
end

function out=mode2(L,T,i,j,cb)
    for x=1:4
        for y=1:4
            if (i == 1 && x == 1) || (j == 1 && y == 1)
                out(x,y) =  cb(x,y);
            else 
            out(x,y)=round(mean([L(1:4) T(1:4)]));  % Mean / DC, ound(mean([L(1:N) T(1:N) 4]))?? 
            end
        end
    end
end
