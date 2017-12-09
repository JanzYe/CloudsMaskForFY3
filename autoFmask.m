function clr_pct = autoFmask(cldpix,sdpix,snpix,cldprob)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Welcome to use the 3.3.0 version of Fmask!
% It is capable of detecting cloud, cloud shadow, snow for Landsat 4, 5, 7, and 8
% If you have any question please do not hesitate
% to contact Zhe Zhu and Prof. Curtis Woodcock at Center for Remote Sensing,
% Boston University
% email: zhuzhe@bu.edu
%
% This function will calculate the mask for each scence automatically
% Output is the final fmask
% clear land = 0
% clear water = 1
% cloud shadow = 2
% snow = 3
% cloud = 4
% outside = 255
%
% How to install it?
% 1. Copy the "Fmask" folder to your local disk
% 2. Start matlab and addpath for this folder - addpath('local_disk');
%
%
% How to use it?
% 1. Get to the directory where you save the Landsat scene
% 2. Type in - 'autoFmask' or 'autoFmask(cldpix,sdpix,snpix,cldprb) in Matlab command window
% 'cldpix', 'sdpix', 'snpix' are dilated number of pixels for cloud/shadow/snow with
% default values of 3. 'cldprob' is the cloud probability threshold with default
% values of 22.5 for Landsat 4~7 and 50 for Landsat 8 (range from 0~100).
% 3. You can get clear pixel percent by using 'clr_pct = autoFmask';
% 
% Requirements:
% 1. Use the original Landat TIF images as inputs and each folder only put one image. 
% 2. It needs approximately 4G memory to run this algorithm.
% 3. It takes 0.5 to 5 miniutes for processing one Landsat image with one CPU.
%
%% History of revisions:
%
% New features of 2.1.0 version compared to 1.6.3 version:
% Exclude small cloud object <= 9 pixels (Zhe 03/07/2012)
% Dilate snow by default 3 pixels in 8 connect directions (Zhe 05/24/2012)
% Change the Fmask band name to "*Fmask" (Zhe 09/27/2012)
% Process TM and ETM+ images with the new "MTL.txt" metadata (Zhu 09/28/2012)
% Process both the new and old "MTL.txt" metadata (Zhu 10/18/2012)
% Fixed a bug in writing zone number for ENVI header (Zhu 02/26/2013)
%
% New features of 2.2.0 version:
% Change Tbuffer to 0.95 to fix ealier stops in cloud shadow match (Zhu 03/01/2013)
%
% New features of 3.3.0 version:
% Detecting clouds for Landsat 8 without using new bands (Zhe 09/04/2013)
% Remove high probability clouds to reduce commission error (Zhe 09/11/2013)
% Fix bug for wtemp_prob < 0 (Zhe 09/11/2013)
% Add customized snow dilation pixel number (Zhe 09/12/2013)
% Fix problem in snow detection because of temperature screen (Zhe 09/12/2013)
% Output clear pixel percent for the whole Landsat image (Zhe 09/13/2013)
% Remove default 3 pixels snow dilation (Zhe 09/20/2013)
% Fix bug in calculating r_obj and change num_pix value (Zhe 09/27/2013)
% Calculate cloud DEM with recorded height (Zhe 08/19/2015)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Fmask 3.3.0 beta version start ...\n');

% path_Pre = 'F:\BaiduNetdiskDownload\FY-3MERSI\FY3ABC_Proj\FY3A+FIX\';  %风云3B图像路径前缀
% path_Pre = 'F:\BaiduNetdiskDownload\FY-3MERSI\FY3ABC_Proj\FY3B+FIX\';  %风云3B图像路径前缀
path_Pre = 'F:\BaiduNetdiskDownload\FY-3MERSI\FY3ABC_Proj\FY3C+FIX\';  %风云3B图像路径前缀

% load('allFilePathSuf_A.mat');
% load('allFilePathSuf_B.mat');
load('allFilePathSuf_C.mat');

validFilePathSuf = [];
validFileNum = 0;

%89
for i = 47:length(allFilePathSuf)
    if allFilePathSuf(i,1) == 0, continue; end;
    
    path = [path_Pre,char(allFilePathSuf(i,:))];
    
    n_B = h5read(path, '/20bands_L1B_DN_values');
    
%     if(min(min(min(n_B(:,:,[1:4,6:7])))) == -999), continue; end;

    validFileNum = validFileNum + 1;
    validFilePathSuf(validFileNum,:) = allFilePathSuf(i,:);
    
    if exist('cldpix','var')==1&&exist('sdpix','var')==1&&exist('snpix','var')==1
        % cldpix = str2double(cldpix); % to make stand alone work for inputs
        % sdpix = str2double(sdpix);
        % snpix = str2double(snpix);
        fprintf('Cloud/cloud shadow/snow dilated by %d/%d/%d pixels\n',cldpix,sdpix,snpix);

    else
        % default buffering pixels for cloud, cloud shadow, and snow
        cldpix = 10;
        sdpix = 10;
        snpix = 0;
        fprintf('Cloud/cloud shadow/snow dilated by %d/%d/%d pixels (default)\n',cldpix,sdpix,snpix);
    end

    if exist('cldprob','var')==1
        % cldprob = str2double(cldprob); % to make stand alone work for inputs
        fprintf('Cloud probability threshold of %.2f%%\n',cldprob);
    else
        % default cloud probability threshold for cloud detection
%         cldprob = 22.5;
        cldprob = 22.5;
        fprintf('Cloud probability threshold of %.2f%% (default)\n',cldprob);
    end

    clr_pct = Fmask(path,cldpix,sdpix,snpix,cldprob); % newest version 3.2
    i
    break;   %为了测试时只处理一个文件
end
validFileNum
end