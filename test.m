clear all;close all;
img =imresize(im2double(imread('imgs/Grant.bmp')), 0.5);
pt = readfp('imgs/Grant.fp')/2;

% img =imresize(im2double(imread('imgs/potter.bmp')), 0.5);
% pt = readfp('imgs/potter.fp')/2;
% img = im2double(imread('imgs/yaleB01_P00A+050E+00.bmp'));
%         pt=readfp('imgs/yaleB01_P00A+050E+00.fp');
% create the mask of convex hull of pt
[X,Y] = meshgrid(1:size(img, 2), 1:size(img, 1));
ch = convhulln(pt);
mask = inpolygon(X,Y,pt(ch(:,1),1),pt(ch(:,1),2));

% eye mask
for k=1:4
    eye_pt= pt(28 + (k-1)*4+(0:3),:);
    ch = convhulln(eye_pt);
    eye_mask_idv = inpolygon(X,Y,eye_pt(ch(:,1),1),eye_pt(ch(:,1),2));
    if k==1
        eye_mask = eye_mask_idv;
    else
        eye_mask = eye_mask  | eye_mask_idv;
    end
end

% mouth mask
mouth_pt= pt(59:62,:);
ch = convhulln(mouth_pt);
mouth_mask = inpolygon(X,Y,mouth_pt(ch(:,1),1),mouth_pt(ch(:,1),2));


% facial weight by region
R = 1 -mask + eye_mask + 0.2*mouth_mask;


figure(1);
subplot(221);imshow(img);
subplot(222);imshow(R,[]);
subplot(223);imshowpair(img,R);

Ihsv = rgb2hsv(img);
Il = Ihsv(:,:,3);
Il = imfilter(Il,fspecial('gaussian',11),'symmetric');

c=1;
lamda = c + 10*R;

lamda = mask.*(mask + imfilter(3*edge(Il),fspecial('gaussian',5),'symmetric'));
lamda = mask.*(mask + imdilate(3*edge(Il),strel('disk',3)));


L = log(Il+1);

[Lx,Ly]=gradient(L);


[h,w]=size(L);
[Gx,Gy]=getGMat(h,w);

Wx = mask.*lamda./((abs(Lx)).^1+0.0001);
Wy = mask.*lamda./((abs(Ly)).^1+0.0001);

% Wx = mask.*lamda;
% Wy = mask.*lamda;

%%
weight_s=0.1;
Wx_mat = weight_s*sparse(1:h*w,1:h*w,Wx(:));
Wy_mat = weight_s*sparse(1:h*w,1:h*w,Wy(:));

A = speye(h*w);
A = [A;Wx_mat*Gx;Wy_mat*Gy];

mask_l = mask.*Il;
B = [mask_l(:);zeros(2*h*w,1)];

Is = A\B;
p = reshape(Is,h,w);
% Is = medfilt2(Is,[5 5],'symmetric');
figure(1);
subplot(241);imshow(mask);title('mask');
subplot(242);imshow(R,[]);title('R');
subplot(243);imshow(lamda,[]);title('lamda');
subplot(244);imshow(L.*mask,[]);title('L');

subplot(245);imshow(p,[]);title('p');colorbar
subplot(246);imshow(Il,[]);title('l');
subplot(247);imshow(abs(Lx) + abs(Ly),[]);title('|Lx| + |Ly|');
subplot(248);imshowpair(p,Il,'diff');title('p-l');

