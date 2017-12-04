% Perform face relighting based on reference images
%
% Jiansheng Chen, Guangda Su, Jinping He, Shenglan Ben, "Face Image 
% Relighting using Locally Constrained Global Optimization", ECCV'10
%
%01-10-10, Jiansheng Chen

% result = img*imgRefA/imgRefB
function results = relight(img, pt, imgRefA, ptRefA)
    results=struct();
    % morphing the reference images
    scaleA = max(size(img,1)/size(imgRefA,1),size(img,2)/size(imgRefA,2));
    imgRefA = imresize(imgRefA, scaleA);    ptRefA = ptRefA*scaleA;
    try
        imgRefA = rgb2gray(imgRefA);
    catch
    end
    imgRefA = morph(imgRefA, ptRefA, pt); imgRefA = imgRefA(1:size(img,1), 1:size(img,2));
    
    
    % create the mask of convex hull of pt
    [X,Y] = meshgrid(1:size(img, 2), 1:size(img, 1));
    ch = convhulln(pt);
    mask = inpolygon(X,Y,pt(ch(:,1),1),pt(ch(:,1),2));
    margin = 5;
    xpro = sum(mask, 1); ypro = sum(mask, 2);
    left = max(find(xpro>0, 1 )-margin, 0); right = min(find(xpro>0, 1, 'last' )+margin, size(mask, 2));
    up = max(find(ypro>0, 1 )-margin, 0); down = min(find(ypro>0, 1, 'last' )+margin, size(mask, 1));
    rect = [left, up, right-left+1, down-up+1];
    
    results.mask= mask;
    mask = imcrop(mask, rect);
    
    results.rect = rect;
    
    imgRefA = imcrop(imgRefA, rect).*mask; 
    hsv_image = rgb2hsv(imcrop(img, rect));
    hsv_image(:,:,1) = hsv_image(:,:,1).*mask;
    hsv_image(:,:,2) = hsv_image(:,:,2).*mask;
    hsv_image(:,:,3) = hsv_image(:,:,3).*mask;
    img_crop = hsv2rgb(hsv_image);
    

    
    % perform illumination separation 
    
    % perform illumination transform using eccv 2011
    pt(:,1)=pt(:,1)-left;
    pt(:,2)=pt(:,2)-up;
    light_maskA = cvpr_2011(imgRefA,pt);
    light_mask = cvpr_2011(img_crop(:,:,3),pt);
    
 
    % guided filter
    light_maskNew = guided_filter(light_mask,light_maskA);
    light_maskNew(isnan(light_maskNew))=0;
    light_maskNew = light_maskNew./(light_mask+0.001);
    hsv_image(:,:,3) = light_maskNew.*hsv_image(:,:,3).*mask;
    
    
    results.out_img = zeros(size(img));
    results.out_img(rect(2)-1 +(1:size(hsv_image,1)),rect(1)-1+(1:size(hsv_image,2)),:)=hsv2rgb(hsv_image);
    
end