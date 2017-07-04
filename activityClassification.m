classdef activityClassification
	properties
        classifierModel = [];
        classificationRate = 1; %1Hz
        samplingRate = 0.02;
        plotMode = true;
        trainingNumSegemnt = 500;
        validationNumSegemnt = 500;
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
            %Need to write this more general to accept more than 3 
            %activation types
            
            [dataTraining,dataValidation] = splitDataTrainValid(data);
            
            %Training
            [dataTrainNotActive,dataTrainWalk,dataTrainRun] = ...
                splitDataActivity(dataValidation);
            [dataValidNotActive,dataValidWalk,dataVaidRun] = ...
                splitDataActivity(dataTraining);
            featureTrainingNotActive = [];
            for i = 1 : trainingNumSegment
                dataTrainNotActiveSegment = randomSelect(classTrainObj...
                    ,dataTrainNotActive);
                dataTrainWalkSegment = randomSelect(classTrainObj...
                    ,dataTrainWalk);
                dataTrainRunSegment = randomSelect(classTrainObj...
                    ,dataTrainRun);
                featureTemp = classificationFeature(dataTrainNotActiveSegment);
                featureTrainingNotActive = [featureTrainingNotActive;featureTemp];
                featureTemp = classificationFeature(dataTrainWalkSegment);
                featureTrainingWalk = [featureTrainingWalk;featureTemp];
                featureTemp = classificationFeature(dataTrainRunSegment);
                featureTrainingRun = [featureTrainingRun;featureTemp];
            end
            trainingSetFeature = [featureTrainingNotActive;featureTrainingWalk;featureTrainingRun];
            trainingSetLabel = [ones(size(featureTrainingNotActive,1),1)*1;...
            ones(size(featureTrainingWalk,1),1)* 2;...
            ones(size(featureTrainingRun,1),1) * 3];
            t = templateSVM('SaveSupportVectors','on');
            classTrainObj.classifierModel = fitcecoc(trainingSetFeature,trainingSetLabel,'Learners',t);
            
            %Validation
            featureValidationNotActive = [];
            for i = 1 : validationNumSegment
                dataValidNotActiveSegment = randomSelect(classTrainObj...
                    ,dataValidNotActive);
                dataValidWalkSegment = randomSelect(classTrainObj...
                    ,dataValidWalk);
                dataValidRunSegment = randomSelect(classTrainObj...
                    ,dataValidRun);
                featureTemp = classificationFeature(dataValidNotActiveSegment);
                featureValidationNotActive = [featureValidationNotActive;featureTemp];
                featureTemp = classificationFeature(dataValidWalkSegment);
                featureValidationWalk = [featureValidationWalk;featureTemp];
                featureTemp = classificationFeature(dataValidRunSegment);
                featureValidationRun = [featureValidationRun;featureTemp];
            end
            validationSetFeature = [featureValidationNotActive;featureValidationWalk;featureValidationRun];
            validationSetLabel = [ones(size(featureValidationNotActive,1),1)*1;...
            ones(size(featureValidationWalk,1),1)* 2;...
            ones(size(featureValidationRun,1),1) * 3];
            predictValidationSetLabel = predict(Mdl,validationSetFeature);
        end
    end
end

function [dataNotActive,dataWalk,dataRun] = splitDataActivity(data)
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
        
        