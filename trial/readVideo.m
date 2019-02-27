function readVideo(vidPath)
vidPath = '/Users/macbookair/Desktop/Multimedia Systems/Ass2/vc/SampleVideo_640x360_1mb.mp4';
vid = VideoReader(vidPath);
n = vid.NumberOfFrames;
for i = 1:1:n
  frames = read(vid,i);
  imwrite(frames,['frames/' int2str(i), '.jpg']);
end 
end
