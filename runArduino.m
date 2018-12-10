delete(instrfindall);

throttleOutput = [0;0];

set_param('Model', 'SimulationCommand', 'start')

samples = 100; %number of samples
min = 1000;
max = 2000;

angle = double(nan(1, samples));
pwm = double(nan(1, samples));
time = double(nan(1, samples));

s1 = serial('COM4'); %Insert com port here

set(s1, 'baudrate', 115200);     % See List Below
set(s1, 'parity', 'n');        % 'n' or 'y'
set(s1, 'stopbits', 1);        % 1 or 2
set(s1, 'timeout', 123);     % 12.3 Seconds as an example here

fopen(s1);

subplot(2,1,1);
plotGraph = plot(time, angle, '-r');
title('Measured Angle');
subplot(2,1,2);
plotGraph1 = plot(time, pwm, '-b');
title('Measured Output');

throttBlock = getSimulinkBlockHandle('Model/ThrottleInput', true);
angleBlock = getSimulinkBlockHandle('Model/AngleInput', true);

tic
for x=1:samples
    time(x) = toc;

    angle(x) = fscanf(s1, '%d\n');
    set_param(angleBlock,'Value',num2str(angle(x))) %send a to the model
    pwm(x) = fscanf(s1, '%d\n');
    set_param(throttBlock,'Value',num2str(pwm(x))) %send a to the model
    
    subplot(2,1,1);
    set(plotGraph1, 'XData', time, 'YData', pwm);
    
    subplot(2,1,2);
    set(plotGraph, 'XData', time, 'YData', angle);
    
    %fprintf('%.2f\n', throttleOutput);    
    
    pause(0.1); %frequency
end

set_param('Model', 'SimulationCommand', 'stop');
fclose(s1);
delete(s1);