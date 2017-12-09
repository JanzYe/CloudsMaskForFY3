function [Lmax,Lmin,Qcalmax,Qcalmin,Refmax,Refmin,ijdim_ref,ijdim_thm,reso_ref,...
    reso_thm,ul,zen,azi,zc,doy]=lndhdrread(path)
% Revisions:
% Read in the metadata for Landsat 8 (Zhe 04/04/2013)
% Read in the old or new metadata for Landsat TM/ETM+ images (Zhe 10/18/2012)
% [Lmax,Lmin,Qcalmax,Qcalmin,Refmax,Refmin,ijdim_ref,ijdim_thm,reso_ref,...
%    reso_thm,ul,zen,azi,zc,Lnum,doy]=lndhdrread(filename)
% Where:
% Inputs:
% filename='L*MTL.txt';
% Outputs:
% 1) Lmax = Max radiances;
% 2) Lmin = Min radiances;
% 3) Qcalmax = Max calibrated DNs;
% 4) Qcalmin = Min calibrated DNs;
% 5) ijdim_ref = [nrows,ncols]; % dimension of optical bands
% 6) ijdim_ref = [nrows,ncols]; % dimension of thermal band
% 7) reo_ref = 28/30; % resolution of optical bands
% 8) reo_thm = 60/120; % resolution of thermal band
% 9) ul = [upperleft_mapx upperleft_mapy];
% 10) zen = solar zenith angle (degrees);
% 11) azi = solar azimuth angle (degrees);
% 12) zc = Zone Number
% 13) Lnum = 4,5,or 7; Landsat sensor number
% 14) doy = day of year (1,2,3,...,356);
%
%%
% open and read hdr file
n_B = h5read(path, '/20bands_L1B_DN_values');
Longitude = h5read(path, '/Longitude');
Latitude = h5read(path, '/Latitude');
SolarZenith = h5read(path, '/SolarZenith');
SolarAzimuth = h5read(path, '/SolarAzimuth');

% initialize Refmax & Refmin
Refmax = -1;
Refmin = -1;
% 

%  n_B(n_B(:,:,1:7)<0)=power(2,12);

im_B1 = double(n_B(n_B(:,:,1) ~= -999));
im_B2 = double(n_B(n_B(:,:,2) ~= -999));
im_B3 = double(n_B(n_B(:,:,3) ~= -999));
im_B4 = double(n_B(n_B(:,:,4) ~= -999));
im_B5 = double(n_B(n_B(:,:,6) ~= -999));
im_th = 255;
im_B7 = double(n_B(n_B(:,:,7) ~= -999));

if isempty(im_B1)||isempty(im_B2)||isempty(im_B3)||isempty(im_B4)||isempty(im_B5)||isempty(im_B7)
    im_B1=255;im_B2=255;im_B3=255;im_B4=255;im_B5=255;im_B7=255;
end
 
%�Աȶ�����
% im_B1 = intrans(double(n_B(:,:,1)),'stretch').*255;
% im_B2 = intrans(double(n_B(:,:,2)),'stretch').*255;
% im_B3 = intrans(double(n_B(:,:,3)),'stretch').*255;
% im_B4 = intrans(double(n_B(:,:,4)),'stretch').*255;
% im_B5 = intrans(double(n_B(:,:,6)),'stretch').*255;
% im_th = intrans(double(n_B(:,:,5)),'stretch').*255;
% im_B7 = intrans(double(n_B(:,:,7)),'stretch').*255;


% %�Աȶ�����
% im_B1 = intrans(n_B(:,:,1),'gamma',1).*255;
% im_B2 = intrans(n_B(:,:,2),'gamma',1).*255;
% im_B3 = intrans(n_B(:,:,3),'gamma',1).*255;
% im_B4 = intrans(n_B(:,:,4),'gamma',1).*255;
% im_B5 = intrans(n_B(:,:,6),'gamma',1).*255;
% im_th = intrans(n_B(:,:,5),'gamma',1).*255;
% im_B7 = intrans(n_B(:,:,7),'gamma',1).*255;



