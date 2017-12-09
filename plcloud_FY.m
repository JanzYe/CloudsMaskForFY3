function [clr_pct]=plcloud(image,cldprob)
% Function for potential Cloud, cloud Shadow, and Snow Masking 3.2v
% Works for Sentinel 2
%
% History of revisions:
% Remove the split window method in cirrus cloud detection (Zhe 10/29/2013)
% Add dynamic water threshold (Zhe 10/27/2013)
% Remove majority filter (Zhe 10/27/2013)
% Fix bugs in probs < 0 (Brightness_prob & wTemp_prob) (Zhe 09/11/2013)
% Capable of processing Landsat 4~7 images (Zhe 09/09/2013)
% Use metadata to covert DN to TOA ref (Zhe 09/05/2013)
% Use the news bands from L8 for better cloud masking (Zhe 06/20/2013) 
% Capable of processing Landsat 8 (Zhe 04/04/2013)
% Remove Snow(mask==0)=255; (Zhe 05/24/2012)
% Made it a stand alone version (Zhe 01/09/2012)
% Impoved accuracy in TOA reflectance computing in two ways:
% Firstly, used the more accurate ESUN provied by Chander et al. RSE (2009)
% Secondly, used more Sun-Earth distance table provied by Chander et al.
% RSE (2009) (Zhe 01/07/2012)
% Fixed visible bands abnormal saturation problem (Zhe 04/24/2011)
% Cloud/shadow prob mask (-1) when no cloud prob computed (Zhe 01/01/2011)
% Flood fill for band 5 in shadow detection (Zhe 12/23/2010)
% Fixed saturation pixels (Zhe 12/16/2010)
% Include the BT test for snow (Zhe 12/06/2010)
% Include probability mask (Zhe 11/01/2010)
% Temp < 300k for all clouds (Zhe 12/01/2009)
% Reduced computing memory from double to single (Zhe 12/01/2009)
% Detecting clouds for Landsat 8 without using new bands (Zhe 09/04/2013)
% Add customized snow dilation pixel number (Zhe 09/12/2013)
% Fix problem in snow detection because of temperature (Zhe 09/12/2013)

% resolution of Fmask results
[~,data,dim,ul,zen,azi,zc,satu_B1,satu_B2,satu_B3,resolu]=nd2toarbt(image);

Thin_prob = 0; % there is no contribution from the new bands


% fprintf('Read in TOA ref ...\n');
Cloud=zeros(dim,'uint8');  % cloud mask
Snow=zeros(dim,'uint8'); % Snow mask
WT=zeros(dim,'uint8'); % Water msk
% process only the overlap area
mask=data(:,:,1)>-9999;
Shadow=zeros(dim,'uint8'); % shadow mask

NDVI=(data(:,:,4)-data(:,:,3))./(data(:,:,4)+data(:,:,3));
NDSI=(data(:,:,2)-data(:,:,5))./(data(:,:,2)+data(:,:,5));

NDVI((data(:,:,4)+data(:,:,3))==0)=0.01;
NDSI((data(:,:,2)+data(:,:,5))==0)=0.01;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%saturation in the three visible bands
satu_Bv=satu_B1+satu_B2+satu_B3>=1;
clear satu_B1; % clear satu_B;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Basic cloud test
% idplcd=NDSI<0&NDVI<0.8&data(:,:,6)>300;
idplcd=NDSI<0&NDVI<0.4 & NDVI > 0 &data(:,:,6)>1000;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Snow test
% It takes every snow pixels including snow pixel under thin clouds or icy clouds
Snow(NDSI>0.15&data(:,:,4)>1100&data(:,:,2)>1000)=1;
% Snow(mask==0)=255;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Water test
% Zhe's water test (works over thin cloud)
WT((NDVI<0.01&data(:,:,4)<1100)|(NDVI<0.1&NDVI>0&data(:,:,4)<500))=1;
% WT(NDVI<0.1&data(:,:,4)<1500) = 1;

cs_final = WT;
cs_final(Snow>0) = 3;
cs_final(idplcd>0) = 4;

norln=strread(image,'%s','delimiter','.'); 
n_name=char(norln(1));
save([n_name,'Fmask.mat'],'cs_final');
clr_pct = (1-double(length(find(cs_final>0)))/length(cs_final(:)))*100;

% figure,imshow(cs_final,[])
% set(gcf, 'position', [512 512 512 512]);
end

