%old_pic = imread('Zdj4.png');
%new_pic= imread('Zdj2.png');
function change_detection(old_pic,new_pic)
[old_pic,new_pic,new_pic_recovered_RGB, new_pic_recovered_gray] = transform_picture(old_pic,new_pic);


%% 1. CHANGE OF COLORED AREAS

%% 1.1 Binarization with mask - colored areas

[old_pic_binarized,~] = createMask(old_pic);
[new_pic_binarized,~] = createMask(new_pic_recovered_RGB);
%imshowpair(old_pic_binarized,new_pic_binarized,'montage')

struct_elem_1_1 = strel('cube',7); %Morphological structuring element                                         !!!!!! HAS A BIG INFLUENCE ON RESULT

old_pic_binarized_open = imopen(old_pic_binarized,struct_elem_1_1);
old_pic_binarized_close = imclose(old_pic_binarized_open,struct_elem_1_1);

new_pic_binarized_open = imopen(new_pic_binarized,struct_elem_1_1);
new_pic_binarized_close = imclose(new_pic_binarized_open,struct_elem_1_1);

% Old image befeore and after opening and closing operation
% A = cat(2,old_pic_binarized,old_pic_binarized_open,old_pic_binarized_close);
% montage(A);
% title('old-pic-binarized   /   old-pic-binarized-open   /   old-pic-binarized-close');

% New image befeore and after opening and closing operation
% A = cat(2,new_pic_binarized,new_pic_binarized_open,new_pic_binarized_close);
% figure;montage(A);
% title('new-pic-binarized   /   new-pic-binarized-open   /   new-pic-binarized-close');

%% 1.2 Detection of a reduction - colored ares

struct_elem_1_2 = strel('cube',11); %Morphological structuring element                                        !!!!!! HAS A BIG INFLUENCE ON RESULT

%REDUCTION
reduction_area = uint8(old_pic_binarized_close-new_pic_binarized_close);
reduction_area = logical(reduction_area); %need logical for imshow to work
reduction_area_open = imopen(reduction_area,struct_elem_1_2);

% A = cat(2,old_pic_binarized_close,new_pic_binarized_close,reduction_area_open);
% figure;montage(A);
% title('old-pic-binarized-close   /   new-pic-binarized-close   /   reduction-area-open');



[im_lb_reduction, num_of_reduction] = bwlabel(reduction_area_open,4);
feats_reduction = regionprops(im_lb_reduction,'Area','BoundingBox');

figure;imshow(old_pic);
figure;imshow(new_pic_recovered_RGB);
hold on
min_area_redution = 100;     % minimum size of detected objects                                                      !!!!!! HAS A BIG INFLUENCE ON RESULT
for i=1:num_of_reduction
    if(feats_reduction(i).Area > min_area_redution)        
    rectangle('Position', [feats_reduction(i).BoundingBox(1)-10 feats_reduction(i).BoundingBox(2)-10 feats_reduction(i).BoundingBox(3)+20 feats_reduction(i).BoundingBox(4)+20], 'Curvature', 0.3, 'EdgeColor', 'y', 'LineWidth', 3);
    end
end


%% 1.3 Detection of growth - colored areas

struct_elem_1_3 = strel('cube',11); %Morphological structuring element                                        !!!!!! HAS A BIG INFLUENCE ON RESULT

%Detection of any changes
any_changes = abs(old_pic_binarized_close-new_pic_binarized_close);
any_changes_open = imopen(any_changes,struct_elem_1_3);
%figure;imshowpair(any_changes,any_changes_open,'montage');title('any-changes   /   any-changes-open');

%GROWTH
growth = any_changes_open - reduction_area_open;
growth = logical(growth);
growth_open = imopen(growth,struct_elem_1_3);
%figure;imshowpair(growth,growth_open,'montage');title('growth   /   growth_open');



[im_lb_growth, num_of_growth] = bwlabel(growth_open,4);
feats_growth = regionprops(im_lb_growth,'Area','BoundingBox');

% figure;imshow(old_pic);
% figure;imshow(new_pic_recovered_RGB);
hold on
min_area_growth = 500;     % minimum size of detected objects                                                      !!!!!! HAS A BIG INFLUENCE ON RESULT
for i=1:num_of_growth
    if(feats_growth(i).Area > min_area_growth)
    rectangle('Position', [feats_growth(i).BoundingBox(1)-10 feats_growth(i).BoundingBox(2)-10 feats_growth(i).BoundingBox(3)+20 feats_growth(i).BoundingBox(4)+20], 'Curvature', 0.3, 'EdgeColor', 'g', 'LineWidth', 3);
    end
end

%% 2. CHANGE OF WHITE AREA

%% 2.1 Binarization with threshold - white areas
%orginal/wrong method
% treshhold1 = graythresh(old_pic);
% treshhold2 = 0.6851;  %graythresh(new_pic_recovered_RGB);
% old_pic_binarized = im2bw(old_pic,treshhold1);
% new_pic_binarized = im2bw(new_pic_recovered_RGB,treshhold2);

