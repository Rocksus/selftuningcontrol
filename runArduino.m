delete(instrfindall);

throttleOutput = [0;0];

set_param('Model', 'SimulationCommand', 'start')

samples = 1000; %number of samples
min = 1000;
max = 2000;

angle = double(nan(1, samples));
pwm = double(nan(1, samples));
time = double(nan(1, samples));

s1 = serial('COM4'); %Insert com port here

set(s1, 'baudrate', 250000);     % parameter settings for serial connections
set(s1, 'parity', 'n');
set(s1, 'stopbits', 1);       
set(s1, 'timeout', 123);     

fopen(s1);

set_param('Model', 'SimulationCommand', 'pause');
pause(7);
set_param('Model', 'SimulationCommand', 'continue');

%set initial PID values
set_param('Model/Controller', 'P', num2str(2.7));
set_param('Model/Controller', 'I', num2str(0.006));
set_param('Model/Controller', 'D', num2str(1.4));

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

    angle(x) = fscanf(s1, '%f\n');
    set_param(angleBlock,'Value',num2str(angle(x))) %send data to the model
    pwm(x) = fscanf(s1, '%f\n');
    set_param(throttBlock,'Value',num2str(pwm(x))) %send data to the model
    
    subplot(2,1,1);
    set(plotGraph1, 'XData', time, 'YData', pwm);
    
    subplot(2,1,2);
    set(plotGraph, 'XData', time, 'YData', angle);
    
    fprintf(s1, '%.2f\n', throttleOutput);    %sends data back to arduino
    
    pause(0.005); %frequency
end

set_param('Model', 'SimulationCommand', 'stop');
fclose(s1);
delete(s1);