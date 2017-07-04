classdef activityClassification
	properties
        classifierModel = [];
        classificationRate = 1; %1Hz
        samplingRate = 0.02;
	end
	methods
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%new function%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
		function classTrainObj = activityClassification(data)
			if (nargin<1)
            else
                classTrainObj = train(classTrainObj,data);
            end
        end
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%new function%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
        function classTrainObj = train(classTrainObj,data)
            [dataNotActive,dataWalk,dataRun] = splitData(data);
        end	
    end
end

function [dataNotActive,dataWalk,dataRun] = splitData(data)
    [data,dataOK] = prepareData(data);
    if dataOK
        dataNotActive = data.noActive;
        dataWalk = data.walk;
        dataRun = data.run;
    end
%     if (class(data) == populationExperiment)
% 
%     elseif (class(data) == singleExperiment)
%         classTrainObj.samplingRate = data.samplingTime;
%         %TBD need to split into not active, walk, run
%     elseif (isnumeric(data))
%         if (size(data,2) > size(data,1))
%             data = data';
%         end
%         if (size(data,2) == 3)
%             dataTemp = data;
%             data = singleExperiment;
%             data = setData(data,dataTemp);
%             %TBD need to split into not active, walk, run
%         else
%             warning('data not supported')
%         end
%     else
%         warning('input data not supported');
%     end
%     classificationSamples = classTrainObj.feedbackRate/samplingTime;

end
        
        