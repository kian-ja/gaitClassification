allExperiment = populationExperiment('data');
%%
f = figure('visible', 'off');
numClass = allExperiment.numClassesFound;
h = waitbar(0,'Saving figures. Please wait...');
step = 0;
for i = 1 : allExperiment.numClassesFound
    switchingIndexThisClass = allExperiment.dataActivitySorted{i}.switchingIndex;
    numThisClassOccur = length(switchingIndexThisClass);
    dataThisClass = allExperiment.dataActivitySorted{i}.dataMatrix;
    switchingIndexThisClass = [1;switchingIndexThisClass];
    for j = 1 : numThisClassOccur
        step = step + 1;
        waitbar((step)/(allExperiment.numClassesFound*numThisClassOccur));
        dataThisClassThisSegment = dataThisClass(switchingIndexThisClass(j)...
            :switchingIndexThisClass(j+1),:);
        accX = dataThisClassThisSegment(:,2);
        accY = dataThisClassThisSegment(:,3);
        accZ = dataThisClassThisSegment(:,4);
        if length(accX)>500
            clf
            subplot(3,2,1)
            plot(accX)
            title(['Time series',allExperiment.dataActivitySorted{i}.class])
            ylabel('Acceleration X')
            box off
            ylim([-2,2])
            subplot(3,2,2)
            accX = accX - mean(accX);
            [pxx,f] = pwelch(accX,500,[],[],50);
            pxx = pxx/sum(pxx.^2);
            plot(f,pxx,'lineWidth',2)
            xlim([0.2,25])
            %ylim([0,2.5])
            title(['Spectrum',allExperiment.dataActivitySorted{i}.class])
            box off
            
            subplot(3,2,3)
            plot(accY)
            ylabel('Acceleration Y')
            box off
            ylim([-2,2])
            subplot(3,2,4)
            accY = accY - mean(accY);
            [pxx,f] = pwelch(accY,500,[],[],50);
            pxx = pxx/sum(pxx.^2);
            plot(f,pxx,'lineWidth',2)
            xlim([0.2,25])    
            box off
            %ylim([0,2.5])
            
            subplot(3,2,5)
            plot(accZ)
            ylabel('Acceleration Z')
            xlabel('Time (sample)')
            box off
            ylim([-2,2])
            subplot(3,2,6)
            accZ = accZ - mean(accZ);
            [pxx,f] = pwelch(accZ,500,[],[],50);
            pxx = pxx/sum(pxx.^2);
            plot(f,pxx,'lineWidth',2)
            xlim([0.2,25])
            xlabel('Frequency (Hz)')
            box off
            %ylim([0,2.5])
            
            print(['results/',allExperiment.dataActivitySorted{i}.class,num2str(j)],'-dpdf','-fillpage')
        end
    end
end
waitbar(1);
pause(0.25)
close(h)