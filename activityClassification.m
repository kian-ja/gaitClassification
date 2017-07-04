classdef activityClassification
	properties
        classifierModel = [];
        classificationRate = 1; %1Hz
        samplingRate = 0.02;
        plotMode = true;
        trainingNumSegemnt = 500;
        validationNumSegemnt = 500;
        trainingRatio = 0.8;
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
            if (class(data) == 'populationExperiment')
                data = data.dataConcatenated;
            end
            [dataTraining,dataValidation] = splitDataTrainValid...
                (data,classTrainObj.trainingRatio);
            
            %Training
            dataTrainSplitActivity = ...
                splitDataActivity(dataTraining);
            dataValidSplitActivity = ...
                splitDataActivity(dataValidation);
            trainingSetFeature = [];
            trainingSetLabel = [];
            for i = 1 : classTrainObj.trainingNumSegemnt
                for j = 1 : length(dataTrainSplitActivity)
                    dataTrainSegmentThisActivity = randomSelect(classTrainObj...
                    ,dataTrainSplitActivity{j});
                    featureTemp = classificationFeature(dataTrainSegmentThisActivity);
                    trainingSetFeature = [trainingSetFeature;featureTemp];
                    labelTemp = dataTrainSplitActivity{j}.data.activityLabel(1);
                    trainingSetLabel = [trainingSetLabel;labelTemp];
                end
            end
            t = templateSVM('SaveSupportVectors','on');
            classTrainObj.classifierModel = fitcecoc(trainingSetFeature,trainingSetLabel,'Learners',t);
            
            %Validation
            validationSetFeature = [];
            validationSetLabel = [];
            for i = 1 : classTrainObj.validationNumSegment
                for j = 1 : length(dataVaidSplitActivity)
                    dataValidSegmentThisActivity = randomSelect(classTrainObj...
                    ,dataValidSplitActivity{j});
                    featureTemp = classificationFeature(dataValidSegmentThisActivity);
                    validationSetFeature = [validationSetFeature;featureTemp];
                    labelTemp = dataValidSplitActivity{j}.data.activityLabel(1);
                    validationSetLabel = [validationSetLabel;labelTemp];
                end
            end
            predictValidationSetLabel = predict(Mdl,validationSetFeature);
        end
    end
end

function [dataTrain,dataValid] = splitDataTrainValid(data,trainingRatio)
    if (class(data) == 'singleExperiment')
        if trainingRatio >1
            warning('ratio must be less than 1')
        else
            dataTrain = singleExperiment;
            dataTrain.samplingTime = data.samplingTime;
            dataValid = singleExperiment;
            dataValid.samplingTime = data.samplingTime;
            dataLength = length(data.data.time);
            trainingLength = floor(dataLength * trainingRatio);
            dataTrainArray = [data.data.time(1:trainingLength),...
                data.data.accelerationX(1:trainingLength),...
                data.data.accelerationY(1:trainingLength),...
                data.data.accelerationZ(1:trainingLength),...
                data.data.activityLabel(1:trainingLength)];
            
            dataValidArray = [data.data.time(trainingLength+1:end),...
                data.data.accelerationX(trainingLength+1:end),...
                data.data.accelerationY(trainingLength+1:end),...
                data.data.accelerationZ(trainingLength+1:end),...
                data.data.activityLabel(trainingLength+1:end)];
            dataTrain = setData(dataTrain,dataTrainArray);
            dataValid = setData(dataValid,dataValidArray);
        end
        
    else
        dataTrain = [];
        dataValid = [];
        warning('splitDataTrainValid: input data not supported...')
    end
end
            
function dataActivitySplit = splitDataActivity(data)
    if (class(data) == 'singleExperiment')
        indexNotScored = data.data.activityLabel == data.NOT_SCORED_CLASS;
        indexNoActivity = data.data.activityLabel == data.NO_ACTIVITY_CLASS;
        indexWalk = data.data.activityLabel == data.WALK_CLASS;
        indexRun = data.data.activityLabel == data.RUN_CLASS;
        dataNotScored = [data.data.time(indexNotScored,:),...
            data.data.accelerationX(indexNotScored,:),...
            data.data.accelerationY(indexNotScored,:),...
            data.data.accelerationZ(indexNotScored,:),...
            data.data.activityLabel(indexNotScored,:)];
        dataNoActivity = [data.data.time(indexNoActivity,:),...
            data.data.accelerationX(indexNoActivity,:),...
            data.data.accelerationY(indexNoActivity,:),...
            data.data.accelerationZ(indexNoActivity,:),...
            data.data.activityLabel(indexNoActivity,:)];
        dataWalk = [data.data.time(indexWalk,:),...
            data.data.accelerationX(indexWalk,:),...
            data.data.accelerationY(indexWalk,:),...
            data.data.accelerationZ(indexWalk,:),...
            data.data.activityLabel(indexWalk,:)];
        dataRun = [data.data.time(indexRun,:),...
            data.data.accelerationX(indexRun,:),...
            data.data.accelerationY(indexRun,:),...
            data.data.accelerationZ(indexRun,:),...
            data.data.activityLabel(indexRun,:)];
        dataActivitySplit = cell(3,1);
        dataActivitySplit{1} = singleExperiment;
        dataActivitySplit{1}.samplingTime = data.samplingTime;
        dataActivitySplit{1} = setData(dataActivitySplit{1},dataNoActivity);
        dataActivitySplit{2} = singleExperiment;
        dataActivitySplit{2}.samplingTime = data.samplingTime;
        dataActivitySplit{2} = setData(dataActivitySplit{1},dataWalk);
        dataActivitySplit{3} = singleExperiment;
        dataActivitySplit{3}.samplingTime = data.samplingTime;
        dataActivitySplit{3} = setData(dataActivitySplit{1},dataRun);
    else
        warning('splitDataActivity: input data not supported')
    end
end
function dataSegment = randomSelect(classTrainObj,data)
    if (class(data) == 'singleExperiment')
        segLength = classTrainObj.classificationRate;
        samplingRate = classTrainObj.samplingRate;
        segLength = floor(segLength/samplingRate);
        segmentInitPoint = randi([1 length(s.data.time)-segLength-1]);
        dataSegment = singleExperiment;
        dataSegment.samplingTime = data.samplingTime;
        dataSegmentData = [...
            data.data.time(segmentInitPoint:segmentInitPoint+segLength-1),...
            data.data.accelerationX(segmentInitPoint:segmentInitPoint+segLength-1),...
            data.data.accelerationY(segmentInitPoint:segmentInitPoint+segLength-1),...
            data.data.accelerationZ(segmentInitPoint:segmentInitPoint+segLength-1),...
            data.data.activityLabel(segmentInitPoint:segmentInitPoint+segLength-1)];
        dataSegment = setData(dataSegment,dataSegmentData);
    else
        warning('randomSelect: input data not supported...')
    end
    
end
        
        