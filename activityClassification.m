classdef activityClassification
	properties
        classifierModel = [];
        classificationRate = 4; %1Hz
        samplingRate = 0.02;
        plotMode = true;
        trainingNumSegment = 1500;
        validationNumSegment = 200;
        trainingRatio = 0.8;
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
                %data = data.dataConcatenated;
                %data = data.dataActivitySorted;
            end
            [dataTraining,dataValidation] = splitDataTrainValid...
                (data,classTrainObj.trainingRatio);
            
            %Training
            trainingSetFeature = [];
            trainingSetLabel = [];
            for i = 1 : classTrainObj.trainingNumSegment
                for j = 1 : data.numClassesFound
                    dataTrainSegmentThisActivity = randomSelect(classTrainObj...
                    ,dataTraining,j);
                    featureTemp = classificationFeature(dataTrainSegmentThisActivity);
                    trainingSetFeature = [trainingSetFeature;featureTemp.feature];
                    labelTemp = dataTraining.dataActivitySorted{j}.class;
                    trainingSetLabel{end+1} = labelTemp;
                end
            end
            trainingSetLabel = trainingSetLabel';
            %model = templateSVM('SaveSupportVectors','on','Kernel','linear');
            model = templateSVM('SaveSupportVectors','on','KernelFunction','linear');
            model = fitcecoc(trainingSetFeature,trainingSetLabel,'Learners',model);
            %model = fitctree(trainingSetFeature,trainingSetLabel);
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
                for j = 1 : data.numClassesFound
                    dataValidSegmentThisActivity = randomSelect(classTrainObj...
                    ,dataValidation,j);
                    featureTemp = classificationFeature(dataValidSegmentThisActivity);
                    validationSetFeature = [validationSetFeature;featureTemp.feature];
                    labelTemp = dataValidation.dataActivitySorted{j}.class;
                    validationSetLabel{end+1} = labelTemp;
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
        indexThisClass = contains(signalTrue, classes(i));
        indexThisClass = find(indexThisClass==1);
        numThisClassOccured = length(indexThisClass);
        probabilityThisClass = numThisClassOccured/length(signalTrue);
        numThisClassPredicted = sum(contains(signalMeasured (indexThisClass) , classes(i)));
        truePositive = truePositive + ...
            numThisClassPredicted/numThisClassOccured * probabilityThisClass;
    end
end
function falsePositive = computeFalsePositive(signalTrue,signalMeasured)
    classes = unique(signalTrue);
    numClasses = length(classes);
    falsePositive = 0;
    for i = 1 : numClasses
        indexNotThisClass = strcmp(signalTrue, classes(i));
        indexNotThisClass = find(indexNotThisClass ==0);
        numNotThisClassOccured = length(indexNotThisClass);
        probabilityNotThisClass = numNotThisClassOccured/length(signalTrue);
        numThisClassPredicted = sum(strcmp(signalMeasured (indexNotThisClass),classes(i)));
        falsePositive = falsePositive + ...
            numThisClassPredicted/numNotThisClassOccured * probabilityNotThisClass;
    end
end
function [dataTrain,dataValid] = splitDataTrainValid(data,trainingRatio)
    if trainingRatio >1
        warning('ratio must be less than 1')
    else
        dataTrain = data;
        dataValid = data;
        dataTrain.data = [];
        dataValid.data = [];
        for i = 1 : data.numClassesFound
            dataLengthThisClass = size(data.dataActivitySorted{i}.dataMatrix,1);

            trainingLength = floor(dataLengthThisClass * trainingRatio);
            dataTrain.dataActivitySorted{i}.dataMatrix =...
            data.dataActivitySorted{i}.dataMatrix(1:trainingLength,:);
            dataTrain.dataActivitySorted{i}.switchingIndex =...
            data.dataActivitySorted{i}.switchingIndex(...
            data.dataActivitySorted{i}.switchingIndex < trainingLength);
            dataTrain.dataActivitySorted{i}.switchingIndex = ...
                [dataTrain.dataActivitySorted{i}.switchingIndex;trainingLength];

            dataValid.dataActivitySorted{i}.dataMatrix =...
            data.dataActivitySorted{i}.dataMatrix(trainingLength + 1 :end,:);
            dataValid.dataActivitySorted{i}.switchingIndex =...
            data.dataActivitySorted{i}.switchingIndex(...
            data.dataActivitySorted{i}.switchingIndex >= trainingLength)...
            - trainingLength;
        end
    end
end

function dataSegment = randomSelect(classTrainObj,data,numClassSelect)
    if (class(data) == 'populationExperiment')
        segLength = classTrainObj.classificationRate;
        samplingRate = classTrainObj.samplingRate;
        segLength = floor(segLength/samplingRate);
        nSamp = size(data.dataActivitySorted{numClassSelect}.dataMatrix,1);
        if ((nSamp-segLength-1)>1)
            containsDiscontin = 1;
            while containsDiscontin
                segmentInitPoint = randi([1 nSamp-segLength-1]);
                selectedRange = [segmentInitPoint:segmentInitPoint+segLength-1];
                containsDiscontin = sum(ismember(selectedRange,data.dataActivitySorted{numClassSelect}.switchingIndex));
            end
            dataSegment = singleExperiment;
            selectedDataMatrix = ...
            data.dataActivitySorted{numClassSelect}.dataMatrix(segmentInitPoint:segmentInitPoint+segLength-1,:);
            thisClass = data.dataActivitySorted{numClassSelect}.class;
            activityLabel = repmat({thisClass},segLength,1);
            dataSegment = setData(dataSegment,selectedDataMatrix,activityLabel);
        else
            dataSegment = [];
            warning('Not enough data point for this class')
        end
    else
        dataSegment = [];
        warning('randomSelect: input data not supported...')
    end
    
end
        
        