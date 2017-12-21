function rect = get_boundingBox(img,pt)
% create the mask of convex hull of pt
    [X,Y] = meshgrid(1:size(img, 2), 1:size(img, 1));
    ch = convhulln(pt);
    mask = inpolygon(X,Y,pt(ch(:,1),1),pt(ch(:,1),2));
    margin = 5;
    xpro = sum(mask, 1); ypro = sum(mask, 2);
    left = max(min(find(xpro>0))-margin, 0); right = min(max(find(xpro>0))+margin, size(mask, 2));
    up = max(min(find(ypro>0))-margin, 0); down = min(max(find(ypro>0))+margin, size(mask, 1));
    rect = [left, up, right-left+1, down-up+1];
end

