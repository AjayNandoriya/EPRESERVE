function light_mask=cvpr_2011(img,pt)
% create the mask of convex hull of pt
[X,Y] = meshgrid(1:size(img, 2), 1:size(img, 1));
ch = convhulln(pt);
mask = inpolygon(X,Y,pt(ch(:,1),1),pt(ch(:,1),2));


% check for light component
if(size(img,3)==3)
    Ihsv = rgb2hsv(img);
    Il = Ihsv(:,:,3);
else
    Il = img;
end

% reduce small edges
Il = imfilter(Il,fspecial('gaussian',11),'symmetric');

c=1;
% lamda = c + 10*R;

% lamda = mask.*(mask + imfilter(3*edge(Il),fspecial('gaussian',5),'symmetric'));
lamda = mask.*(mask + imdilate(3*edge(Il),strel('disk',1)));


% need to confirm whether it is log(I)(old) or just I
L = Il;%log(Il+1);

[Lx,Ly]=gradient(L);


[h,w]=size(L);
[Gx,Gy]=getGMat(h,w);


alpha = 1;
Wx = mask.*lamda./((abs(Lx)).^alpha+0.0001);
Wy = mask.*lamda./((abs(Ly)).^alpha+0.0001);

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
light_mask = reshape(Is,h,w);


