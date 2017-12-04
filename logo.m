% Perform Locally cOnstrainted Global Optimization
%
% Jiansheng Chen, Guangda Su, Jinping He, Shenglan Ben, "Face Image 
% Relighting using Locally Constrained Global Optimization", ECCV'10
%
%01-10-10, Jiansheng Chen

function Ic_gray = logo(Iv, C, W, sigma2_matrix)

[ht, wd] = size(Iv); 
% epsilon = 0.1; % the value used in all expriments in the paper

lamda = 0.3; usesparse = true;

    %contructing B
    disp('Constructing B ...')
    tic
    
    npix = (ht-2*W+2)*(wd-2*W+2); %number of valid pixels
    
    B=zeros(npix, 1);
    idx = 1;
    for kx = W:(ht-W+1)
        for ky = W:(wd-W+1)

            %the possible windows contains (kx, ky)
            %the upleft corner from (kx-W+1, ky-W+1) to (kx, ky)
            for ix=kx-W+1:kx
                for iy=ky-W+1:ky
                    B(idx) = B(idx) + Iv(kx, ky)*C(ix, iy)/(sigma2_matrix(ix, iy)+lamda);
                end
            end
            B(idx) = B(idx)*lamda;
            idx = idx + 1;
        end
    end
    toc

    %contructing S stored as sparse matrix
    disp('Constructing S ...');
    tic;

if usesparse    
    S = spalloc(npix, npix, (2*W-1)^2*npix);
else
    S = zeros(npix);
end

h = waitbar(0, 'Please wait ...');
tmp = ht-W+1;
wdeffective = wd-2*W+2;
    for kx = W:(ht-W+1)
        waitbar(kx/tmp);
        for ky = W:(wd-W+1)
            k = (kx-W)*wdeffective+ky-W+1;
            for jx = max(kx-W+1, W): min(kx+W-1, ht-W+1)
                for jy =  max(ky-W+1, W):min(ky+W-1, wd-W+1)
                   j = (jx-W)*wdeffective+jy-W+1;
                   
                        %all the possible windows that contains both k and j
                        %the upleftcorner in range (
                        %max(kx,jx)-W+1:min(kx,jx)+W-1,
                        %max(ky,jy)-W+1:min(ky,jy)+W-1)
                   
                   %use symmetry to save time
%                    fprintf(1, 'k=%d, j=%d\n', k, j);
                   if k==j
                        for ix = max(kx,jx)-W+1:min(kx,jx)
                            for iy = max(ky,jy)-W+1:min(ky,jy)
                                S(k,j) = S(k,j) + (1 - Iv(kx, ky)*Iv(jx, jy)/(sigma2_matrix(ix, iy)+lamda));
                            end
                        end
                   elseif k<j
                        for ix = max(kx,jx)-W+1:min(kx,jx)
                            for iy = max(ky,jy)-W+1:min(ky,jy)
                                S(k,j) = S(k,j) - Iv(kx, ky)*Iv(jx, jy)/(sigma2_matrix(ix, iy)+lamda);
                            end
                        end
                        S(j,k) = S(k,j);
                   end
                end
            end
        end
    end
    
close(h);
%checkpoint, S should be symmetric and very sparse.
toc;

Ic_gray = zeros(size(Iv));  
tmp = reshape(S\B, size(Iv,2)-2*(W-1), size(Iv,1)-2*(W-1))';
Ic_gray(2*floor(W/2)+1:size(Ic_gray, 1)-2*floor(W/2), 2*floor(W/2)+1:size(Ic_gray, 2)-2*floor(W/2))=mat2gray(tmp);
m0 = mean(Ic_gray(Ic_gray>0)); std0 = std((Ic_gray(Ic_gray>0)));
Ic_gray = (Ic_gray-std0)*0.35/std0+0.35;

end