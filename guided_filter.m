function q = guided_filter(I,P,w)
if(nargin<3)
    w=7;
end

mu_i = imfilter(I,fspecial('average',w),'symmetric');
mu_ii = imfilter(I.^2,fspecial('average',w),'symmetric');

sig_i = mu_ii - mu_i.^2;

mu_ip = imfilter(I.*P,fspecial('average',w),'symmetric');
mu_p = imfilter(P,fspecial('average',w),'symmetric');
mu_i_mu_p = mu_i.*mu_p;

ak = (mu_ip - mu_i_mu_p)./(sig_i);
bk = mu_p - ak.*mu_i;

q = ak.*I  + bk;