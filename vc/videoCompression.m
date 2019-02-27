

function videoCompression(QP)
QP
fprintf(QP);
vid = readVideo();

encodedVideo = encodeVideo(vid,QP);

decodedVideo = decodeVideo(encodedVideo);

end

function encodedVideo =  encodeVideo(vid,QP)

% Frame type pattern (repeats for entire video)
%fpat = 'IBBP';
fpat = 'IPPP';
% Loop over frames
k = 0;
pf = [];
for i = 1:vid.NumberOfFrames
    
    % Get frame
    f = read(vid,i);
    
    % Convert frame to YCrCb
    f = rgb2yuv(f);
    
    % Get frame type
    k = k + 1;
    if k > length(fpat)
        k = 1;
    end
    ftype = fpat(k);
    
    % Encode frame
    [encodedVideo{i},pf] = encodeFrame(f,ftype,pf,QP);    
end
end

function [mpeg,df] = encodeFrame(f,ftype,pf,QP)

[M,N,i] = size(f);
mbsize = [M, N] / 16;
mpeg = struct('type',[],'mvx',[],'mvy',[],'scale',[],'coef',[],'modes',[]);

mpeg(mbsize(1),mbsize(2)).type = [];

% Loop over macroblocks
pfy = pf(:,:,1);
df = zeros(size(f));
for m = 1:mbsize(1)
    for n = 1:mbsize(2)
        
        % Encode one macroblock
        x = 16*(m-1)+1 : 16*(m-1)+16;
        y = 16*(n-1)+1 : 16*(n-1)+16;
        [mpeg(m,n),df(x,y,:)] = encodeMacroblock(f(x,y,:),ftype,pf,pfy,x,y,QP);
        
    end % macroblock loop
end % macroblock loop
end

function [mpeg,decodedMacroblock] = encodeMacroblock(mb,ftype,pf,pfy,x,y,QP)

% Quality scaling
%QP = 50;

% Init mpeg struct
mpeg.type = 'I';
mpeg.mvx = 0;
mpeg.mvy = 0;
mpeg.modes = zeros(4,4,3);


%intra coding of I frame
if ftype == 'I'
    % add code from intra_coding file
    [diff_struct]=intra_coding(mb);
    %for the decoded blk: diff_struct.diff_blk
    %for the intra modes: diff_struct.intra_modes
    %mpeg.mb = diff_struct.diff_blk;
    mpeg.modes = diff_struct.intra_modes;
    mb = diff_struct.diff_blk;
    
end

% Find motion vectors
if ftype == 'P'
    mpeg.type = 'P';
    [mpeg,emb] = getmotionvec(mpeg,mb,pf,pfy,x,y);
    mb = emb; % Set macroblock to error for encoding
end

b = getblocks(mb);

% Encode blocks
for i = 6:-1:1
    mpeg.scale(i) = QP;
    mpeg.coef(:,:,i) = blkproc(b(:,:,i),[4 4],'ForwardTransform',QP);
end

% Decode this macroblock for reference by a future P frame
decodedMacroblock = decodeMacroblock(mpeg,pf,x,y,QP);


end


function b = getblocks(mb)

b = zeros([8, 8, 6]);

% Four lum blocks
b(:,:,1) = mb( 1:8,  1:8,  1);
b(:,:,2) = mb( 1:8,  9:16, 1);
b(:,:,3) = mb( 9:16, 1:8,  1);
b(:,:,4) = mb( 9:16, 9:16, 1);

% Two subsampled chrom blocks (mean of four neighbors)
b(:,:,5) = 0.25 * ( mb(1:2:15,1:2:15, 2) + mb(1:2:15,2:2:16, 2) ...
                  + mb(2:2:16,1:2:15, 2) + mb(2:2:16,2:2:16, 2) );
b(:,:,6) = 0.25 * ( mb(1:2:15,1:2:15, 3) + mb(1:2:15,2:2:16, 3) ...
                  + mb(2:2:16,1:2:15, 3) + mb(2:2:16,2:2:16, 3) );
end


