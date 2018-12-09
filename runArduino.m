delete(instrfindall);
set_param('Model', 'SimulationCommand', 'start')

samples = 1000; %number of samples
min = 0;
max = 1023;
delay = 1;

angle = double(nan(1, samples));
pwm = double(nan(1, samples));
time = double(nan(1, samples));

s1 = serial('COM9'); %Insert com port here

set(s1, 'baudrate', 115200);     % See List Below
set(s1, 'parity', 'n');        % 'n' or 'y'
set(s1, 'stopbits', 1);        % 1 or 2
set(s1, 'timeout', 123);     % 12.3 Seconds as an example here

fopen(s1);

subplot(2,1,1);
plotGraph = plot(time, angle, '-r');
subplot(2,1,2);
plotGraph1 = plot(time, pwm, '-b');
title('Motor Control');
xlabel('Time');
%ylabel('potentio');

flushinput(s1);

tic
for x=1:samples
    time(x) = toc;
    
    angle(x) = fscanf(s1, '%d\n');
    set_param('Model/AngleInput','Value',num2str(angle(x))) %send a to the model
    pwm(x) = fscanf(s1, '%d\n');
    set_param('Model/ThrottleInput','Value',num2str(pwm(x))) %send a to the model
    

    set(plotGraph, 'XData', time, 'YData', angle);
    set(plotGraph1, 'XData', time, 'YData', pwm);
    
    axis([0 time(x) min max]);
    pause(0.1); %frequency
end

set_param('Model', 'SimulationCommand', 'stop');
fclose(s1);
delete(s1);