%Matlab script to plot FRET efficiency and stoichiometry versus time 
% of tracked smFRET data obtained by the Matlab script
% trackPooledEMapsWithGapClosure.m
%
%Input parameters
% particleTracksGapClosure: Structure array with all tracks. Each field 
%                           (row) is a full track with 12 entries (columns): 
%                           cell #, track id, time [s], x [µm], y [µm], 
%                           FRET efficiency E_raw, FRET efficiency EPR, 
%                           corrected FRET efficiency E, stoichiometry S_raw, 
%                           stoichiometry SPR, gamma corrected stoichiometry 
%                           S_gamma, gamma and beta corrected stoichiometry 
%                           S_gammabeta.
% minFrames: Only trajectories longer than minFrames are considered for
%           plotting and saving
% pxlSz: Pixel size of raw data.
% nPxlX: Horizontal resolution of input images in pixels.
% nPxlY: Vertical resolution of input images in pixels.
%
% Output Figures show for each trajectory FRET efficiency and stoichiometry
% versus time, trajectory on XY map as well as FRET efficiency
% histogram. Figures are saved as Matlab figure and png image.

% To run the script, the structure array particleTracksGapClosure has to 
% be loaded in the Matlab workspace.  
%
%Date: 01/08/2025
%written by Rainer Kurre (rainer.kurre@uos.de)
%Center for Cellular Nanoanalytics and Division of Biophysics
%Osnabrueck University, Barabastr. 11, D-49076 Osnabrück

%Parameters
minFrames = 20;
nPxlX = 256;
nPxlY = 256;
pxlSz = 0.1; %units of microns


szData = size(particleTracksGapClosure);
nEl = szData(2);
EAll = [];
SAll = [];
cmap = parula(256);
colormap(cmap);

xmax = nPxlX*pxlSz;
ymax = nPxlY*pxlSz;

for i=1:nEl
    cell = particleTracksGapClosure(i).cell;
    id = particleTracksGapClosure(i).id;
    time = particleTracksGapClosure(i).time_s;
    x = particleTracksGapClosure(i).x_um;
    y = particleTracksGapClosure(i).y_um;
    nFrames = length(time);
    if nFrames > minFrames
        E = particleTracksGapClosure(i).E;
        EAll = vertcat(EAll,E);
        S = particleTracksGapClosure(i).Sgammabeta;
        SAll = vertcat(SAll,S);

