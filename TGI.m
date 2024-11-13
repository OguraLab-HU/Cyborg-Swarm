clear
clc

% Parameters
N = 19; % number of followers
N_sec = 18; % number of sectors
r = 5; % sensing range
rFree = 1; % free range
numIterations = 600;  % Max steps

% Initialization
Followers = rand(N, 2) * 5;  
leader = [2.5, 2.5];            
maxSector = zeros(1, N);
moveVector = zeros(N, 2);
angleFollower = zeros(N, N);

% Make video
videoFile = 'animation.mp4'; 
writerObj = VideoWriter(videoFile, 'MPEG-4'); 
writerObj.FrameRate = 10; 
open(writerObj); % Open video writer

% Start simulation
for iter = 1:numIterations
        
    % Compute repulsive force to mimick natural avoidance among cyborg insects 
    repulsiveForce = zeros(N, 2);
    for i = 1:N
        for j = 1:N
            if i ~= j
                distance = norm(Followers(i, :) - Followers(j, :));
                if distance <= r % Recieve repulsive force only from neighbors
                    repulsiveForce(i, :) = repulsiveForce(i, :) + 0.1 * (Followers(i, :) - Followers(j, :)) / distance^2;
                end
            end
        end
    end
    
    % Compute driven force
    for i = 1:N
        follower = Followers(i, :);
        
        % Sensing range of followers
        circleMaskFollower = vecnorm(Followers - follower, 2, 2) <= r & vecnorm(Followers - follower, 2, 2) > 0;
        % Free zone of followers
        circleMaskFollowerFree = vecnorm(Followers - follower, 2, 2) <= rFree & vecnorm(Followers - follower, 2, 2) > 0;
        % Sensing range of leader
        circleMaskLeader = vecnorm(leader - follower, 2) <= r;
        
        angleLeader = atan2(leader(2) - Followers(:, 2), leader(1) - Followers(:, 1)); % Angle between leader and followers
        angleLeader(angleLeader < 0) = angleLeader(angleLeader < 0) + 2 * pi;   % Change angle to the range from 0 to 2*pi
        angleFollower(i, :) = atan2(follower(2) - Followers(:, 2), follower(1) - Followers(:, 1)); % Angle between folower i and other followers
        angleFollower(angleFollower < 0) = angleFollower(angleFollower < 0) + 2 * pi;  % Change angle to the range from 0 to 2*pi
        
        % Compute number of agents in each sector
        for j = 1:N_sec
            numLeaderInSector(i, j) = sum(circleMaskLeader & (angleLeader(i) >= 2 * pi * (j - 1) / N_sec) & (angleLeader(i) < 2 * pi * j / N_sec));
            numFollowersInSector(i, j) = sum(circleMaskFollower & (angleFollower(i) >= 2 * pi * (j - 1) / N_sec) & (angleFollower(i) < 2 * pi * j / N_sec));
            numFollowersInSectorRep(i, j) = sum(circleMaskFollowerFree & (angleFollower(i) >= 2 * pi * (j - 1) / N_sec) & (angleFollower(i) < 2 * pi * j / N_sec));
        end
                
        % Drive follower to the max sector
        [~, maxSector(i)] = max(numFollowersInSector(i, :) + N * numLeaderInSector(i, :));
        
        % Compute the angle to the max sector
        angleMax(i) = (maxSector(i) - 1) * (2 * pi / N_sec) + (pi / N_sec);
        
        % When numbers of neighbors in the free zone larger than
        % threshhold, driven force is triggered. Else, do free motion
        if sum(circleMaskFollowerFree == 1)  < 5
            moveVector(i,:) = 0.1 * rand * [cos(angleMax(i)), sin(angleMax(i))] + 0.025 * repulsiveForce(i, :);
        else
            moveVector(i,:) = moveVector(i,:) + 0.02 * rand(1,2) - [0.01,0.01];
        end
                
    end
    
    % Update leader and followers
    Followers = Followers + moveVector;
    leader = leader + [0.025, 0];
    
    % Animation
    figure(1);
    set(gcf, 'Position', [100, 100, 800, 600]);
    
    plot(Followers(:, 1), Followers(:, 2), '.', 'MarkerEdgeColor', 'b', 'MarkerSize', 15)
    hold on;
    plot(leader(1), leader(2), '.', 'MarkerEdgeColor', 'r', 'MarkerSize', 30)
    hold off;
    axis([0, 20, 0, 5]);
    xticks(0:5:30);
    yticks(0:2.5:10);
    daspect([1, 1, 1]);
    xlabel('X');
    ylabel('Y');
    title(['Iteration ', num2str(iter)]);
    drawnow;

    % Add each frame to video
    slide(j) = getframe(gcf);
    writeVideo(writerObj, slide(j));

end

% Close video writer
close(writerObj)
