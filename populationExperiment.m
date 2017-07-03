classdef populationExperiment
	properties
    	allDataLoaded = 0;
		data;
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
            	populationExperimentObj = readAllFiles(populationExperimentObj,directory);
        	end
    	end
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%new function%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
		function populationExperimentObj = readAllFiles(populationExperimentObj,directory)
			if (nargin < 1)
                listOfFiles = dir();
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
        end
	end	
end