classdef populationExperiment
	properties
        directory = '';
    	dataLoaded = 0;
        numberOfFilesFound = 0;
        numClassesFound = 0;
		data = [];
        dataActivitySorted = [];
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
            numClasses = 0;
            classesPopulation = {};
            for i = 1 : numberOfFiles
                thisExperiment = singleExperiment([directory,'/',fileNames{i}]);
                populationExperimentObj.data{i} = thisExperiment;
                classesThisExperiment = unique(thisExperiment.activityLabel);
                for j = 1 : length(classesThisExperiment)
                    if ~any(strcmp(classesPopulation,classesThisExperiment{j}))
                        classesPopulation{length(classesPopulation)+1,1} = classesThisExperiment{j};
                        numClasses = numClasses + 1;
                    end
                end
            end
            populationExperimentObj.numClassesFound = numClasses;
            populationExperimentObj.dataActivitySorted = cell(numClasses,1);
            for i = 1 : numClasses
                populationExperimentObj.dataActivitySorted{i}.dataMatrix = [];
                populationExperimentObj.dataActivitySorted{i}.class = '';
                populationExperimentObj.dataActivitySorted{i}.switchingIndex = [];
            end
            nSampClassesPrevExp = zeros (numClasses,1);
            for i = 1 : numberOfFiles
                thisExperiment = populationExperimentObj.data{i};
                for j = 1 : thisExperiment.numClass
                    thisExperimentClass = thisExperiment.dataActivitySorted{j}.class;
                    if isempty(thisExperimentClass)
                        fIndex = find(cellfun(@isempty,classesPopulation)==1);
                        populationExperimentObj.dataActivitySorted{fIndex,1}.dataMatrix...
                        = [populationExperimentObj.dataActivitySorted{fIndex,1}.dataMatrix;...
                        thisExperiment.dataActivitySorted{j}.dataMatrix];
                        populationExperimentObj.dataActivitySorted{fIndex}.class...
                        = '';
                        populationExperimentObj.dataActivitySorted{fIndex,1}.switchingIndex...
                        = [populationExperimentObj.dataActivitySorted{fIndex,1}.switchingIndex;...
                        nSampClassesPrevExp(fIndex,1) + ...
                        thisExperiment.dataActivitySorted{j}.switchingIndex];
                        nSampClassesPrevExp(fIndex,1) = ...
                            nSampClassesPrevExp(fIndex,1) + ...
                            size(thisExperiment.dataActivitySorted{fIndex}.dataMatrix,1);
                    else
                        fIndex = find(strcmp(classesPopulation,thisExperimentClass)==1);
                        populationExperimentObj.dataActivitySorted{fIndex,1}.dataMatrix...
                        = [populationExperimentObj.dataActivitySorted{fIndex,1}.dataMatrix;...
                        thisExperiment.dataActivitySorted{j}.dataMatrix];
                        populationExperimentObj.dataActivitySorted{fIndex,1}.class...
                        = thisExperiment.dataActivitySorted{j}.class;
                        populationExperimentObj.dataActivitySorted{fIndex,1}.switchingIndex...
                        = [populationExperimentObj.dataActivitySorted{fIndex,1}.switchingIndex;...
                        nSampClassesPrevExp(fIndex,1) + ...
                        thisExperiment.dataActivitySorted{j}.switchingIndex];
                        nSampClassesPrevExp(fIndex,1) = ...
                        nSampClassesPrevExp(fIndex,1) + ...
                        size(thisExperiment.dataActivitySorted{j}.dataMatrix,1);
                    end
                end
            end
        populationExperimentObj.dataLoaded = 1;
        end
	end	
end