% read in LMAX   ÿ�����η���ֵ�����ֵ  ����У����  ��DNֵ
Lmax_B1 = max(max(im_B1));
Lmax_B2 = max(max(im_B2));
Lmax_B3 = max(max(im_B3));
Lmax_B4 = max(max(im_B4));
Lmax_B5 = max(max(im_B5));%��landsat�Ƚϣ�5,6����Ҫ����
Lmax_B6 = max(max(im_th));
Lmax_B7 = max(max(im_B7));
Lmax=[Lmax_B1,Lmax_B2,Lmax_B3,Lmax_B4,Lmax_B5,Lmax_B6,Lmax_B7];

% Read in LMIN  ÿ�����η���ֵ����Сֵ
Lmin_B1 = min(min(im_B1));
Lmin_B2 = min(min(im_B2));
Lmin_B3 = min(min(im_B3));
Lmin_B4 = min(min(im_B4));
Lmin_B5 = min(min(im_B5));
Lmin_B6 = min(min(im_th));
Lmin_B7 = min(min(im_B7));
Lmin=[Lmin_B1,Lmin_B2,Lmin_B3,Lmin_B4,Lmin_B5,Lmin_B6,Lmin_B7];

% Read in QCALMAX  ����ֵ�����ֵ
% Qcalmax = power(2,12)-1;
Qcalmax = power(2,8)-1;
Qcalmax_B1 = Qcalmax;
Qcalmax_B2 = Qcalmax;
Qcalmax_B3 = Qcalmax;
Qcalmax_B4 = Qcalmax;
Qcalmax_B5 = Qcalmax;
Qcalmax_B6 = Qcalmax;
Qcalmax_B7 = Qcalmax;
Qcalmax=[Qcalmax_B1,Qcalmax_B2,Qcalmax_B3,Qcalmax_B4,Qcalmax_B5,Qcalmax_B6,Qcalmax_B7];

% Read in QCALMIN  ����ֵ����Сֵ ȫ��1
Qcalmin = 1;
Qcalmin_B1 = Qcalmin;
Qcalmin_B2 = Qcalmin;
Qcalmin_B3 = Qcalmin;
Qcalmin_B4 = Qcalmin;
Qcalmin_B5 = Qcalmin;
Qcalmin_B6 = Qcalmin;
Qcalmin_B7 = Qcalmin;
Qcalmin=[Qcalmin_B1,Qcalmin_B2,Qcalmin_B3,Qcalmin_B4,Qcalmin_B5,Qcalmin_B6,Qcalmin_B7];

% Read in nrows & ncols of optical bands  ͼ�������������
% record ijdimension of optical bands
ijdim_ref=double(size(n_B(:,:,1)));

%�Ȳ�������������
% record thermal band dimensions (i,j)
ijdim_thm=double(size(n_B(:,:,5)));

% Read in resolution of optical and thermal bands  �Ⲩ�κ��Ȳ��εĿռ�ֱ���
reso_ref = double(250);
reso_thm = double(250);

% Read in UTM Zone Number  UTMͶӰ�ִ�
zc=utmzone(Latitude(1,1),Longitude(1,1));
% Read in Solar Azimuth & Elevation angle (degrees)   ̫����λ��  ����
azi= double(SolarAzimuth(1,1)/100);
zen= double(SolarZenith(1,1)/100);
% Read in upperleft mapx,y   ���Ͻ�mapֵ  �þ�γ��תUTM
axesm utm   %����ͶӰ��ʽ
[ulx,uly]=mfwdtran(Latitude(1,1),Longitude(1,1));
ul = [ulx,uly];
% Read in date of year  ��������Ϊ��һ��ĵڼ���
date = path(length(path)-45:length(path)-38);
doy=double(datenum(date,'yyyymmdd')-datenum([date(1:4),'0101'],'yyyymmdd')+1);
    

end

