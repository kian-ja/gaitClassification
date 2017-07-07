allExperiments = populationExperiment('data');
classifier = activityClassification(allExperiments);
save('results/classifier.mat','classifier')
disp(['True positive for this classifier: '])
disp(['True Positive ID: ',num2str(classifier.truePositiveIdentification)])
disp(['True Positive Valid: ',num2str(classifier.truePositiveValidation)])
disp(['False positive for this classifier: '])
disp(['False Positive ID: ',num2str(classifier.falsePositiveIdentification)])
disp(['False Positive Valid: ',num2str(classifier.falsePositiveValidation)])

testRealTime = singleExperiment('data/hw_file_3.csv');
simulateRealTime(classifier,testRealTime)