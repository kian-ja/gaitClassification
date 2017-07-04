classdef classificationFeature
	properties
        feature_SMV_Power = 0;
        feature_SMV_HighFreqPower = 0;
        featureAccelXPower = 1;
        featureAccelY_Power = 1;
        featureAccelZPower = 0;
        featureAccelXHighFreqPower = 0;
        featureAccelYHighFreqPower = 0;
        featureAccelZHighFreqPower = 0;
	end
	methods
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%new function%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
		function classFeatureObj = classificationFeature(data)
			if (nargin < 1)
            	
            else
                if numeric(data)
                else
                    warning('Input not supported')
                end
            end
    	end

	end	
end