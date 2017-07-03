classdef populationExperiment
	properties
    	allDataLoaded = 0;
		data;
	end
	methods
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%new function%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
		function populationExperimentObj = populationExperiment(directory)
			if nargin<1
            	disp('current directory will be considered')
                populationExperimentObj = readAllFiles(populationExperimentObj);
          	else
            	populationExperimentObj = readAllFiles(populationExperimentObj,directory);
        	end
    	end
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%new function%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
		function populationExperimentObj = readAllFiles(populationExperimentObj,directory)
			
        end
	end	
end