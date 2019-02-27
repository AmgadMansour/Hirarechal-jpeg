
function GUI_demo()

%%
% Initialize the video reader.
videoSrc = vision.VideoFileReader('SampleVideo_640x360_1mb.mp4', 'ImageColorSpace', 'RGB');
videoSrc_dec = vision.VideoFileReader('decoded_Q5.avi', 'ImageColorSpace', 'RGB');


%% 
% Create a figure window and two axes to display the input video and the
% processed video.
[hFig, hAxes] = createFigureAndAxes();

%%
% Add buttons to control video playback.
insertButtons(hFig, hAxes, videoSrc);

%% Interact with the New User Interface
% Now that the GUI is constructed, we can press the play button to trigger
% the main video processing loop defined in the |getAndProcessFrame| function
% listed below.

% Initialize the display with the first frame of the video
frame = getAndProcessFrame(videoSrc, 0);
frame_dec = getAndProcessFrame(videoSrc_dec, 0);
% Display input video frame on axis
showFrameOnAxis(hAxes.axis1, frame);
showFrameOnAxis(hAxes.axis2, frame_dec);

%%
% Note that each video frame is centered in the axis box. If the axis size
% is bigger than the frame size, video frame borders are padded with
% background color. If axis size is smaller than the frame size scroll bars
% are added.

%% Create Figure, Axes, Titles
% Create a figure window and two axes with titles to display two videos.
    function [hFig, hAxes] = createFigureAndAxes()

        % Close figure opened by last run
        figTag = 'CVST_VideoOnAxis_9804532';
        close(findobj('tag',figTag));

        % Create new figure
        hFig = figure('numbertitle', 'off', ...
               'name', 'Video In Custom GUI', ...
               'menubar','none', ...
               'toolbar','none', ...
               'resize', 'on', ...
               'tag',figTag, ...
               'renderer','painters', ...
               'position',[680 678 480 240],...
               'HandleVisibility','callback'); % hide the handle to prevent unintended modifications of our custom UI

        % Create axes and titles
        hAxes.axis1 = createPanelAxisTitle(hFig,[0.1 0.2 0.36 0.6],'Original Video'); % [X Y W H]
        hAxes.axis2 = createPanelAxisTitle(hFig,[0.5 0.2 0.36 0.6],'Decoded Video');
        
    end

%% Create Axis and Title
% Axis is created on uipanel container object. This allows more control
% over the layout of the GUI. Video title is created using uicontrol.
    function hAxis = createPanelAxisTitle(hFig, pos, axisTitle)

        % Create panel
        hPanel = uipanel('parent',hFig,'Position',pos,'Units','Normalized');

        % Create axis   
        hAxis = axes('position',[0 0 1 1],'Parent',hPanel); 
        hAxis.XTick = [];
        hAxis.YTick = [];
        hAxis.XColor = [1 1 1];
        hAxis.YColor = [1 1 1];
        % Set video title using uicontrol. uicontrol is used so that text
        % can be positioned in the context of the figure, not the axis.
        titlePos = [pos(1)+0.02 pos(2)+pos(3)+0.3 0.3 0.07];
        uicontrol('style','text',...
            'String', axisTitle,...
            'Units','Normalized',...
            'Parent',hFig,'Position', titlePos,...
            'BackgroundColor',hFig.Color);
    end

%% Insert Buttons
% Insert buttons to play, pause the videos.
    function insertButtons(hFig,hAxes,videoSrc)

        % Play button with text Start/Pause/Continue
        uicontrol(hFig,'unit','pixel','style','pushbutton','string','Start',...
                'position',[10 10 75 25], 'tag','PBButton123','callback',...
                {@playCallback,videoSrc,hAxes});

        % Exit button with text Exit
        uicontrol(hFig,'unit','pixel','style','pushbutton','string','Exit',...
                'position',[100 10 50 25],'callback', ...
                {@exitCallback,videoSrc,hFig});
    end     

%% Play Button Callback
% This callback function rotates input video frame and displays original
% input video frame and rotated frame on axes. The function
% |showFrameOnAxis| is responsible for displaying a frame of the video on
% user-defined axis. This function is defined in the file
% <matlab:edit(fullfile(matlabroot,'examples','vision','main','showFrameOnAxis.m')) showFrameOnAxis.m>
    function playCallback(hObject,~,videoSrc,hAxes)
       try
            % Check the status of play button
            isTextStart = strcmp(hObject.String,'Start');
            isTextCont  = strcmp(hObject.String,'Continue');
            if isTextStart
               % Two cases: (1) starting first time, or (2) restarting 
               % Start from first frame
               if isDone(videoSrc)
                  reset(videoSrc);
               end
            end
            if (isTextStart || isTextCont)
                hObject.String = 'Pause';
            else
                hObject.String = 'Continue';
            end

            % Rotate input video frame and display original and rotated
            % frames on figure
            angle = 0;            
            while strcmp(hObject.String, 'Pause') && ~isDone(videoSrc)  
                % Get input video frame and rotated frame
                [frame,rotatedImg,angle] = getAndProcessFrame(videoSrc,angle); 
                % Display input video frame on axis
                showFrameOnAxis(hAxes.axis1, frame);
                
                % Display rotated video frame on axis
                [frame_dec,rotatedImg,angle] = getAndProcessFrame(videoSrc_dec,angle);
                showFrameOnAxis(hAxes.axis2, frame_dec);    
            end

            % When video reaches the end of file, display "Start" on the
            % play button.
            if isDone(videoSrc)
               hObject.String = 'Start';
            end
       catch ME
           % Re-throw error message if it is not related to invalid handle 
           if ~strcmp(ME.identifier, 'MATLAB:class:InvalidHandle')
               rethrow(ME);
           end
       end
    end

%% Video Processing Algorithm
% This function defines the main algorithm that is invoked when play button
% is activated.
    function [frame,rotatedImg,angle] = getAndProcessFrame(videoSrc,angle)
        
        % Read input video frame
        frame = step(videoSrc);
        
        % Pad and rotate input video frame
        paddedFrame = padarray(frame, [30 30], 0, 'both');
        rotatedImg  = imrotate(paddedFrame, angle, 'bilinear', 'crop');
        angle       = angle + 1;
    end

%% Exit Button Callback
% This callback function releases system objects and closes figure window.
    function exitCallback(~,~,videoSrc,hFig)
        
        % Close the video file
        release(videoSrc); 
        % Close the figure window
        close(hFig);
    end



end
