function [video_data_dir,video_dir,fullvideoname, videoname,vocabDir,featDir_FV,featDir_LLC,descriptor_path,class_category,actionName] = getconfig()
    vocabDir = '/mnt/remote/olympicData/Vocab'; % Path where dictionary/GMM will be saved.
    featDir_LLC = '/mnt/remote/olympicData/llc/feats'; % Path where features will be saved
    featDir_FV = '/mnt/remote/olympicData/fv/feats'; % Path where features will be saved
    descriptor_path = '/mnt/remote/olympicData/descriptorall/'; % change paths here 
     if ~exist(fullfile(descriptor_path),'dir')
            mkdir(fullfile(descriptor_path));
    end
    video_dir = '/mnt/remote/oly_sports/';
    video_data_dir = '/mnt/remote/olympicData/';
    category = dir(video_dir);
    index = 1;
    for i = 3 : length(category)
        fnames = dir(fullfile(video_dir,category(i).name));
        for j = 3: length(fnames)
            fullvideoname{index,1}=fullfile(video_dir,category(i).name,fnames(j).name);
            videoname{index,1} = fnames(j).name;
            class_category{index,1}= i-2;
            index = index+1;
        end
    end
    fullvideoname = natsort(fullvideoname);
    videoname = natsort(videoname);
    actionName = {'basketball_layup', 'bowling', 'clean_and_jerk', 'discus_throw', 'diving_platfrom_10m', 'diving_springboard_3m', 'hammer_throw', 'high_jump', 'javelin_throw', 'long_jump', 'pole_vault', 'shot_put', 'snatch', 'tennis_serve', 'triple_jump', 'vault'};
end
