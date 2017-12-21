% Demonstrate face image relighting
%
% Chen, Xiaowu, et al. "Face illumination transfer through edge-preserving filters." Computer Vision and Pattern Recognition (CVPR), 2011 IEEE Conference on. IEEE, 2011.
% 


close all;

% Input 
source_name = 'ss2';
ref_name = 'ref1';

% Reading Images and respective Facial Landmark data
img=  imresize(im2double(imread(['nimg/' source_name '.PNG'])), 1);
shape_pt = load(['nimg/' source_name '.mat']);
shape_pt =double(shape_pt.shape);

imgA=  imresize(im2double(imread(['nimg/' ref_name '.PNG'])), 1);
shape = load(['nimg/' ref_name '.mat']);
shape =double(shape.shape);


% Light Transfer 
results=relight( ...
        img, ...
        shape_pt, ...
        imgA, ...
        shape ...
        );
    
% Display Results
figure(1);
subplot(131);imshow(img);title('Source');
subplot(132);imshow(imgA);title('Reference');
subplot(133);imshow(results.out_img);title('Output');

% Saving Result
imwrite(results.out_img./(max(results.out_img(:))),[source_name '_' ref_name '_ours.png']);
