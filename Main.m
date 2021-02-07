params = controlParams;   
cam = ipcam('rtsp://192.168.1.88/mjpeg');
i = 0;
while(i<30) 
    %img = readImage(imgSub.LatestMessage);
    %img = imread('Zdj3.png');

    preview(cam)
    img = snapshot(cam);
    %% PROCESS
    % Object detection algorithm
    resizeScale = 1;
    [centerX,centerY,circleSize] = object_detection(img,resizeScale);
    % Object tracking algorithm
    [v,wX,wY] = object_tracking(centerX,centerY,circleSize,size(img,2),size(img,1),params);
    % Display velocity results
    fprintf('Forward/Backward: %f,       X: %f,      Y: %f,  i: %f\n',v,wX,wY,i);
    %% CONTROL
    % Package ROS message and send to the robot
    %velMsg.Linear.X = v;
    %velMsg.Angular.Z = w;
    %send(velPub,velMsg);
    if v == 0 && wX == 0 && wY == 0 && centerX ~= 0
       i = i + 1;
       if i == 30
       NewPic = img;  
       close;
       end    
    else
        i = 0;
    end
    
    %% VISUALIZE
    % Annotate image and update the video player
    img = insertShape(img,'Circle',[centerX centerY circleSize/2],'LineWidth',2);
    %step(vidPlayer,img);
    imshow(img);  
    hold on 
    plot(centerX, centerY,'*');
end

change_detection(OldPic,NewPic)
figure;imshow(OldPic);



%% Paste this to command window to see detected changes
%OldPic = imread('Zdj4.png');
% NewPic = imread('Zdj2.png');
% wykrywanie_zmian(OldPic,NewPic)
% figure;imshow(OldPic);
