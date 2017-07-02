classdef singleExperiment
	properties
    	dataLoaded = 0;
		data = struct('time',[],'accelerationX',[],'accelerationY',[],...
            'accelerationZ',[],'activityLabel',[]);
		dataFormat = ['%f,%f,%f,%f,%s'];
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
            	data = readData(fileName);
            	if checkData(data)
                	singleExperimentObj.data = data;
                	singleExperimentObj.dataLoaded = 1;
            	else
                	warning('data format is not correct')
                	singleExperimentObj.dataLoaded = 0;
              	end
        	end
    	end
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%new function%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
		function data = readData(fileName)
			fileID = fopen(fileName);
		    data = textscan(fileID,'%f,%f,%f,%f,%s');
		    time = data{1};
		    accelerationX = data{2};
		    accelerationY = data{3};
		    accelerationZ = data{4};
		    activityLabel = data{5};
		    indexWalk = find(contains(activityLabel,'Walk'));
		    indexRun = find(contains(activityLabel,'Run'));
		    activityLabel = ones(size(activityLabel)) * NO_CLASS;
		    activityLabel(indexWalk) = WALK_CLASS;
		    activityLabel(indexRun) = RUN_CLASS;
		    if (length(activityLabel) == length(accelerationX) - 1)
				activityLabel = [NO_CLASS;activityLabel];
		    end
		    data = struct('time',time,'accelerationX',accelerationX,'accelerationY',accelerationY,...
            'accelerationZ',accelerationZ,'activityLabel',activityLabel);
		end
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%new function%%%%%
%%%%%%%%%%%%%%%%%%%%%%%		
		function setDataFormat (dataFormat)
			singleExperimentObj.dataFormat = dataFormat;
		end
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%new function%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
		function dataHealth = checkData(data)
			dataHealth = 1;
		end
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%new function%%%%%
%%%%%%%%%%%%%%%%%%%%%%%		
		function plot
			subplot(4,1,1)
			plot(data.time,data.accelerationX)
			subplot(4,1,2)
			plot(data.time,data.accelerationY)
			subplot(4,1,3)
			plot(data.time,data.accelerationZ)
			subplot(4,1,4)
			plot(data.time,data.activityLabel)
		end
	end	
end