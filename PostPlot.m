function PostPlot()

Directory = './Turbulence/Beta1/';
% Folder    = '2020-07-06 16-08-44/';
Folder    = '2020-07-24 11-44-49//';

filename = @(n) [Directory Folder sprintf('%u',n) '.mat'];

PlotChoice    = 2;      % 1 for energy v time of run;  2 for visualisation of zeta^p/m


Nfiles = length(dir([Directory Folder '*.mat']))-1;       % '-1' accounts for 0.mat
Number = 200;       % Plots most recent *.mat file in 'Directory' Change to an integer less than Nfiles for any other saved 'snapshot' in directory

Fullscreen    = 1;

SavePlot      = 0;
PlotDirectory    = './';  % Directory the plot is saved to

filename = @(n) [Directory Folder sprintf('%u',n) '.mat'];
%% Loading Parameters from 0.mat
Init0 = load(filename(0));
input = Init0.input;
SlowModes = input.Parameters.SlowModes;

VariableTimeStep = input.Parameters.VariableTimeStep;
if VariableTimeStep == 0
    dt = input.Parameters.dtFixed;
end

if PlotChoice == 2                % Visualisation Information
    KX = input.KX; KY = input.KY; KZ = input.KZ;
    NX = input.Parameters.NX; NY = input.Parameters.NY; NZ = input.Parameters.NZ;
    LX = input.Parameters.LX; LY = input.Parameters.LY; LZ = input.Parameters.LZ;
    
    dx = LX/NX; dy = LY/NY; dz = LZ/NZ;
    
    k2_perp = KX.^2 + KY.^2;      % (Perpendicular) Laplacian in Fourier space
    k2_poisson = k2_perp; k2_poisson(1,1,:) = 1;
    
    [i,j,k] = ndgrid((1:NX)*dx,(1:NY)*dy,(1:NZ)*dz);
    XG = permute(i, [2 1 3]); YG = permute(j, [2 1 3]); ZG = permute(k, [2 1 3]);
end

%% Loading Data from n.mat
Init1 = load(filename(Number));
output = Init1.output;

if PlotChoice == 1      %%% Energy Plot
    Ezp = output.Ezp;
    Ezm = output.Ezm;
    
    if VariableTimeStep == 1
        TSlice = output.time;
        t = output.timevec;
        t = t(2:find(t,1,'last'));  % Trims vectors of trailing zeros
        Ezp = Ezp(1:length(t));     
        Ezm = Ezm(1:length(t));
        if SlowModes == 1
            Esp = output.Esp;
            Esm = output.Esm;
            Esp = Esp(1:length(t));
            Esm = Esm(1:length(t));
        else
            Esp = 0;
            Esm = 0;
        end
    else
        TSlice = output.time;
        t = dt:dt:TSlice;
        Esp = output.Esp;
        Esm = output.Esm;
        Esp = Esp(1:length(t));
        Esm = Esm(1:length(t));
    end

%     assignin('base', 'Ezp', Ezp);
%     assignin('base', 'Ezm', Ezm);
%     assignin('base', 'Esp', Esp);
%     assignin('base', 'Esm', Esm);
%     assignin('base', 't', t);
    
%     assignin('base', 'Ezp1', Ezp);
%     assignin('base', 'Ezm1', Ezm);
%     assignin('base', 'Esp1', Esp);
%     assignin('base', 'Esm1', Esm);
%     assignin('base', 't1', t);
%     
    EnergyPlot(Ezp, Ezm, t, TSlice, SlowModes, Esp, Esm)
    
elseif PlotChoice == 2  %%% Visualisation
    Lap_z_plus  = output.Lzp;
    Lap_z_minus = output.Lzm;
    t = output.time;
        
    try
        s_plus  = output.sp;
        s_minus = output.sm;
    catch
        SlowModes = 0;
        s_plus  = 0;
        s_minus = 0;
    end
    PlotGrid(Lap_z_plus, Lap_z_minus, k2_poisson, Fullscreen, SlowModes, SavePlot, PlotDirectory, XG, YG, ZG, LX, LZ, dy, t, KX, s_plus, s_minus)
    if SavePlot == 1
        saveas(gcf, [PlotDirectory num2str(t) '.jpg'])
    end
    
else
    disp(['    ERROR:   Invalid Plot Type'])
end
end

function EnergyPlot(Ezp, Ezm, time, TSlice, SlowModes, Esp, Esm)

if SlowModes == 1
    subplot(1,2,1)
    plot(time, Ezp, time, Ezm)
    title('\zeta^{\pm} "Energy"')
    legend('\zeta^+', '\zeta^-', 'Location', 'Best')
    xlabel('Time')

    axis([0 TSlice 0 1.1*max([Ezp Ezm])])
    
    subplot(1,2,2)
    plot(time, Esp, time, Esm)
    title('z^{\pm} "Energy"')
    legend('z^+', 'z^-', 'Location', 'Best')
    xlabel('Time')
    axis([0 TSlice 0 1.1*max([Esp Esm])])
