clear;
clc;
% TODO Add paths
addpath('~/lib/vlfeat/toolbox');
vl_setup();
setenv('LD_LIBRARY_PATH','/usr/local/lib/'); 
addpath('~/lib/liblinear/matlab');
addpath('~/lib/libsvm/matlab');
addpath('~/lib/natsort');
addpath('~/lib/exact_alm_rpca/');

[video_data_dir,video_dir,fullvideoname, videoname,vocabDir,featDir_FV,featDir_LLC,descriptor_path,class_category,actionName] = getconfig();
	encode = 'fv';
	fprintf('begin fv encoding\n');
	st = 1;
	send = length(videoname);
	fprintf('Start : %d \n',st);
	fprintf('End : %d \n',send);
	addpath('0-trajectory');
	fprintf('select salient trajectory\n');
	getIDT(st,send,fullvideoname,descriptor_path);
	addpath('1-fv');
	fprintf('getGMM \n');
	% create GMM model, Look at this function see if parameters are okay for you.
	totalnumber = 2560000; %1000000
	gmmSize = 256;
	[gmm] = getGMMAndBOW(fullvideoname,vocabDir,descriptor_path,video_dir,totalnumber,gmmSize);
	fprintf('generate Fisher Vectors \n');
	FVEncodeFeatures_w(fullvideoname,gmm,vocabDir,st,send,featDir_FV,descriptor_path,'all');
	allFeatureDimension = 396;
	getVideoDarwin(fullvideoname,featDir_FV,descriptor_path,gmmSize,allFeatureDimension);

	encode = 'llc';
	fprintf('begin llc encoding\n');
	addpath('1-cluster');
	
	kmeans_size = 8000;
	fprintf('clustering \n');
	centers = SelectSalient(kmeans_size,totalnumber,fullvideoname,descriptor_path,vocabDir);
	fprintf('llc Encoding now \n');
	llcEncodeFeatures(centers,fullvideoname,descriptor_path,featDir_LLC,class_category,vocabDir);
	clear centers;

addpath('2-trainAndtest');
%trainAndTest_normalizedL2_LLC(video_data_dir,fullvideoname,featDir_LLC,encode,actionName);
%trainAndTest_normalizedL2_FV(video_data_dir,fullvideoname,featDir_FV,featDir_LLC,encode,actionName);
%trainAndTest_normalizedL2_FV_LLC(video_data_dir,fullvideoname,featDir_FV,featDir_LLC,encode,actionName);