classdef classificationFeature
	properties
        flagFeature_SMV_Power = 0;
        flagFeature_SMV_HighFreqPower = 0;
        flagFeatureAccelXPower = 1;
        flagFeatureAccelY_Power = 1;
        flagFeatureAccelZPower = 0;
        flagFeatureAccelXHighFreqPower = 0;
        flagFeatureAccelYHighFreqPower = 0;
        flagFeatureAccelZHighFreqPower = 0;
        feature = [];
	end
	methods
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%new function%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
		function classFeatureObj = classificationFeature(data)
			if (nargin < 1)
            	
            else
                classFeatureObj = createFeature(classFeatureObj,data);
            end
        end
        function classFeatureObj = createFeature(classFeatureObj,data)
            if numeric(data)
                if (size(data,2) > size(data,1))
                    data = data';
                end
                if (size(data,2) == 3)
                    data = 1;
                else
                    warning('Input not supported')
                end
            elseif (class(data) == 'singleExperiment')
                data = 1;
            else
                    warning('Input not supported')
            end
                
            feature = [];
            
            if (classFeatureObj.flagFeature_SMV_Power)
                feature = [feature; 
            end
            if (classFeatureObj.flagFeature_SMV_HighFreqPower)
            end
            if (classFeatureObj.flagFeatureAccelXPower)
            end
            if (classFeatureObj.flagFeatureAccelY_Power)
            end
            if (classFeatureObj.flagFeatureAccelZPower)
            end
            if (classFeatureObj.flagFeatureAccelXHighFreqPower)
            end
            if (classFeatureObj.flagFeatureAccelYHighFreqPower)
            end
            if (classFeatureObj.flagFeatureAccelZHighFreqPower)
            end
        end
	end	
end