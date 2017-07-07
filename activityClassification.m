classdef activityClassification
	properties
        classifierModel = [];
        classificationTrainingRate = 3;%in (s)
        classificationPredictionRate = 1;%in (s)
        samplingTime = 0.02;
        plotMode = 0;
        trainingNumSegment = 1500;
        validationNumSegment = 200;
        trainingRatio = 0.8;
        truePositiveIdentification = [];
        falsePositiveIdentification = [];
        truePositiveValidation = [];
        falsePositiveValidation = [];
        confusionIdentification = [];
        confusionValidation = [];
        numFeatures = 0;
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
		function predictionClassTimeHistory = simulateRealTime(classTrainObj,signal,emulationRate)
            if nargin==2
                emulationRate = 1;
            end
            if (class(signal)=='singleExperiment')
                
                model = classTrainObj.classifierModel;
                nSample = size(signal.dataMatrix,1);
                ts = classTrainObj.samplingTime;
                samplePerSegment = (classTrainObj.classificationPredictionRate/ts);
                nSeg = floor(nSample / samplePerSegment);
                predictionSegment = cell(nSeg,1);
                classTrainWindow = classTrainObj.classificationTrainingRate/0.02;
                featureAllSegments = zeros(nSeg,classTrainObj.numFeatures);
                h = waitbar(0,'please wait...');
                for i = 2 : nSeg
                    waitbar(i/nSeg);
                    dataThisSegment = signal;
                    if ((i-1)*samplePerSegment+2-classTrainWindow)<1
                        dataThisSegment.dataMatrix = dataThisSegment.dataMatrix(1:(i-1)*samplePerSegment + 1,:);
                        dataThisSegment.activityLabel = dataThisSegment.activityLabel(1:(i-1)*samplePerSegment + 1,:);
                        featureThisSegment = classificationFeature(dataThisSegment);
                        featureAllSegments(i,:) = featureThisSegment.feature;
                    else
                        dataThisSegment.dataMatrix = dataThisSegment.dataMatrix((i-1)*samplePerSegment+2-classTrainWindow:(i-1)*samplePerSegment + 1,:);
                        dataThisSegment.activityLabel = dataThisSegment.activityLabel((i-1)*samplePerSegment+2-classTrainWindow:(i-1)*samplePerSegment + 1,:);
                        featureThisSegment = classificationFeature(dataThisSegment);
                        featureAllSegments(i,:) = featureThisSegment.feature;
                    end
                end
                close(h);
                predictionSegment = predict(model,featureAllSegments);
                predictionClassTimeHistory = repmat(predictionSegment,1,samplePerSegment)';
                predictionClassTimeHistory = predictionClassTimeHistory(:);
                trueClassTimeHistory = signal.activityLabel;
                trueClassTimeHistory = trueClassTimeHistory(1:nSeg * samplePerSegment);
                if nargout < 1
                    figure
                    time = -10: ts:0-ts;
                    time = time';
                    numChannel = size(signal.dataMatrix,2) - 1;
                    dataThisFrame = nan(length(time),numChannel+1);
                    classThisFrame = nan(length(time),2);
                    classPredict = convertLabel2Num(predictionClassTimeHistory);
                    classTrue = convertLabel2Num(trueClassTimeHistory);
                    classPredictTrue = [classTrue,classPredict];
                    for i = 1 : nSeg
                        time = time + classTrainObj.classificationPredictionRate;
                        dataSegment = signal.dataMatrix((i-1)*samplePerSegment + 1:i*samplePerSegment,:);
                        classSegment = classPredictTrue((i-1)*samplePerSegment + 1:i*samplePerSegment,:);
                        dataThisFrame = shiftFrame(dataThisFrame,dataSegment);
                        classThisFrame = shiftFrame(classThisFrame,classSegment);
                        subplot(4,1,1);
                        plot(time,dataThisFrame(:,2))
                        ylim([-2,2])
                        title('Acceleration X')
                        subplot(4,1,2);
                        plot(time,dataThisFrame(:,3))
                        title('Acceleration Y')
                        ylim([-2,2])
                        subplot(4,1,3);
                        plot(time,dataThisFrame(:,4))
                        title('Acceleration Z')
                        ylim([-2,2])
                        subplot(4,1,4);
                        plot(time,classThisFrame(:,1),'b','lineWidth',3)
                        hold on
                        plot(time,classThisFrame(:,2),'--r','lineWidth',1)
                        legend('True Class','Predicted Class','location','north')
                        hold off
                        ylim([0,4])
                        set(gca,'YTick',[1:3])
                        set(gca,'YTickLabel',{'Neither';' Walk';'Run'})
                        pause(1/emulationRate);
                    end
                else
                end
            else
                warning('simulateRealTime: input signal not supported...')
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
            classTrainObj.numFeatures = length(featureTemp.feature);
            trainingSetLabel = trainingSetLabel';
            
            if classTrainObj.plotMode
                if size(trainingSetFeature,2) == 2
                    %class1 = trainingSetFeature([1:3:4500],:);
                    %class2 = trainingSetFeature([2:3:4500],:);
                    %class3 = trainingSetFeature([3:3:4500],:);

                    %plot(class1(:,1),class1(:,2),'o','markerFaceColor','k','markerEdgeColor','k')
                    %hold on
                    %plot(class2(:,1),class2(:,2),'o','markerFaceColor','r','markerEdgeColor','r')
                    %plot(class3(:,1),class3(:,2),'o','markerFaceColor','b','markerEdgeColor','b')
                    %grid on
                    %xlabel('Feature 1')
                    %ylabel('Feature 2')
                    %legend(trainingSetLabel{1},trainingSetLabel{2},trainingSetLabel{3})
                    gscatter(trainingSetFeature(:,1),trainingSetFeature(:,2),trainingSetLabel);
                    xlabel('Feature 1')
                    ylabel('Feature 2')
                end
                if size(trainingSetFeature,2) == 3
                    class1 = trainingSetFeature([1:3:4500],:);
                    class2 = trainingSetFeature([2:3:4500],:);
                    class3 = trainingSetFeature([3:3:4500],:);

                    plot3(class1(:,1),class1(:,2),class1(:,3),'o','markerFaceColor','k','markerEdgeColor','k')
                    hold on
                    plot3(class2(:,1),class2(:,2),class2(:,3),'o','markerFaceColor','r','markerEdgeColor','r')
                    plot3(class3(:,1),class3(:,2),class3(:,3),'o','markerFaceColor','b','markerEdgeColor','b')
                    grid on
                    xlabel('Feature 1')
                    ylabel('Feature 2')
                    zlabel('Feature 3')
                    legend(trainingSetLabel{1},trainingSetLabel{2},trainingSetLabel{3})
                end
            end
            %model = templateSVM('SaveSupportVectors','on','Kernel','linear');
            model = templateSVM('SaveSupportVectors','on','KernelFunction','linear');
            model = fitcecoc(trainingSetFeature,trainingSetLabel,'Learners',model);
            %model = fitctree(trainingSetFeature,trainingSetLabel);
            classTrainObj.classifierModel = model;
            predictTrainingSetLabel = predict(model,trainingSetFeature);
            
            tPosID = computeTruePositive(trainingSetLabel,predictTrainingSetLabel);
            fPosID = computeFalsePositive(trainingSetLabel,predictTrainingSetLabel);
            confusionID = computeConfusionMatrix(trainingSetLabel,predictTrainingSetLabel);
            classTrainObj.truePositiveIdentification = tPosID;
            classTrainObj.falsePositiveIdentification = fPosID;
            classTrainObj.confusionIdentification = confusionID;
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
            validationSetLabel = validationSetLabel';
            predictValidationSetLabel = predict(model,validationSetFeature);
            tPosValid = computeTruePositive(validationSetLabel,predictValidationSetLabel);
            fPosValid = computeFalsePositive(validationSetLabel,predictValidationSetLabel);
            confusionValid = computeConfusionMatrix(validationSetLabel,predictValidationSetLabel);
            classTrainObj.truePositiveValidation = tPosValid;
            classTrainObj.falsePositiveValidation = fPosValid;
            classTrainObj.confusionValidation = confusionValid;
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
        segLength = classTrainObj.classificationTrainingRate;
        samplingTime = classTrainObj.samplingTime;
        segLength = floor(segLength/samplingTime);
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
function dataFrame = shiftFrame(dataFrame,dataSegment)
    nSampleShift = size(dataSegment,1);
    dataFrame = circshift(dataFrame,-nSampleShift);
    dataFrame (end-nSampleShift+1:end,:) = dataSegment;