% rgb to gray -> finding the threshold -> binarization
old_pic_gray = rgb2gray(old_pic);
new_pic_gray = rgb2gray(new_pic_recovered_RGB);

old_pic_treshhold = graythresh(old_pic_gray);     %                                   !!!!!! HAS A BIG INFLUENCE ON RESULT
new_pic_treshhold = 0.6851; %graythresh(new_pic_gray) - does not working properly, need to find better solution   %         !!!!!! HAS A BIG INFLUENCE ON RESULT

w_old_pic_binarized = im2bw(old_pic_gray,old_pic_treshhold);
w_new_pic_binarized = im2bw(new_pic_gray,new_pic_treshhold);

% opening and closing operation
struct_elem_2_1 = strel('cube',7); %Morphological structuring element                                        !!!!!! HAS A BIG INFLUENCE ON RESULT

w_old_pic_binarized_open = imopen(w_old_pic_binarized,struct_elem_2_1);
w_old_pic_binarized_close = imclose(w_old_pic_binarized_open,struct_elem_2_1);

w_new_pic_binarized_open = imopen(w_new_pic_binarized,struct_elem_2_1);
w_new_pic_binarized_close = imclose(w_new_pic_binarized_open,struct_elem_2_1);


% Old image in gary scale, binarized, binarized with opening and binarized with closing
% imshow(old_pic_gray);
% title('old-pic-gray');
% A_2_1 = cat(2,w_old_pic_binarized,w_old_pic_binarized_open,w_old_pic_binarized_close);
% figure;montage(A_2_1);
% title('w-old-pic-binarized   /   w-old-pic-binarized-open   /   w-old-pic-binarized-close');


% New image in gary scale, binarized, binarized with opening and binarized with closing
% imshow(new_pic_gray);
% title('new-pic-gray');
% A = cat(2,w_new_pic_binarized,w_new_pic_binarized_open,w_new_pic_binarized_close);
% figure;montage(A);
% title('w-new-pic-binarized   /   w-new-pic-binarized-open   /   w-new-pic-binarized-close');



%% 2.2 Detection of a reduction - white ares

%Redution of white areas
struct_elem_2_2 = strel('cube',17); 
w_reduction_area = uint8(w_old_pic_binarized_close-w_new_pic_binarized_close);
w_reduction_area = logical(w_reduction_area); 
w_reduction_area_open = imopen(w_reduction_area,struct_elem_2_2);


% A1 = cat(2,old_pic_gray,new_pic_gray);
% figure;montage(A1);
% title('old-pic-gray   /   new-pic-gray');
% A2 = cat(2,w_old_pic_binarized_close,w_new_pic_binarized_close,w_reduction_area_open);
% figure;montage(A2);
% title('w-old-pic-binarized-close   /   w-new-pic-binarized-close   /   w-reduction-area-open');

[w_im_lb_reduction, w_num_of_reduction] = bwlabel(w_reduction_area_open,4);
w_feats_reduction = regionprops(w_im_lb_reduction,'Area','BoundingBox');

% figure;imshow(old_pic);
% figure
% imshow(new_pic_recovered_RGB);

hold on
w_min_area_reduction = 1000;     % minimum size of detected objects                                                      !!!!!! HAS A BIG INFLUENCE ON RESULT
for i=1:w_num_of_reduction
    if(w_feats_reduction(i).Area > w_min_area_reduction)
    rectangle('Position', w_feats_reduction(i).BoundingBox, 'Curvature', 0.3, 'EdgeColor', 'blue', 'LineWidth', 3);
    end
end

%% 2.3 Detection of growth - white areas
%OLDB2 = imread('a.png');
%OLDB2 = rgb2gray(OLDB2);
%OLDB2 = imbinarize(OLDB2);

%Detection of any  changes
w_any_changes = abs(w_old_pic_binarized_close-w_new_pic_binarized_close);
w_any_changes_open = imopen(w_any_changes,struct_elem_2_1);
%figure;imshowpair(w_any_changes,w_any_changes_open,'montage');title('w-any-changes   /   w-any-changes_open');

%GROWTH
w_growth = w_any_changes_open - w_reduction_area_open;
w_growth_open = imopen(w_growth,struct_elem_2_1);
%figure;imshowpair(w_growth,w_growth_open,'montage');title('w-growth   /   w-growth-open');

[w_im_lb_growth, w_num_of_growth] = bwlabel(w_growth_open,4);
w_feats_growth = regionprops(w_im_lb_growth,'Area','BoundingBox');


% figure;imshow(old_pic);
% figure
% imshow(new_pic_recovered_RGB);
hold on
w_min_area_growth = 500;     % minimum size of detected objects                                                      !!!!!! HAS A BIG INFLUENCE ON RESULT 
for i=1:w_num_of_growth
    if(w_feats_growth(i).Area > w_min_area_growth)              
    rectangle('Position', w_feats_growth(i).BoundingBox, 'Curvature', 0.3, 'EdgeColor', 'red', 'LineWidth', 3);
    end
end
end
%figure;
%imshow(old_pic);