function [mpeg,emb] = getmotionvec(mpeg,mb,pf,pfy,x,y)

% Do search in Y only
mby = mb(:,:,1);
[M,N] = size(pfy);

% Logarithmic search
step = 8; % Initial step size for logarithmic search

dx = [0 1 1 0 -1 -1 -1  0  1]; % Unit direction vectors
dy = [0 0 1 1  1  0 -1 -1 -1]; % [origin, right, right-up, up, left-up,
                               %         left, left-down, down, right-down]

mvx = 0;
mvy = 0;
while step >= 1
    
    minsad = inf;
    for i = 1:length(dx)
        
        tx = x + mvx + dx(i)*step;
        if (tx(1) < 1) || (M < tx(end))
            continue
        end
        
        ty = y + mvy + dy(i)*step;
        if (ty(1) < 1) || (N < ty(end))
            continue
        end
        
        sad = sum(sum(abs(mby-pfy(tx,ty))));
        
        if sad < minsad
            ii = i;
            minsad = sad;
        end
        
    end
    
    mvx = mvx + dx(ii)*step;
    mvy = mvy + dy(ii)*step;
    
    step = step / 2;
    
end

mpeg.mvx = mvx; % Store motion vectors
mpeg.mvy = mvy;

emb = mb - pf(x+mvx,y+mvy,:); % Error macroblock
end 

function mb = decodeMacroblock(mpeg,pf,x,y,QP)

% scale
%QP = 5;

mb = zeros(16,16,3);

% Predict with motion vectors
if mpeg.type == 'P'
    mb = pf(x+mpeg.mvx,y+mpeg.mvy,:);
end

% Decode blocks
for i = 6:-1:1
    b(:,:,i) = blkproc(mpeg.coef(:,:,i),[4 4],'InverseTransform',mpeg.scale(i));
end

% Construct macroblock
mb = mb + putblocks(b);

% Intra decoding of macroblock for I frame
if mpeg.type == 'I'
    % add code from intra_decoding file 
    mb =intra_decoding(mb,mpeg.modes);
    
end

end

function mb = putblocks(b)

mb = zeros([16, 16, 3]);

% Four lum blocks
mb( 1:8,  1:8,  1) = b(:,:,1);
mb( 1:8,  9:16, 1) = b(:,:,2);
mb( 9:16, 1:8,  1) = b(:,:,3);
mb( 9:16, 9:16, 1) = b(:,:,4);

% Two subsampled chrom blocks
z = [1 1; 1 1];
mb(:,:,2) = kron(b(:,:,5),z);
mb(:,:,3) = kron(b(:,:,6),z);
end

function decodedVideo = decodeVideo(mpeg)

videosize = size(mpeg{1});
decodedVideo = repmat(uint8(0),[16*videosize(1:2), 3, length(mpeg)]);

% Loop over frames
pf = [];
for j = 1:length(mpeg)
    
    % Decode frame
    f = decodeFrame(mpeg{j},pf);
    
    % Cache previous frame
    pf = f;
    
    % Convert frame to RGB
    f = yuv2rgb(f);
    
    % Make sure movie is in 8 bit range
    f = min( max(f,0), 255);
    
    % Store frame
    decodedVideo(:,:,:,j) = uint8(f);
    framePath = '/Users/macbookair/Desktop/Multimedia Systems/Ass2/vc/results/';
    imwrite(f,[framePath int2str(j), '.jpg']);
end
end

function fr = decodeFrame(mpeg,pf)

mbsize = size(mpeg);
M = 16 * mbsize(1);
N = 16 * mbsize(2);

% Loop over macroblocks
fr = zeros(M,N,3);
for m = 1:mbsize(1)
    for n = 1:mbsize(2)
        
        % Construct frame
        x = 16*(m-1)+1 : 16*(m-1)+16;
        y = 16*(n-1)+1 : 16*(n-1)+16;
        fr(x,y,:) = decodeMacroblock(mpeg(m,n),pf,x,y);
        
    end % macroblock loop
end % macroblock loop
end 
