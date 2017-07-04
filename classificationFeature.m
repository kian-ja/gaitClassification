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
        samplingTime = [];
        cutOffFreq = 3;
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
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%new function%%%%%
%%%%%%%%%%%%%%%%%%%%%%%        
        function classFeatureObj = createFeature(classFeatureObj,data)
            if isnumeric(data)
                if (size(data,2) > size(data,1))
                    data = data';
                end
                if (size(data,2) == 5)
                    accelerationX = data(:,2);
                    accelerationY = data(:,3);
                    accelerationZ = data(:,4);
                else
                    warning('Input not supported')
                end
            elseif (class(data) == 'singleExperiment')
                classFeatureObj.samplingTime = data.samplingTime;
                accelerationX = data.data.accelerationX;
                accelerationY = data.data.accelerationY;
                accelerationZ = data.data.accelerationZ;
            else
                    warning('Input not supported')
            end
                
            classFeatureObj.feature = [];
            
            if (classFeatureObj.flagFeature_SMV_Power)
                feature_SMV_Power = computePower(accelerationX.^2+...
                    accelerationY.^2+accelerationZ.^2);
                classFeatureObj.feature = [classFeatureObj.feature feature_SMV_Power];
            end
            if (classFeatureObj.flagFeature_SMV_HighFreqPower)
                feature_SMV_HF_Power = computeHighFreqPower(accelerationX.^2+...
                    accelerationY.^2+accelerationZ.^2,...
                    classFeatureObj.samplingTime,classFeatureObj.cutOffFreq);
                classFeatureObj.feature = [classFeatureObj.feature feature_SMV_HF_Power];
            end
            if (classFeatureObj.flagFeatureAccelXPower)
                feature_AccX_Power = computePower(accelerationX);
                classFeatureObj.feature = [classFeatureObj.feature feature_AccX_Power];
            end
            if (classFeatureObj.flagFeatureAccelY_Power)
                feature_AccY_Power = computePower(accelerationY);
                classFeatureObj.feature = [classFeatureObj.feature feature_AccY_Power];
            end
            if (classFeatureObj.flagFeatureAccelZPower)
                feature_AccZ_Power = computePower(accelerationZ);
                classFeatureObj.feature = [classFeatureObj.feature feature_AccZ_Power];
            end
            if (classFeatureObj.flagFeatureAccelXHighFreqPower)
                feature_AccX_HF_Power = computeHighFreqPower(accelerationX...
                    ,classFeatureObj.samplingTime,classFeatureObj.cutOffFreq);
                classFeatureObj.feature = [classFeatureObj.feature feature_AccX_HF_Power];
            end
            if (classFeatureObj.flagFeatureAccelYHighFreqPower)
                feature_AccY_HF_Power = computeHighFreqPower(accelerationY...
                    ,classFeatureObj.samplingTime,classFeatureObj.cutOffFreq);
                classFeatureObj.feature = [classFeatureObj.feature feature_AccY_HF_Power];
            end
            if (classFeatureObj.flagFeatureAccelZHighFreqPower)
                feature_AccZ_HF_Power = computeHighFreqPower(accelerationZ...
                    ,classFeatureObj.samplingTime,classFeatureObj.cutOffFreq);
                classFeatureObj.feature = [classFeatureObj.feature feature_AccZ_HF_Power];
            end
        end
	end	
end

function signalPower = computePower(signal)
    signalPower = sum(signal.^2);
end
function signalHighFreqPower = computeHighFreqPower(signal,samplingTime,cutOffFreq)
    if nargin==1
        samplingTime = 0.02;
        cutOffFreq = 3;
    elseif nargin==2
        samplingTime = 0.02;
    end
    [signalFFT,frequency]=fourier(signal,samplingTime);
    fIndex = frequency>=cutOffFreq;
    signalHighFreqPower = sum(signalFFT(fIndex).^2);
end

function [X,frequency] = fourier(x,samplingTime)
    if iseven(length(x)) == 0
        frequency = -1/2/samplingTime : 1/samplingTime/length(x) : 1/2/samplingTime;
    else
        frequency = -1/2/samplingTime : 1/samplingTime/length(x) : 1/2/samplingTime-1/samplingTime/length(x);
    end
    X = fft(x) / length(x);
    X = FFTmirror(X);
    X = abs(X);
    freqIndex = frequency >= 0;
    frequency = frequency(freqIndex);
    X = X(freqIndex);
    frequency = frequency(:);
    X = X(:);
end

function y = FFTmirror(x)
    if min(size(x)) > 1
      error('Input must be a vector.')
    end
    is_column = size(x, 1) > 1;
    x = x(:);
    len = length(x);
    if iseven(len)
        yy = [x((len+2)/2:len); x(1:(len+2)/2)];
        yy(1) = conj(yy(1));
    else
        yy = fftshift(x);
    end
    if is_column
      y = yy;
    else
      y = yy.';
    end
end
function y = iseven(x)
    % ISEVEN tests for the input value being even
    %
    %     Y = ISEVEN(X) returns 1 if X ix even and returns 0 otherwise. At present this
    %     function accepts scalar X.
    y = fix(x/2) * 2 == x;
end