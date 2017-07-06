classdef classificationFeature
	properties
        flagFeature_SMV_Power = 1;
        flagFeature_SMV_LowFreqPower = 1;
        flagFeature_SMV_HighFreqPower = 0;
        flagFeature_SMV_DominantFreq = 1;
        
        flagFeatureAccelXPower = 0;
        flagFeatureAccelXLowFreqPower = 0;
        flagFeatureAccelXHighFreqPower = 0;
        flagFeatureAccelXDominantFreq = 0;
        
        flagFeatureAccelY_Power = 0;
        flagFeatureAccelYLowFreqPower = 0;
        flagFeatureAccelYHighFreqPower = 0;
        flagFeatureAccelYDominantFreq = 0;
        
        
        flagFeatureAccelZPower = 0;
        flagFeatureAccelZLowFreqPower = 0;
        flagFeatureAccelZHighFreqPower = 0;
        flagFeatureAccelZDominantFreq = 0;
        
        lowFreqCutOff = 1.5;
        highFreqCutOff = 7;
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
                    SMV = sqrt(accelerationX.^2 + accelerationY.^2 +accelerationZ.^2);
                    accelerationX = accelerationX - mean(accelerationX);
                    accelerationY = accelerationY - mean(accelerationY);
                    accelerationZ = accelerationZ - mean(accelerationZ);
                    SMV = SMV - mean(SMV);
                else
                    warning('Input not supported')
                end
            elseif (class(data) == 'singleExperiment')
                classFeatureObj.samplingTime = data.samplingTime;
                accelerationX = data.dataMatrix(:,2);
                accelerationY = data.dataMatrix(:,3);
                accelerationZ = data.dataMatrix(:,4);
                SMV = sqrt(accelerationX.^2 + accelerationY.^2 +accelerationZ.^2);
                accelerationX = accelerationX - mean(accelerationX);
                accelerationY = accelerationY - mean(accelerationY);
                accelerationZ = accelerationZ - mean(accelerationZ);
                SMV = SMV - mean(SMV);
            else
                    warning('Input not supported')
            end
                
            classFeatureObj.feature = [];
            %Signal power
            if (classFeatureObj.flagFeature_SMV_Power)
                feature_SMV_Power = computePower(SMV);
                classFeatureObj.feature = [classFeatureObj.feature feature_SMV_Power];
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
            if (classFeatureObj.flagFeature_SMV_HighFreqPower)
                feature_SMV_HF_Power = computeHighFreqPower(SMV,...
                    classFeatureObj.samplingTime,classFeatureObj.cutOffFreq);
                classFeatureObj.feature = [classFeatureObj.feature feature_SMV_HF_Power];
            end
            %Signal high frequency power
            if (classFeatureObj.flagFeature_SMV_HighFreqPower)
                feature_SMV_HF_Power = computeHighFreqPower(SMV...
                    ,classFeatureObj.samplingTime,classFeatureObj.cutOffFreq);
                classFeatureObj.feature = [classFeatureObj.feature feature_SMV_HF_Power];
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
            %Signal low frequency power
            if (classFeatureObj.flagFeature_SMV_LowFreqPower)
                feature_SMV_LF_Power = computeLowFreqPower(SMV...
                    ,classFeatureObj.samplingTime,classFeatureObj.lowFreqCutOff,...
                    classFeatureObj.highFreqCutOff);
                classFeatureObj.feature = [classFeatureObj.feature feature_SMV_LF_Power];
            end
            if (classFeatureObj.flagFeatureAccelXLowFreqPower)
                feature_AccX_LF_Power = computeLowFreqPower(accelerationX...
                    ,classFeatureObj.samplingTime,classFeatureObj.lowFreqCutOff,...
                    classFeatureObj.highFreqCutOff);
                classFeatureObj.feature = [classFeatureObj.feature feature_AccX_LF_Power];
            end
            
            if (classFeatureObj.flagFeatureAccelYLowFreqPower)
                feature_AccY_LF_Power = computeLowFreqPower(accelerationY...
                    ,classFeatureObj.samplingTime,classFeatureObj.lowFreqCutOff,...
                    classFeatureObj.highFreqCutOff);
                classFeatureObj.feature = [classFeatureObj.feature feature_AccY_LF_Power];
            end

            if (classFeatureObj.flagFeatureAccelZLowFreqPower)
                feature_AccZ_LF_Power = computeLowFreqPower(accelerationZ...
                    ,classFeatureObj.samplingTime,classFeatureObj.lowFreqCutOff,...
                    classFeatureObj.highFreqCutOff);
                classFeatureObj.feature = [classFeatureObj.feature feature_AccZ_LF_Power];
            end
            %Dominant frequency power
            if (classFeatureObj.flagFeature_SMV_DominantFreq)
                feature_SMV_DominantFreq = computeDominantFreq(SMV...
                    ,classFeatureObj.samplingTime,classFeatureObj.lowFreqCutOff...
                    ,classFeatureObj.highFreqCutOff);
                classFeatureObj.feature = [classFeatureObj.feature feature_SMV_DominantFreq];
            end
            if (classFeatureObj.flagFeatureAccelXDominantFreq)
                feature_AccX_DominantFreq = computeDominantFreq(accelerationX...
                    ,classFeatureObj.samplingTime,classFeatureObj.lowFreqCutOff...
                    ,classFeatureObj.highFreqCutOff);
                classFeatureObj.feature = [classFeatureObj.feature feature_AccX_DominantFreq];
            end
            if (classFeatureObj.flagFeatureAccelYDominantFreq)
                feature_AccY_DominantFreq = computeDominantFreq(accelerationY...
                    ,classFeatureObj.samplingTime,classFeatureObj.lowFreqCutOff...
                    ,classFeatureObj.highFreqCutOff);
                classFeatureObj.feature = [classFeatureObj.feature feature_AccY_DominantFreq];
            end
            if (classFeatureObj.flagFeatureAccelZDominantFreq)
                feature_AccZ_DominantFreq = computeDominantFreq(accelerationZ...
                    ,classFeatureObj.samplingTime,classFeatureObj.lowFreqCutOff...
                    ,classFeatureObj.highFreqCutOff);
                classFeatureObj.feature = [classFeatureObj.feature feature_AccZ_DominantFreq];
            end
        end
    end
