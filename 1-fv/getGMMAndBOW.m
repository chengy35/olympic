function [gmm] = getGMMAndBOW(fullvideoname,vocabDir,descriptor_path,video_dir,totalnumber,gmmsize)
    pcaFactor = 0.5;

    if ~exist(fullfile(vocabDir,'/all'),'dir')
        mkdir(fullfile(vocabDir,'/all'));
    end
    vocabDir = [vocabDir,'/all/'];
    
    sampleFeatFile = fullfile(vocabDir,'featfile.mat');
    modelFilePath = fullfile(vocabDir,'gmmvocmodel.mat');
    if exist(modelFilePath,'file')
        load(modelFilePath);
        return;
    end
    start_index = 1;
    end_index = 1;
    if ~exist(sampleFeatFile,'file') 
        allAll = zeros(totalnumber,96*2);
        num_videos = size(fullvideoname,1);
        num_samples_per_vid = round(totalnumber / num_videos);
        warning('getGMMAndBOW : update num_videos only to include training videos')
        for i = 1:num_videos       
            timest = tic();        
            [~,partfile,~] = fileparts(fullvideoname{i});
            descriptorFile = fullfile(descriptor_path,sprintf('%s.mat',partfile));      
                if exist(descriptorFile,'file')
                    load(descriptorFile);
                else
                    fprintf('%s not exist !!!',descriptorFile);
                    [obj,trj,hog,hof,mbhx,mbhy] = extract_improvedfeatures(fullvideoname{i}) ;
                    save(descriptorFile,'obj','trj','hog','hof','mbhx','mbhy'); 
                end
                hog = sqrt(hog); hof = sqrt(hof);
                mbhx = sqrt(mbhx);mbhy = sqrt(mbhy);
                all = [hog, hof, mbhx, mbhy];
                rnsam = randperm(size(mbhx,1));
                if numel(rnsam) > num_samples_per_vid
                    rnsam = rnsam(1:num_samples_per_vid);
                end
                end_index = start_index + numel(rnsam) - 1;
                allAll(start_index:end_index,:) = [all(rnsam,:)];
                start_index = start_index + numel(rnsam);        
                timest = toc(timest);
                fprintf('%d/%d -> %s --> %1.2f sec\n',i,num_videos,fullvideoname{(i)},timest);  
        end

        if end_index ~= totalnumber
            allAll(end_index+1:totalnumber,:) = [];
        end
            fprintf('start computing pca\n');
            gmm.pcamap.all = princomp(allAll);
            fprintf('start saving descriptors\n');
            save(sampleFeatFile,'allAll','gmm','-v7.3');
    else
        load(sampleFeatFile);
    end

    fprintf('start create gmm \n');
    allProjected = allAll * gmm.pcamap.all(:,1:size(gmm.pcamap.all,1)*pcaFactor);
    [gmm.means.all, gmm.covariances.all, gmm.priors.all] = vl_gmm(allProjected', gmmsize);
    fprintf('start saving gmm\n');
    save(modelFilePath,'gmm');     
end