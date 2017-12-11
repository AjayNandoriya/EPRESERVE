% Morph the image according to the control points using kernel function
%
% Jiansheng Chen, Guangda Su, Jinping He, Shenglan Ben, "Face Image 
% Relighting using Locally Constrained Global Optimization", ECCV'10
%
%01-10-10, Jiansheng Chen
function imDst = morph(imSrc, ptSrc, ptDst)

nCtrlPt = length(ptSrc);
Xinv = zeros(size(imSrc,1), size(imSrc,2));
Yinv = zeros(size(imSrc,1), size(imSrc,2));
A = zeros(nCtrlPt+3);
Bx = zeros(nCtrlPt+3, 1);
By = zeros(nCtrlPt+3, 1);

C = zeros(nCtrlPt, 1);
sqdist = zeros(nCtrlPt, 1);
for ki = 1:nCtrlPt % locate nearest point
    X1 = ptDst(ki, 1);
    Y1 = ptDst(ki, 2);
    for kj = 1:nCtrlPt
        X2 = ptDst(kj, 1);
        Y2 = ptDst(kj, 2);
        sqdist(kj) = (X1-X2).^2 + (Y1-Y2).^2;
    end
    sqdist(ki) = inf;
    sqdist(sqdist<5) = inf;
    C(ki) = min(sqdist);
end

for ki = 1:nCtrlPt
    X1 = ptDst(ki, 1);
    Y1 = ptDst(ki, 2);
    for kj = 1:nCtrlPt
        X2 = ptDst(kj, 1);
        Y2 = ptDst(kj, 2);
        A(ki, kj) = 1/sqrt(C(kj)+(X1-X2).^2+(Y1-Y2).^2);
    end
end

A(1:nCtrlPt, nCtrlPt+(1:2)) = ptDst(1:nCtrlPt, 1:2);
A(1:nCtrlPt, nCtrlPt+3) = 1;
A(nCtrlPt+(1:2), 1:nCtrlPt) = ptDst(1:nCtrlPt, 1:2).';
A(nCtrlPt+3, 1:nCtrlPt) = 1;
Bx(1:nCtrlPt, 1) = ptSrc(1:nCtrlPt, 1);
By(1:nCtrlPt, 1) = ptSrc(1:nCtrlPt, 2);

AlphaX = A\Bx;
AlphaY = A\By;

for ki = 1:size(imSrc, 1)
    tmp = zeros(1, nCtrlPt+3);
    tmp(nCtrlPt+3) = 1;    
    tmp(nCtrlPt+2) = ki-1;
    Xinv_kj = zeros(1,size(imSrc, 2));
    Yinv_kj = zeros(1,size(imSrc, 2));
    ptKi_C = (ptDst(:, 2)-ki-1).^2+C;
    for kj = 0:size(imSrc, 2)-1
        for n = 1:nCtrlPt
            tmp(n) = 1/sqrt((ptDst(n, 1)-kj)^2+ptKi_C(n));
        end
        tmp(nCtrlPt+1) = kj;
        Xinv_kj(kj+1) = tmp*AlphaX;
        Yinv_kj(kj+1) = tmp*AlphaY;
    end
    Xinv(ki, :) = Xinv_kj;
    Yinv(ki, :) = Yinv_kj;
end

imDst = zeros(size(imSrc));
[X0, Y0] = meshgrid(1:size(imSrc,2), 1:size(imSrc,1));

for j = 1:size(imSrc,3)
    tmp = interp2(X0, Y0, imSrc(:,:,j), Xinv, Yinv);
    tmp(isnan(tmp)) = 0;
    imDst(:,:,j) = tmp;
end

end