end

function lowFreqPower = computeLowFreqPower(signal,samplingTime,cutOffLowF,cutOffHighF)
    signal = signal - mean(signal);
    [signalFFT,frequency]=fourier(signal,samplingTime);
    fIndex = frequency<=cutOffLowF;
    %baseLinePower = computeBaseline(frequency,signalFFT,cutOffHighF);
    baseLinePower = computePower(signal);
    lowFreqPower = sum(signalFFT(fIndex).^2)/baseLinePower;
end
function dominantFreqPower = computeDominantFreq(signal,samplingTime,cutOffLowF,cutOffHighF)
    signal = signal - mean(signal);
    numPeakFreq = 4;
    [signalFFT,frequency]=fourier(signal,samplingTime);
    %baseLinePower = computeBaseline(frequency,signalFFT,cutOffHighF);
    baseLinePower = computePower(signal);
    fIndex = (frequency>cutOffLowF) & (frequency<cutOffHighF);
    signalFFT = signalFFT(fIndex);
    dominantFreq = zeros(numPeakFreq,1);
    for i = 1 : numPeakFreq
        [dominantFreq(i),fIndex] = max(signalFFT);
        signalFFT(fIndex) = [];
    end
    dominantFreqPower = sum(dominantFreq.^2)/baseLinePower;
end
function signalPower = computePower(signal)
    signal = signal - mean(signal);
    signalPower = sum(signal.^2) / length(signal);
end
function baseline = computeBaseline(frequency,signalFFT,cutOffFreq)
    fIndex = frequency>cutOffFreq;
    %baseline = sum(signalFFT(fIndex).^2);
    baseline = sum(signalFFT.^2);
end
function signalHighFreqPower = computeHighFreqPower(signal,samplingTime,cutOffFreq)
    signal = signal - mean(signal);
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
        frequency = -1/2/samplingTime : 1/samplingTime/length(x) : 1/2/samplingTime-1/samplingTime/length(x);;
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