%         % Create a single figure with 3 subplots (side by side)
%         figure;

        % Adjust figure size (in inches, for better control)
        fig_width = 11;  % Width of the figure (in inches)
        fig_height = 3;  % Height of the figure (in inches)
        set(gcf, 'Units', 'Inches', 'Position', [1, 1, fig_width, fig_height]);

        % Define a common height for all subplots and a width for each
        subplot_height = 0.75; % Height of each subplot (scaled to figure size)
        subplot_width = 0.25; % Width of each subplot (scaled to figure size)

        % Adjust position for the first subplot (FRET efficiency and stoichiometry vs time)
        subplot(1, 3, 1);
        plot(time, E, '-g');
        hold on;
        plot(time, S, '-k');
        hold off;
        xlabel('Time [s]');
        ylabel('Efficiency, Stoichiometry');
        title(['Cell ', int2str(cell), ', Track ID ', int2str(id), ...
            ': FRET vs. time']);
        x_limits = [time(1), time(end)];
        y_limits = [-0.2, 1.2];
        xlim(x_limits);
        ylim(y_limits);
        legend('FRET efficiency', 'Stoichiometry');
        % Adjust position manually (relative to the figure)
        set(gca, 'Position', [0.05, 0.15, subplot_width, subplot_height]);

        % Second subplot: Particle track with color-coded FRET efficiency
        subplot(1, 3, 2);
        E_plot = E;
        E_plot(E < 0) = 0;
        E_plot(E > 1) = 1;
        E_plot_scaled = round(E_plot * (size(cmap, 1) - 1)) + 1;
        lenTr = size(E_plot_scaled, 1);
        for p = 1:lenTr-1
            plot(x, y, '-', 'Color', cmap(E_plot_scaled(p), :), 'LineWidth', 2);
        end
        % Add colorbar
        cbar = colorbar;
        cbar.Label.String = 'FRET Efficiency';
        cbar.Ticks = linspace(0, 1, 5); % Set ticks for the colorbar
        cbar.TickLabels = arrayfun(@(x) sprintf('%.2f', x), ...
            linspace(0, 1, 5), 'UniformOutput', false); % Custom tick labels
        xlabel('X (µm)');
        ylabel('Y (µm)');
        title('Particle Track');
        set(gca, 'YDir', 'reverse');
        axis equal;
        xlim([0 xmax]);
        ylim([0 ymax]);
        % Adjust position manually (relative to the figure)
        set(gca, 'Position', [0.35, 0.15, subplot_width, subplot_height]);

        % Third subplot: FRET efficiency histogram with Gaussian fit
        subplot(1, 3, 3);
        histogram(E, round((max(E) - min(E)) / 0.05), 'Normalization', 'pdf');
        hold on;

        % Fit a Gaussian to the histogram
        pd = fitdist(E, 'Normal');  % Fit a normal (Gaussian) distribution

        % Generate fitted Gaussian data
        x = linspace(-0.2, 1.2, 200);
        y = pdf(pd, x);

        % Plot the Gaussian fit
        plot(x, y, 'r-', 'LineWidth', 2);

        % Add the mean value as text on the figure
        mean_val = pd.mu;  % Mean value from the fit
        % Position and size of the text box (relative to the figure)
        dim = [0.7 0.7 0.25 0.2];  
        annotation('textbox', dim, 'String', sprintf('Mean = %.2f', ...
            mean_val), 'FitBoxToText', 'on', 'FontSize', 10, ...
            'EdgeColor', 'none');

        % Labels and title
        xlabel('FRET Efficiency');
        ylabel('Probability Density');
        x_limits = [-0.2, 1.2];
        xlim(x_limits);
        title('FRET Efficiency Histogram');
        hold off;
        % Adjust position manually (relative to the figure)
        set(gca, 'Position', [0.7, 0.15, subplot_width, subplot_height]);

        % Save the figure as a single figure with three subplots
        savefig([saveDir, '\FRET_E_Track_and_histogram_cell_', ...
            int2str(cell), '_track_ID ', int2str(id), ...
            '_minframes_', int2str(minFrames), '_nFrames_', ...
            int2str(nFrames), '.fig']);
        saveas(gcf, [saveDir, '\FRET_E_Track_and_histogram_cell_',...
            int2str(cell), '_track_ID ', int2str(id), '_minframes_', ...
            int2str(minFrames), '_nFrames_', int2str(nFrames), '.png']);
        close(gcf);
        %break;
    end
end

% Parameters for the histogram
bin_size = 0.05;

% Create the histogram (normalized probability density function)
figure;
h = histogram(EAll, 'BinWidth', bin_size, 'Normalization', 'pdf');
hold on;

% Fit a multimodal Gaussian (using fitgmdist for mixture of Gaussians)
num_components = 2;  % Assuming a 2-component Gaussian mixture model, you can change this
gm = fitgmdist(EAll, num_components);

% Generate the fitted Gaussian distribution curve
x = linspace(-0.2, 1.2, 200);
pdf_fit = pdf(gm, x');

% Plot the fitted Gaussian mixture model
plot(x, pdf_fit, 'r', 'LineWidth', 2);

% Extract results from the fit
means = gm.mu;  % Means of the Gaussian components
std_dev = gm.Sigma;  % Covariances (standard deviations for univariate case)
weights = gm.ComponentProportion;  % Weights of the components

% Prepare the text to display
text_str = 'Gaussian Fit:';
for i = 1:num_components
    text_str = sprintf('%s\nComponent %d: \nMean = %.2f, \nStd = %.2f, \nWeight = %.2f\n', ...
        text_str, i, means(i), std_dev(i), weights(i));
end

% Add the text box in the upper right corner
dim = [0.7 0.7 0.25 0.2];  % Position and size of the text box (relative to the figure)
annotation('textbox', dim, 'String', text_str, 'FitBoxToText', ...
    'on', 'FontSize', 8, 'EdgeColor', 'k');

% Customize plot
title('FRET Histogram and Multimodal Gaussian Fit');
xlabel('FRET Efficiency');
ylabel('Probability Density');
hold off;
x_limits = [-0.2, 1.2]; % Change these values as needed
xlim(x_limits);

savefig([saveDir, '\FRET_E_All_histogram_minframes_', ...
    int2str(minFrames),'.fig']);
saveas(gcf, [saveDir, '\FRET_E_All_histogram_minframes_', ...
    int2str(minFrames),'.png']);
%close(gcf);
