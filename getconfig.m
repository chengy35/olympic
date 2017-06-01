function [video_data_dir,video_dir,fullvideoname, videoname,vocabDir,featDir_FV,featDir_LLC,descriptor_path,class_category,actionName] = getconfig()
    vocabDir = '~/remote/olympicData/Vocab'; % Path where dictionary/GMM will be saved.
    featDir_LLC = '~/remote/olympicData/llc/feats'; % Path where features will be saved
    featDir_FV = '~/remote/olympicData/fv/feats'; % Path where features will be saved
    descriptor_path = '~/remote/olympicData/descriptor/'; % change paths here 
    video_dir = '~/remote/oly_sports/';
    video_data_dir = '~/remote/olympicData/';
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