function [v,wX,wY] = object_tracking(x,y,blobSize,imgWidth,imgHeight,params)
    %% Initialize persistent variables
    persistent xBuffer xPrev sizeBuffer outlierCount yBuffer yPrev
    if isempty(xBuffer); xBuffer = zeros(1,params.bufSize); end
    if isempty(sizeBuffer); sizeBuffer = zeros(1,params.bufSize); end
    if isempty(xPrev); xPrev = x; end
    if isempty(outlierCount); outlierCount = 0; end
    if isempty(yPrev); yPrev = y; end
    if isempty(yBuffer); yBuffer = zeros(1,params.bufSize); end
    %% Input processing
    % Count outliers
    if (abs(x-xPrev)<params.maxDisp) && (blobSize>params.minSize) && (blobSize<params.maxSize)      
        outlierCount = 0;
    else
        outlierCount = min(outlierCount+1,1000); % Increment with saturation
    end
    % Update and average the measurement buffers
    xBuffer = [xBuffer(2:params.bufSize) x];
    sizeBuffer = [sizeBuffer(2:params.bufSize) blobSize];
    xFilt = mean(xBuffer);
    sizeFilt = mean(sizeBuffer);
    xPrev = x;
    yBuffer = [yBuffer(2:params.bufSize) y];
    yFilt = mean(yBuffer);
    %% Angular velocity control: Keep the marker centered
    wX = 0;
    if outlierCount < params.maxCounts        
        posError = xFilt - imgWidth/2;
        if abs(posError) > params.posDeadZone
            speedReduction = max(sizeFilt/params.speedRedSize,1);
            wX = -params.angVelGain*posError*speedReduction;
        end
        if wX > params.maxAngVel
            wX = params.maxAngVel;
        elseif wX < -params.maxAngVel
            wX = -params.maxAngVel;
        end
    end
    
    wY = 0;
    if outlierCount < params.maxCounts        
        posErrorY = yFilt - imgHeight/2;
        if abs(posErrorY) > params.posDeadZone
            speedReduction = max(sizeFilt/params.speedRedSize,1);
            wY = -params.angVelGain*posErrorY*speedReduction;
        end
        if wY > params.maxAngVel
            wY = params.maxAngVel;
        elseif wY < -params.maxAngVel
            wY = -params.maxAngVel;
        end
    end

    %% Linear velocity control: Keep the marker at a certain distance
    v = 0;
    if outlierCount < params.maxCounts      
        sizeError = params.targetSize - sizeFilt;
        if abs(sizeError) > params.sizeDeadZone
            v = params.linVelGain*sizeError;
        end
        if v > params.maxLinVel
            v = params.maxLinVel;
        elseif v < -params.maxLinVel
            v = -params.maxLinVel;
        end
    end

    %% Scan autonomously for a while if the outlier count has been exceeded
    if outlierCount > 50 && outlierCount < 500
       w = params.maxAngVel/2; 
    end
    
end
