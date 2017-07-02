classdef singleExperiment
   properties
       dataLoaded = 0;
       data = struct('accelerationX',[],'accelerationY',[],...
            'accelerationZ',[],'activityLabel',[]);
   end
   methods
      function singleExperimentObj = singleExperiment(fileName)
          if nargin<0
              error('File name must be specified')
          else
              data = readData(fileName);
              if checkData()
                  singleExperimentObj.data = data;
                  singleExperimentObj.dataLoaded = 1;
              else
                  warning('data format is not correct')
                  singleExperimentObj.dataLoaded = 0;
              end
          end
      end
   end
end