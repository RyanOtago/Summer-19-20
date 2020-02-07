function PostPlot()

% Needs 0.mat and *.mat files of runs you want to plot

SinglePlot    = 1;
Fullscreen    = 1;
SavePlot      = 0;
PlotDirectory = './';

Directory = './Turbulence/';
Folder    = '2020-02-03 16-13-18/';

filename = @(n) [Directory Folder sprintf('%u',n) '.mat'];

if SinglePlot == 1
    Number = 55;         % Chooose single file you want to plot figures for
end

%% Loading Parameters from 0.mat
Init0 = load(filename(0));
input = Init0.input;

VariableTimeStep = 0;%input.Parameters.VariableTimeStep;
TF = input.Parameters.TF;

KX = input.KX; KY = input.KY; KZ = input.KZ;
NX = input.Parameters.NX; NY = input.Parameters.NY; NZ = input.Parameters.NZ; 
LX = input.Parameters.LX; LY = input.Parameters.LY; LZ = input.Parameters.LZ; 

dx = LX/NX; dy = LY/NY; dz = LZ/NZ;

k2_perp = KX.^2 + KY.^2;      % (Perpendicular) Laplacian in Fourier space
k2_poisson = k2_perp; k2_poisson(1,1,:) = 1;        

[i,j,k] = ndgrid((1:NX)*dx,(1:NY)*dy,(1:NZ)*dz);
XG = permute(i, [2 1 3]); YG = permute(j, [2 1 3]); ZG = permute(k, [2 1 3]);

%% Loading Data from n.mat
Init1 = load(filename(Number));
output = Init1.output;

t = output.time;
Lap_z_plus  = output.Lzp;
Lap_z_minus = output.Lzm;
E_z_plus    = output.Ezp;
E_z_minus   = output.Ezm;

try
    s_plus    = output.sp;
    s_minus   = output.sm;
    E_s_plus  = output.Esp;
    E_s_minus = output.Esm;
catch
    SlowModes = 0;
    s_plus    = 0;
    s_minus   = 0;
    E_s_plus  = 0;
    E_s_minus = 0;
end

figure(1)
% EnergyPlot(t, E_z_plus, E_z_minus, E_s_plus, E_s_minus, SlowModes, TF, VariableTimeStep)
PlotGrid(Lap_z_plus, Lap_z_minus, k2_poisson, Fullscreen, SlowModes, SavePlot, PlotDirectory, XG, YG, ZG, LX, LZ, dy, t, SlowModes, s_plus, s_minus)


end

function PlotGrid(Lap_z_plus, Lap_z_minus, k2_poisson, Fullscreen, SlowModes, SavePlot, PlotDirectory, XG, YG, ZG, LX, LZ, dy, t, varargin)

        %Go back to real space for plotting
        zp  = double(permute(real(ifftn(Lap_z_plus./k2_poisson)),[2,1,3]));
        zm  = double(permute(real(ifftn(Lap_z_minus./k2_poisson)),[2,1,3]));
        if SlowModes == 1
            sp     = double(permute(real(ifftn(s_plus)),[2,1,3]));
            sm     = double(permute(real(ifftn(s_minus)),[2,1,3]));
        end
        figure(1)
        if Fullscreen == 1
            set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96])        % Makes figure fullscreen
        end
        if SlowModes == 1
            subplot(2,2,1)
        else
            subplot(1,2,1)
        end
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
        
        if SlowModes == 1
            subplot(2,2,2)
        else
            subplot(1,2,2)
        end
        hold on
        hx = slice(XG, YG, ZG, zm, LX, [], []);
        set(hx,'FaceColor','interp','EdgeColor','none')
        hy = slice(XG, YG, ZG, zm, [], dy, []);
        set(hy,'FaceColor','interp','EdgeColor','none')
        hz = slice(XG, YG, ZG, zm, [], [], LZ);
        set(hz,'FaceColor','interp','EdgeColor','none')
        hold off
        daspect([1,1,1])
        axis tight
        box on
        view(42,16)
        camproj perspective
        set(gcf,'Renderer','zbuffer')
        title('\zeta^-')
        xlabel('x')
        ylabel('y')
        zlabel('z')
        colorbar
        
        if SlowModes == 1
            subplot(2,2,3)
            hold on
            hx = slice(XG, YG, ZG, sp, LX, [], []);
            set(hx,'FaceColor','interp','EdgeColor','none')
            hy = slice(XG, YG, ZG, sp, [], dy, []);
            set(hy,'FaceColor','interp','EdgeColor','none')
            hz = slice(XG, YG, ZG, sp, [], [], LZ);
            set(hz,'FaceColor','interp','EdgeColor','none')
            hold off
            
            daspect([1,1,1])
            axis tight
            box on
            view(42,16)
            camproj perspective
            set(gcf,'Renderer','zbuffer')
            title('z^+')
            xlabel('x')
            ylabel('y')
            zlabel('z')
            colorbar
            
            subplot(2,2,4)
            hold on
            hx = slice(XG, YG, ZG, sm, LX, [], []);
            set(hx,'FaceColor','interp','EdgeColor','none')
            hy = slice(XG, YG, ZG, sm, [], dy, []);
            set(hy,'FaceColor','interp','EdgeColor','none')
            hz = slice(XG, YG, ZG, sm, [], [], LZ);
            set(hz,'FaceColor','interp','EdgeColor','none')
            hold off
            
            daspect([1,1,1])
            axis tight
            box on
            view(42,16)
            camproj perspective
            set(gcf,'Renderer','zbuffer')
            title('z^-')
            xlabel('x')
            ylabel('y')
            zlabel('z')
            colorbar
        end
        drawnow
        
        if SavePlot == 1
            saveas(gcf, [PlotDirectory num2str(t) '.jpg'])
        end
end

function EnergyPlot(time, E_z_plus, E_z_minus, E_s_plus, E_s_minus, SlowModes, TF, VariableTimeStep)

if VariableTimeStep == 1
    % Cut off trailing zeros from time and energy vectors
    time = time(2:find(time,1,'last'));
    E_z_plus  = E_z_plus(1:length(time));
    E_z_minus = E_z_minus(1:length(time));
    if SlowModes == 1
        E_s_plus  = E_s_plus(1:length(time));
        E_s_minus = E_s_minus(1:length(time));
    end
end
figure(2)
if SlowModes == 1
    subplot(1,2,1)
    plot(time, E_z_plus, time, E_z_minus)
    title('\zeta^{\pm} "Energy"')
    legend('\zeta^+', '\zeta^-', 'Location', 'Best')
    xlabel('Time')
    axis([0 TF 0 1.1*max([E_z_plus E_z_minus])])
    
    subplot(1,2,2)
    plot(time, E_s_plus, time, E_s_minus)
    title('z^{\pm} "Energy"')
    legend('z^+', 'z^-', 'Location', 'Best')
    xlabel('Time')
    axis([0 TF 0 1.1*max([E_s_plus E_s_minus])])
else
%     plot(time, E_z_plus, time, E_z_minus)
plot(E_z_plus)
    title('\zeta^{\pm} "Energy"')
    legend('\zeta^+', '\zeta^-', 'Location', 'Best')
    xlabel('Time')
    axis([0 TF 0.9*min([E_z_plus(1, 0:length(time)) E_z_minus(1, 0:length(time))]) 1.1*max([E_z_plus E_z_minus])])
end

end