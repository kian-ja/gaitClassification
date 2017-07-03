classdef singleExperiment
	properties
    	dataLoaded = 0;
		data = struct('time',[],'accelerationX',[],'accelerationY',[],...
            'accelerationZ',[],'activityLabel',[]);
		dataFormat = '%f,%f,%f,%f,%s';
		NOT_SCORED_CLASS = 0;
		NO_ACTIVITY_CLASS = 1;
		WALK_CLASS = 2;
		RUN_CLASS = 3;
	end
	methods
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%new function%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
		function singleExperimentObj = singleExperiment(fileName)
			if nargin<0
            	error('File name must be specified')
          	else
            	singleExperimentObj = readData(singleExperimentObj,fileName);
            	if checkData(singleExperimentObj)
                	singleExperimentObj.dataLoaded = 1;
            	else
                	warning('data format is not correct')
                    singleExperimentObj.data.time = [];
                    singleExperimentObj.data.accelerationX = [];
                    singleExperimentObj.data.accelerationY = [];
                    singleExperimentObj.data.accelerationZ = [];
                    singleExperimentObj.data.activityLabel = [];
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
            else
                dataFile = textscan(fileID,'%f,%f,%f,%f,%s');
                time = dataFile{1};
                accelerationX = dataFile{2};
                accelerationY = dataFile{3};
                accelerationZ = dataFile{4};
                activityLabel = dataFile{5};
                indexWalk = contains(activityLabel,'Walk');
                indexRun = contains(activityLabel,'Run');
                activityLabel = ones(size(activityLabel)) * singleExperimentObj.NO_ACTIVITY_CLASS;
                activityLabel(indexWalk) = singleExperimentObj.WALK_CLASS;
                activityLabel(indexRun) = singleExperimentObj.RUN_CLASS;
                if (length(activityLabel) == length(accelerationX) - 1)
                    activityLabel = [singleExperimentObj.NO_ACTIVITY_CLASS;activityLabel];
                end
                singleExperimentObj.data.time = time;
                singleExperimentObj.data.accelerationX = accelerationX;
                singleExperimentObj.data.accelerationY = accelerationY;
                singleExperimentObj.data.accelerationZ = accelerationZ;
                singleExperimentObj.data.activityLabel = activityLabel;
            end
        end
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%new function%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
		function dataHealth = checkData(singleExperimentObj)
            dataHealth = 0;
            lengthTime = length(singleExperimentObj.data.time);
            lengthX = length(singleExperimentObj.data.accelerationX);
            lengthY = length(singleExperimentObj.data.accelerationY);
            lengthZ = length(singleExperimentObj.data.accelerationZ);
            lengthLabel = length(singleExperimentObj.data.activityLabel);
            if (lengthTime + lengthX + lengthY + lengthZ + lengthLabel)...
                    /5 == lengthX && (lengthTime > 0)
                dataHealth = 1;
            end
		end
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%new function%%%%%
%%%%%%%%%%%%%%%%%%%%%%%		
		function plot(singleExperimentObj)
			subplot(4,1,1)
			plot(singleExperimentObj.data.time,singleExperimentObj.data.accelerationX)
			subplot(4,1,2)
			plot(singleExperimentObj.data.time,singleExperimentObj.data.accelerationY)
			subplot(4,1,3)
			plot(singleExperimentObj.data.time,singleExperimentObj.data.accelerationZ)
			subplot(4,1,4)
			plot(singleExperimentObj.data.time,singleExperimentObj.data.activityLabel)
		end
	end	
end