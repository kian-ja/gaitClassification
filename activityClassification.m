classdef activityClassification
	properties
        classifierModel = [];
        classificationRate = 4; %1Hz
        samplingRate = 0.02;
        plotMode = true;
        trainingNumSegment = 500;
        validationNumSegment = 500;
        trainingRatio = 0.5;
        truePositiveIdentification = [];
        falsePositiveIdentification = [];
        truePositiveValidation = [];
        falsePositiveValidation = [];
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
            for i = 1 : classTrainObj.trainingNumSegment
                for j = 1 : length(dataTrainSplitActivity)
                    dataTrainSegmentThisActivity = randomSelect(classTrainObj...
                    ,dataTrainSplitActivity{j});
                    featureTemp = classificationFeature(dataTrainSegmentThisActivity);
                    trainingSetFeature = [trainingSetFeature;featureTemp.feature];
                    labelTemp = dataTrainSplitActivity{j}.data.activityLabel(1);
                    trainingSetLabel = [trainingSetLabel;labelTemp];
                end
            end
            model = templateSVM('SaveSupportVectors','on');
            model = fitcecoc(trainingSetFeature,trainingSetLabel,'Learners',model);
            classTrainObj.classifierModel = model;
            predictTrainingSetLabel = predict(model,trainingSetFeature);
            
            tPosID = computeTruePositive(trainingSetLabel,predictTrainingSetLabel);
            fPosID = computeFalsePositive(trainingSetLabel,predictTrainingSetLabel);
            classTrainObj.truePositiveIdentification = tPosID;
            classTrainObj.falsePositiveIdentification = fPosID;
            %Validation
            validationSetFeature = [];
            validationSetLabel = [];
            for i = 1 : classTrainObj.validationNumSegment
                for j = 1 : length(dataValidSplitActivity)
                    dataValidSegmentThisActivity = randomSelect(classTrainObj...
                    ,dataValidSplitActivity{j});
                    if ~isempty(dataValidSegmentThisActivity)
                        featureTemp = classificationFeature(dataValidSegmentThisActivity);
                        validationSetFeature = [validationSetFeature;featureTemp.feature];
                        labelTemp = dataValidSplitActivity{j}.data.activityLabel(1);
                        validationSetLabel = [validationSetLabel;labelTemp];
                    end
                end
            end
            predictValidationSetLabel = predict(model,validationSetFeature);
            tPosValid = computeTruePositive(validationSetLabel,predictValidationSetLabel);
            fPosValid = computeFalsePositive(validationSetLabel,predictValidationSetLabel);
            
            classTrainObj.truePositiveValidation = tPosValid;
            classTrainObj.falsePositiveValidation = fPosValid;
        end
    end
end
function truePositive = computeTruePositive(signalTrue,signalMeasured)
    classes = unique(signalTrue);
    numClasses = length(classes);
    truePositive = 0;
    for i = 1 : numClasses
        indexThisClass = find(signalTrue == classes(i));
        numThisClassOccured = length(indexThisClass);
        probabilityThisClass = numThisClassOccured/length(signalTrue);
        numThisClassPredicted = sum(signalMeasured (indexThisClass) == classes(i));
        truePositive = truePositive + ...
            numThisClassPredicted/numThisClassOccured * probabilityThisClass;
    end
end
function falsePositive = computeFalsePositive(signalTrue,signalMeasured)
    classes = unique(signalTrue);
    numClasses = length(classes);
    falsePositive = 0;
    for i = 1 : numClasses
        indexNotThisClass = find(signalTrue ~= classes(i));
        numNotThisClassOccured = length(indexNotThisClass);
        probabilityNotThisClass = numNotThisClassOccured/length(signalTrue);
        numThisClassPredicted = sum(signalMeasured (indexNotThisClass) == classes(i));
        falsePositive = falsePositive + ...
            numThisClassPredicted/numNotThisClassOccured * probabilityNotThisClass;
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
        dataActivitySplit{2} = setData(dataActivitySplit{2},dataWalk);
        dataActivitySplit{3} = singleExperiment;
        dataActivitySplit{3}.samplingTime = data.samplingTime;
        dataActivitySplit{3} = setData(dataActivitySplit{3},dataRun);
    else
        warning('splitDataActivity: input data not supported')
    end
end
function dataSegment = randomSelect(classTrainObj,data)
    if (class(data) == 'singleExperiment')
        segLength = classTrainObj.classificationRate;
        samplingRate = classTrainObj.samplingRate;
        segLength = floor(segLength/samplingRate);
        if ((length(data.data.time)-segLength-1)>1)
            segmentInitPoint = randi([1 length(data.data.time)-segLength-1]);
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
            dataSegment = [];
            warning('Not enough data point for this class')
        end
    else
        dataSegment = [];
        warning('randomSelect: input data not supported...')
    end
    
end
        
        