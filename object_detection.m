%img = imread('Zdj2.png');
%scale = 1;
function [centerX,centerY,circleSize] = object_detection(img,scale)

% Initialize variables
    centerX = 0;
    centerY = 0;
    blobSize = 0;
    
    % Resize the image
    img = imresize(img,scale,'Antialiasing',false);
    
[~,maskedRGBImage] = object_detection_mask(img);


maskedRGBImage_gray = rgb2gray(maskedRGBImage);
maskedRGBImage_binarized = imbinarize(maskedRGBImage_gray);

    persistent detector
    if isempty(detector)
        detector = vision.BlobAnalysis( ...
                    'BoundingBoxOutputPort',false, ...
                    'AreaOutputPort',false, ...
                    'MajorAxisLengthOutputPort', true, ...
                    'MinimumBlobArea',300, ...
                    'MaximumCount', 10);
    end
    [centroids,majorAxes] = detector(maskedRGBImage_binarized);
    
    % Estimate the blob location and size, if any are large enough
    if ~isempty(majorAxes)
        
        % Find max blob major axis
        [blobSize,maxIdx] = max(majorAxes);
        blobSize = double(blobSize(1));
        
        % Find location of largest blob
        maxLoc = centroids(maxIdx,:);
        centerX = double(maxLoc(1));
        centerY = double(maxLoc(2));
        
    end
    
    % Rescale outputs
    centerX = centerX/scale;
    centerY = centerY/scale;
    blobSize = blobSize/scale;
    circleSize = blobSize;
    
     %% Uncomment to see resoult - circle on rgb picture
     img_with_circle = insertShape(img,'Circle',[centerX centerY circleSize/2],'LineWidth',2);
     imshow(img_with_circle);
     
     figure % Uncomment to see both resoult
     
     %% Uncomment to see resoult - circle on binarized picture
     binarized_img_with_circle = insertShape(double(maskedRGBImage_binarized),'Circle',[centerX centerY circleSize/2],'LineWidth',2);
     imshow(binarized_img_with_circle);
end

