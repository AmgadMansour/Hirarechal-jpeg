function [vid] = readVideo()
vidPath = '/Users/macbookair/Desktop/Multimedia Systems/Ass2/vc/SampleVideo_640x360_1mb.mp4';
framePath = '/Users/macbookair/Desktop/Multimedia Systems/Ass2/vc/frames/';
vid = VideoReader(vidPath);
n = vid.NumberOfFrames;
for i = 1:1:n
  frames = read(vid,i);
  imwrite(frames,[framePath int2str(i), '.jpg']);
end 
end
