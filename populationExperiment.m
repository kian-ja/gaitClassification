classdef populationExperiment
	properties
        directory = '';
    	dataLoaded = 0;
        numberOfFilesFound = 0;
		data = [];
        %Concatenated Data
        time =[];
        accelerationX =[];
        accelerationY =[];
        accelerationZ =[];
        activityLabel =[];
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
            populationExperimentObj.time = [];
            populationExperimentObj.accelerationX = [];
            populationExperimentObj.accelerationY = [];
            populationExperimentObj.accelerationZ = [];
            populationExperimentObj.activityLabel = [];
            for i = 1 : numberOfFiles
                dataThisExperiment = singleExperiment([directory,'/',fileNames{i}]);
                populationExperimentObj.data{i} = dataThisExperiment;
                %populating concatenated data
                populationExperimentObj.time = [populationExperimentObj.time;...
                    dataThisExperiment.data.time];
                populationExperimentObj.accelerationX = [populationExperimentObj.accelerationX;...
                    dataThisExperiment.data.accelerationX];
                populationExperimentObj.accelerationY = [populationExperimentObj.accelerationY;...
                    dataThisExperiment.data.accelerationY];
                populationExperimentObj.accelerationZ = [populationExperimentObj.accelerationZ;...
                    dataThisExperiment.data.accelerationZ];
                populationExperimentObj.activityLabel = [populationExperimentObj.activityLabel;...
                    dataThisExperiment.data.activityLabel]; 
            end
            populationExperimentObj.dataLoaded = 1;
        end
	end	
end