else
    plot(time, Ezp, time, Ezm)
    title('\zeta^{\pm} "Energy"')
    legend('\zeta^+', '\zeta^-', 'Location', 'Best')
    xlabel('Time')
    axis([0 TSlice 0 1.1*max([Ezp Ezm])])
end

end

function PlotGrid(Lap_z_plus, Lap_z_minus, k2_poisson, Fullscreen, SlowModes, SavePlot, PlotDirectory, XG, YG, ZG, LX, LZ, dy, t, KX, s_plus, s_minus)

%Go back to real space for plotting
zp  = double(permute(real(ifftn(KX.*Lap_z_plus./k2_poisson)),[2,1,3]));
zm  = double(permute(real(ifftn(KX.*Lap_z_minus./k2_poisson)),[2,1,3]));

zp = 0.5*(zp + zm);
if SlowModes == 1
    sp     = double(permute(real(ifftn(s_plus)),[2,1,3]));
    sm     = double(permute(real(ifftn(s_minus)),[2,1,3]));
end
figure(1)
if Fullscreen == 1
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96])        % Makes figure fullscreen
end
clf
% if SlowModes == 1
%     subplot(2,2,1)
% else
%     subplot(1,2,1)
% end
hold on
hx = slice(XG, YG, ZG, zp, LX, [], []);
set(hx,'FaceColor','interp','EdgeColor','none')
hy = slice(XG, YG, ZG, zp, [], dy, []);
set(hy,'FaceColor','interp','EdgeColor','none')
hz = slice(XG, YG, ZG, zp, [], [], LZ);
set(hz,'FaceColor','interp','EdgeColor','none')
hold off
daspect([1,1,1])
axis tight
box on
view(42,16)
camproj perspective
set(gcf,'Renderer','zbuffer')
title([num2str(t,'%f') '  \zeta^+'])
xlabel('x')
ylabel('y')
zlabel('z')
colorbar

% if SlowModes == 1
%     subplot(2,2,2)
% else
%     subplot(1,2,2)
% end
% hold on
% hx = slice(XG, YG, ZG, zm, LX, [], []);
% set(hx,'FaceColor','interp','EdgeColor','none')
% hy = slice(XG, YG, ZG, zm, [], dy, []);
% set(hy,'FaceColor','interp','EdgeColor','none')
% hz = slice(XG, YG, ZG, zm, [], [], LZ);
% set(hz,'FaceColor','interp','EdgeColor','none')
% hold off
% daspect([1,1,1])
% axis tight
% box on
% view(42,16)
% camproj perspective
% set(gcf,'Renderer','zbuffer')
% title('\zeta^-')
% xlabel('x')
% ylabel('y')
% zlabel('z')
% colorbar
% 
% if SlowModes == 1
%     subplot(2,2,3)
%     hold on
%     hx = slice(XG, YG, ZG, sp, LX, [], []);
%     set(hx,'FaceColor','interp','EdgeColor','none')
%     hy = slice(XG, YG, ZG, sp, [], dy, []);
%     set(hy,'FaceColor','interp','EdgeColor','none')
%     hz = slice(XG, YG, ZG, sp, [], [], LZ);
%     set(hz,'FaceColor','interp','EdgeColor','none')
%     hold off
%     
%     daspect([1,1,1])
%     axis tight
%     box on
%     view(42,16)
%     camproj perspective
%     set(gcf,'Renderer','zbuffer')
%     title('z^+')
%     xlabel('x')
%     ylabel('y')
%     zlabel('z')
%     colorbar
%     
%     subplot(2,2,4)
%     hold on
%     hx = slice(XG, YG, ZG, sm, LX, [], []);
%     set(hx,'FaceColor','interp','EdgeColor','none')
%     hy = slice(XG, YG, ZG, sm, [], dy, []);
%     set(hy,'FaceColor','interp','EdgeColor','none')
%     hz = slice(XG, YG, ZG, sm, [], [], LZ);
%     set(hz,'FaceColor','interp','EdgeColor','none')
%     hold off
%     
%     daspect([1,1,1])
%     axis tight
%     box on
%     view(42,16)
%     camproj perspective
%     set(gcf,'Renderer','zbuffer')
%     title('z^-')
%     xlabel('x')
%     ylabel('y')
%     zlabel('z')
%     colorbar
% end
% drawnow

if SavePlot == 1
    saveas(gcf, [PlotDirectory num2str(t) '.jpg'])
end
end