end
function labelMajorityEvent = majorityEventSelect(label)
    labelMajorityEventSegmented = zeros(size(label,1),1);
    for i = 1 : size(label,1)
        labelThisSegment = label(i,:);
        uniqueLabelsThisSegment = unique(labelThisSegment);
        uniqueLabelsThisSegmentOccurence = zeros(length(uniqueLabelsThisSegment),1);
        for j = 1 : length(uniqueLabelsThisSegment)
            uniqueLabelsThisSegmentOccurence(j) = length(find(labelThisSegment == uniqueLabelsThisSegment(j)));
        end
        [~,labelMajorityEventSegmented(i)] = max(uniqueLabelsThisSegmentOccurence);
    end
end
function classNum = convertLabel2Num(classLabel)
    classNum = zeros(size(classLabel));
    fIndex = strcmp(classLabel,'NAW');
    classNum(fIndex) = 1;
    fIndex = strcmp(classLabel,'Walk');
    classNum(fIndex) = 2;
    fIndex = strcmp(classLabel,'Run');
    classNum(fIndex) = 3;
end

function confusion = computeConfusionMatrix(trueValues,predictedValues)
    classes = unique(trueValues);
    numClasses = length(classes);
    confusion = zeros(numClasses,numClasses);
    for i = 1 : numClasses
        for j = 1 : numClasses
            confusion(i,j) = computeProbability(trueValues,predictedValues,classes(i),classes(j));
        end 
    end
end

function p = computeProbability(trueValues,predictedValues,trueClass,predictClass)
    indexTrue = strcmp(trueValues, trueClass);
    indexPredict = strcmp(predictedValues, predictClass);
    p = sum((indexTrue == indexPredict)&(indexTrue ==1))/sum(indexTrue);
end