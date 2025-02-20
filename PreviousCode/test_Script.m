clc; close all; clear;
tStart = cputime;
load("MoMbenchmark\MoMbenchmarkData1.mat");

A = triverts(1,:)';
B = triverts(2,:)';
C = triverts(3,:)';

v = [A, B, C];

Icalc = zeros(length(r),1);

for ii=1:length(r)
   Icalc(ii, :) = triang_int(r(ii,:)', A, B, C); 
end

x_axis = r(:,3);

figure()
hold on;
patch(v(1,:), v(2,:), v(3,:), 'FaceColor', [0, 0, 0], 'linestyle', ':')
% plot3(A(1), A(2), A(3), 'ok', 'MarkerFaceColor', 'y')
% plot3(B(1), B(2), B(3), 'ok', 'MarkerFaceColor', 'b')
% plot3(C(1), C(2), C(3), 'ok', 'MarkerFaceColor', 'r')
plot3(r(:, 1), r(:, 2), r(:, 3), '-r', 'MarkerFaceColor', 'r')
grid on, grid minor;
axis image;
view([-37 -43]);
camroll(-360);
%axis([[-5 5 -0.05 0.15 -1 1]])
xlabel('x-axis')
ylabel('y-axis')
zlabel('z-axis')

figure()
subplot(2, 1, 1)
hold on
plot(x_axis, Ival, '--b', 'LineWidth', 1.2)
plot(x_axis, Icalc, ':r', 'LineWidth', 1.5)
legend("Benchmark", "Results"),
title("Comparison")
grid on, grid minor;
xlabel("Position [m]")
ylabel("Integral [dS/R]")
M = 100*(Ival-Icalc)./Ival;
[~, ind] = max(abs(M), [], 1, 'linear');

subplot(2, 1, 2)
hold on
plot(x_axis, M, 'b')
yline(M(ind), '--r', string(M(ind)),...
      'LabelHorizontalAlignment','center',...
      'LabelVerticalAlignment','middle');
legend("Error", "Max. error"),
title("Results Conformance")
xlabel("x position [m]")
ylabel("Porcentual error [%]")
grid on, grid minor;

%whos
simulationTime = cputime - tStart;

disp("Simulation time: "+num2str(simulationTime)+" s")