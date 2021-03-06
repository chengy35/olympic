function trainAndTest_normalizedL2_LLC(video_data_dir,fullvideoname,featDir_LLC,encode,actionName)
	nClasses = 16;
	resultFile = ['./' encode '_result'];
	FileName = ['./2-trainAndtest/classlabel'];
	classlabel = load(FileName);
	FileName = ['./2-trainAndtest/trainIndex'];
	trn_indx = load(FileName);
	FileName = ['./2-trainAndtest/testIndex'];
	test_indx = load(FileName);
	TrainClass = classlabel(trn_indx,:);
	TestClass = classlabel(test_indx,:);
	j = 1;

	[~,partfile,~] = fileparts(fullvideoname{1});
	featFile{j} = fullfile(featDir_LLC,'all',sprintf('%s.mat',partfile));  
	fvtemp =  dlmread(featFile{j});
	fvtemp = fvtemp'; %'
	Dimension = size(fvtemp,2);

	if ~exist('TestData_Kern_cell.mat','file')
 		    if ~exist('TrainData.mat','file')
			TrainData = zeros(size(trn_indx,1),Dimension);
			for j = 1:size(trn_indx,1)
				[~,partfile,~] = fileparts(fullvideoname{trn_indx(j)});
				featFile{j} = fullfile(featDir_LLC,'all',sprintf('%s.mat',partfile));  
				fprintf('read LLC in training: %d \n',j);
				temp =  dlmread(featFile{j});
				TrainData(j,:)  = normalizeL2(sqrt(temp'));
				clear temp;
				
			end
				save('./TrainData','TrainData','-v7.3');
				clear TrainData;
			end
			load('TrainData');
			TrainData_Kern_cell = [TrainData * TrainData'];
			save('./TrainData_Kern_cell','TrainData_Kern_cell','-v7.3');
			clear TrainData_Kern_cell;
			if ~exist('TestData.mat','file')
		    	TestData = zeros(size(test_indx,1),Dimension);
			for j = 1:size(test_indx,1)
				[~,partfile,~] = fileparts(fullvideoname{test_indx(j)});
				featFile{j} = fullfile(featDir_LLC,'all',sprintf('%s.mat',partfile));  
				fprintf('read LLC in testing : %d \n',j);
				temp = dlmread(featFile{j});
				TestData(j,:)  = normalizeL2(sqrt(temp'));
				clear temp;
				
			end
				save('./TestData','TestData','-v7.3');
				clear TestData;
			end
			load('TestData');
			TestData_Kern_cell = [TestData * TrainData'];
			clear TrainData;
			clear TestData;
			save('./TestData_Kern_cell','TestData_Kern_cell','-v7.3');
			clear TestData_Kern_cell;
	end
	load ('TrainData_Kern_cell.mat');
	load ('TestData_Kern_cell.mat');
    for cl = 1 : size(classlabel,2)            
        trnLBLB = TrainClass(:,cl);
        testLBL = TestClass(:,cl);         
        ap_class(cl) = train_and_classify(TrainData_Kern_cell,TestData_Kern_cell,trnLBLB,testLBL);       
    end
    for cl = 1 : size(classlabel,2)
            fprintf('%s = %1.2f \n',actionName{cl},ap_class(cl));
    end
    fprintf('mean = %1.2f \n',mean(ap_class));
    save(resultFile,'ap_class','-v7.3');
end

function [ap ] = train_and_classify(TrainData_Kern_cell,TestData_Kern_cell,trnLBLB,testLBL)
	nTrain = 1 : size(TrainData_Kern_cell,1);
	TrainData_Kern_cell = [nTrain' TrainData_Kern_cell];         
	nTest = 1 : size(TestData_Kern_cell,1);
	TestData_Kern_cell = [nTest' TestData_Kern_cell];

	C = [0.1 1 10 100 500 1000 ];
	for ci = 1 : numel(C)
		model(ci) = svmtrain(trnLBLB, TrainData_Kern_cell, sprintf('-t 4 -c %1.6f -v 2 -q ',C(ci)));               
		end
	[~,max_indx]=max(model);
	model = svmtrain(trnLBLB, TrainData_Kern_cell, sprintf('-t 4 -c %1.6f -q ',C(max_indx)));
	
	[~, acc, scores] = svmpredict(testLBL, TestData_Kern_cell ,model);	                 
	[rc, pr, info] = vl_pr(testLBL, scores(:,1)) ; 
	ap = info.ap;
end

function X = normalizeL2(X)
	for i = 1 : size(X,1)
		if norm(X(i,:)) ~= 0
			X(i,:) = X(i,:) ./ norm(X(i,:));
		end
    end	   
end