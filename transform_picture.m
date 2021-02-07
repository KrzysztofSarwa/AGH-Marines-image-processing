%old_pic = imread('Zdj4.png');
%new_pic = imread('Zdj2.png');
function [old_pic,new_pic,new_pic_recovered_RGB,new_pic_recovered_gray] = transform_picture(old_pic,new_pic)

% imshow(old_pic);title('Old picture');
% figure
% imshow(new_pic);title('New picture');

old_pic_gray = rgb2gray(old_pic);
new_pic_gray = rgb2gray(new_pic);

%% Step 3   FEATURE FINDING
ptsOriginal  = detectSURFFeatures(old_pic_gray);
ptsDistorted = detectSURFFeatures(new_pic_gray);
[featuresOriginal,   validPtsOriginal]  = extractFeatures(old_pic_gray,  ptsOriginal);
[featuresDistorted, validPtsDistorted]  = extractFeatures(new_pic_gray, ptsDistorted);
indexPairs = matchFeatures(featuresOriginal, featuresDistorted);
matchedOriginal  = validPtsOriginal(indexPairs(:,1));
matchedDistorted = validPtsDistorted(indexPairs(:,2));

% Putatively matched features
%showMatchedFeatures(old_pic_gray,new_pic_gray,matchedOriginal,matchedDistorted,'montage','Parent',axes);
%title('Putatively matched points (including outliers)');

%% Step 4        FINDING THE TRANSFORMATION
[tform, inlierDistorted, inlierOriginal] = estimateGeometricTransform(matchedDistorted, matchedOriginal, 'similarity');

% Matched points
%figure;
%showMatchedFeatures(old_pic_gray,new_pic_gray,inlierOriginal,inlierDistorted);
%title('Matching points (inliers only)');
%legend('ptsOriginal','ptsDistorted');

%% Step 5         
%Tinv  = tform.invert.T;
%ss = Tinv(2,1);
%sc = Tinv(1,1);
%scaleRecovered = sqrt(ss*ss + sc*sc)
%thetaRecovered = atan2(ss,sc)*180/pi

%% Step 6
outputView = imref2d(size(old_pic_gray));
new_pic_recovered_RGB  = imwarp(new_pic,tform,'OutputView',outputView); 
new_pic_recovered_gray  = imwarp(new_pic_gray,tform,'OutputView',outputView);

%figure, 
%imshowpair(old_pic,new_pic_recovered_RGB,'montage');title('Old picture (gary) and new picture (gray) recovered');

%figure, 
%imshowpair(old_pic_gray,new_pic_recovered_gray,'montage');title('Old picture (gary) and new picture (gray) recovered');
end

