classdef singleExperiment
	properties
        fileName = '';
        dataFormat = '%f,%f,%f,%f,%s';
        samplingTime = 0.02;
        numClass = 0;
    	dataLoaded = 0;
		dataMatrix = [];
        activityLabel = [];
        dataActivitySorted = [];
	end
	methods
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%new function%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
		function singleExperimentObj = singleExperiment(fileName,samplingTime)
            if (nargin == 1)
                samplingTime = 0.02;
            end
            if (nargin < 1)
            else
                singleExperimentObj.samplingTime = samplingTime;
            	singleExperimentObj = readData(singleExperimentObj,fileName);
                if checkData(singleExperimentObj)
                    singleExperimentObj = activitySort(singleExperimentObj);
                	singleExperimentObj.dataLoaded = 1;
                    singleExperimentObj.fileName = fileName;
                else
                	warning('data format is not correct')
                    singleExperimentObj.dataMatrix = [];
                	singleExperimentObj.dataLoaded = 0;
                end
            end
    	end
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%new function%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
		function singleExperimentObj = readData(singleExperimentObj,fileName)
			fileID = fopen(fileName);
            if (fileID == -1)
                warning('File not found');
            else
                dataFile = textscan(fileID,singleExperimentObj.dataFormat);
                activLab = dataFile{end};
                fIndex = cellfun(@isempty,activLab);
                activLab(fIndex) = {'NAW'};
                if (length(activLab) == length(dataFile{1}) - 1)
                    activLabNew = cell(length(activLab)+1,1);
                    activLabNew{1} = 'NAW';
                    activLabNew(2:end) = activLab;
                    activLab = activLabNew;
                end
                numberOfDataChannels = length(find(singleExperimentObj.dataFormat=='%'));
                nSamples = length(dataFile{1});
                singleExperimentObj.dataMatrix = zeros(nSamples,numberOfDataChannels-1);
                for i = 1 : numberOfDataChannels -1
                    singleExperimentObj.dataMatrix(:,i) = dataFile{i};
                end
                singleExperimentObj.activityLabel = activLab;
                singleExperimentObj.numClass = length(unique(activLab));
            end
        end
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%new function%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
        function singleExperimentObj = activitySort(singleExperimentObj)
            activLab = singleExperimentObj.activityLabel;
            availableClasses = unique(activLab);
            dataActivSorted = cell(singleExperimentObj.numClass,1);
            for i = 1 : singleExperimentObj.numClass
                if isempty(availableClasses{i})
                    fIndex = find(cellfun(@isempty,activLab));
                else
                    fIndex = contains(activLab,availableClasses{i});
                    fIndex = find(fIndex == 1);
                end
                switchingIndex = findDiscontinuity(fIndex);
                switchingIndex = [switchingIndex;size(singleExperimentObj.dataMatrix(fIndex,:),1)];
                dataActivSorted{i}.dataMatrix = singleExperimentObj.dataMatrix(fIndex,:);
                dataActivSorted{i}.class = availableClasses{i};
                dataActivSorted{i}.switchingIndex = switchingIndex;
            end
            singleExperimentObj.dataActivitySorted = dataActivSorted;
        end
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%new function%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
		function dataHealth = checkData(singleExperimentObj)
            %Other tests need to be added to verify the data format
            dataHealth = 0;
            if size(singleExperimentObj.dataMatrix,1) > 0
                dataHealth = 1;
            end
        end
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%new function%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
		function singleExperimentObj = setData(singleExperimentObj,data,activityLabel)
            if (size(data,2)>1)
                singleExperimentObj.dataMatrix = data;
                singleExperimentObj.activityLabel = activityLabel;
                dataHealth = checkData(singleExperimentObj);
                singleExperimentObj.dataLoaded = 1;
                singleExperimentObj.numClass = length(unique(activityLabel));
                singleExperimentObj = activitySort(singleExperimentObj);
                if ~dataHealth
                    singleExperimentObj.dataMatrix = [];
                    singleExperimentObj.dataLoaded = 0;
                end
            else
                warning('wrong data format')
            end
        end
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%new function%%%%%
%%%%%%%%%%%%%%%%%%%%%%%		
		function plot(singleExperimentObj)
            numDataChannels = size(singleExperimentObj.dataMatrix,2) - 1;
            for i = 1 : numDataChannels
                subplot(numDataChannels,1,i)
                plot(singleExperimentObj.dataMatrix(:,1),singleExperimentObj.dataMatrix(:,i+1)) 
            end
		end
	end	
end
function switchingIndex = findDiscontinuity(index)
    indexDiff = index(2:end)-index(1:end-1);
    switchingIndex = find(indexDiff~=1);
    switchingIndex = switchingIndex + 1;
    %switchingIndex = index;
end