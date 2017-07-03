classdef populationExperiment
	properties
        directory = '';
    	dataLoaded = 0;
        numberOfFilesFound = 0;
		data = [];
        %Concatenated Data
        dataConcatenated = [];
        notScoredConcatenated = [];
        noActiveConcatenated = [];
        walkConcatenated = [];
        runConcatenated = [];
	end
	methods
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%new function%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
		function populationExperimentObj = populationExperiment(directory)
			if (nargin < 1)
            	disp('current directory will be considered')
                populationExperimentObj = readAllFiles(populationExperimentObj);
            else
                populationExperimentObj.directory = directory;
            	populationExperimentObj = readAllFiles(populationExperimentObj,directory);
        	end
    	end
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%new function%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
		function populationExperimentObj = readAllFiles(populationExperimentObj,directory)
			if (nargin < 2)
                listOfFiles = dir();
                directory = '';
            else
                listOfFiles = dir(directory);
            end
            numberOfFiles = length(listOfFiles);
            fileNames = cell(numberOfFiles,1);
            for i = 1 : numberOfFiles
                if (startsWith(listOfFiles(i).name,'.'))
                    numberOfFiles = numberOfFiles - 1;
                elseif (listOfFiles(i).isdir)
                    numberOfFiles = numberOfFiles - 1;
                elseif ~strcmp(listOfFiles(i).name(end-3:end),'.csv')
                    numberOfFiles = numberOfFiles - 1;
                else
                    fileNames{i} = listOfFiles(i).name;
                end
            end
            fileNames(cellfun(@isempty,fileNames)) = [];
            numberOfFiles = length(fileNames);
            populationExperimentObj.numberOfFilesFound = numberOfFiles;
            populationExperimentObj.data = cell(numberOfFiles,1);
            time = [];
            accelerationX = [];
            accelerationY = [];
            accelerationZ = [];
            activityLabel = [];
            for i = 1 : numberOfFiles
                dataThisExperiment = singleExperiment([directory,'/',fileNames{i}]);
                populationExperimentObj.data{i} = dataThisExperiment;
                %populating concatenated data
                time = [time;dataThisExperiment.data.time];
                accelerationX = [accelerationX;dataThisExperiment.data.accelerationX];
                accelerationY = [accelerationY;dataThisExperiment.data.accelerationY];
                accelerationZ = [accelerationZ;dataThisExperiment.data.accelerationZ];
                activityLabel = [activityLabel;dataThisExperiment.data.activityLabel];
            end
            dataCat = [time accelerationX accelerationY ...
                accelerationZ activityLabel];
            populationExperimentObj.dataConcatenated = singleExperiment;
            populationExperimentObj.dataConcatenated = setData(...
                populationExperimentObj.dataConcatenated,dataCat);
            populationExperimentObj.dataLoaded = 1;
            NOT_SCORED_CLASS = populationExperimentObj.dataConcatenated.NOT_SCORED_CLASS;
            NO_ACTIVITY_CLASS = populationExperimentObj.dataConcatenated.NO_ACTIVITY_CLASS;
            WALK_CLASS = populationExperimentObj.dataConcatenated.WALK_CLASS;
            RUN_CLASS = populationExperimentObj.dataConcatenated.RUN_CLASS;
            
            indexNotScored = dataCat(:,5) == NOT_SCORED_CLASS;
            indexNoActivity = dataCat(:,5) == NO_ACTIVITY_CLASS;
            indexWalk = dataCat(:,5) == WALK_CLASS;
            indexRun = dataCat(:,5) == RUN_CLASS;
            dataCatNotScored = dataCat(indexNotScored,:);
            dataCatNoActivity = dataCat(indexNoActivity,:);
            dataCatWalk = dataCat(indexWalk,:);
            dataCatRun = dataCat(indexRun,:);
            populationExperimentObj.notScoredConcatenated = singleExperiment;
            populationExperimentObj.notScoredConcatenated = setData(...
                populationExperimentObj.notScoredConcatenated,dataCatNotScored);
            populationExperimentObj.noActiveConcatenated = singleExperiment;
            populationExperimentObj.noActiveConcatenated = setData(...
                populationExperimentObj.noActiveConcatenated,dataCatNoActivity);
            populationExperimentObj.walkConcatenated = singleExperiment;
            populationExperimentObj.walkConcatenated = setData(...
                populationExperimentObj.walkConcatenated,dataCatWalk);
            populationExperimentObj.runConcatenated = singleExperiment;
            populationExperimentObj.runConcatenated = setData(...
                populationExperimentObj.runConcatenated,dataCatRun);
        end
	end	
end