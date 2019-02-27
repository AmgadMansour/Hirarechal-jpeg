function [diff_struct]=intra_coding(mb)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%The function perofrms intra coding on the given macrblock 'mb' of size 16x16x3, we apply three
%modes and choose the one with smallest Sum of Absolute Difference for each 4x4 microblock.
%The output is the differntial macroblock = intracoded macroblock - original macroblock
% intra modes is a 4x4 matrix representing to which 4x4 block mode is
% either 0,1 or 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
diff_struct = struct;
diff_struct.diff_blk = zeros(16,16,3);
diff_struct.intra_modes = zeros(4,4,3);

for band = 1:3
    SAD = zeros(1,3);
    mb_band = mb(:,:,band);
    i = 1;
    j = 1;
    %(i,j) represent which 4x4 block we are at 
    intra_modes_bnd = zeros(4,4);
    intra_blk = zeros(16,16);
    mborig = mb_band;

    for i = 1:4
        for j = 1:4
    r = 4*i-3;
    c = 4*j-3;
    cur_block = double(mb_band(r:r+3,c:c+3));

if i ~= 1 && j ~= 1	
  T = mb_band(r-1,c:c+3); %TOP pixels above the block
  Lt = mb_band(r:r+3,c-1); %LEFT pixels before the block
elseif i == 1 && j == 1
  T = mb_band(1,1:4);
  Lt = mb_band(1:4,1);
elseif i == 1
  T = mb_band(1,c:c+3);
  Lt = mb_band(r:r+3,c-1);
elseif j == 1
  T = mb_band(r-1,c:c+3);
  Lt = mb_band(r:r+3,1);  
end
    
L = transpose(Lt);
% Call Different Mode Functions for N=4
c0=mode0(T,j,cur_block);   %Vertical Replication
c1=mode1(L,i,cur_block);   %Horizonatal Replication
c2=mode2(L,T,i,j,cur_block); %Mean / DC
  
   
% Calculte Sum of Absolute difference for each block from the modes
SAD(1,1) =  sum(sum(abs(c0-cur_block)));
SAD(1,2) =  sum(sum(abs(c1-cur_block)));
SAD(1,3) =  sum(sum(abs(c2-cur_block)));
 
% Selection based on Min SAD
min_SAD = min(SAD);
switch min_SAD
    case SAD(1,1)
            intra=c0;  
            intra_modes_bnd(i,j) = 0;
    case SAD(1,2)
            intra=c1;
            intra_modes_bnd(i,j) = 1;
    case SAD(1,3)
            intra=c2;
            intra_modes_bnd(i,j) = 2;        
end

    intra_blk(r:r+3,c:c+3) = intra;
    mb_band(r:r+3,c:c+3) = intra;

    end   
end 

    diff_blk = intra_blk - mborig;
    diff_blk(1,1:16) = mborig(1,1:16);
    diff_blk(1:16,1) = mborig(1:16,1);
    diff_struct.diff_blk(:,:,band) = diff_blk;
    diff_struct.intra_modes(:,:,band) = intra_modes_bnd;
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
