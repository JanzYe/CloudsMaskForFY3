function clr_pct = Fmask(im,cldpix,sdpix,snpix,cldprob)
% 3.0 stand alone version
% Output image data description:
% This algorithm provide mask for cloud, cloud Shadow, Snow, Land, and Water.
% bsq ENVI readable '*Fmask' image
tic
% [zen,azi,ptm,Water,Snow,Cloud,Shadow,dim,ul,resolu,zc]=plcloud(im,cldprob);
% clr_pct = fcssm(im,zen,azi,ptm,Water,Snow,Cloud,Shadow,dim,ul,resolu,zc,cldpix,sdpix,snpix);
clr_pct = plcloud_FY(im,cldprob);
fprintf('Fmask finished for %s with %.2f%% clear pixels\n',im,clr_pct);
toc
end