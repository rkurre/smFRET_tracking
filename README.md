# Tracking of smFRET data based TIRF microscopy of diffusing receptors in live cells
A Matlab script to track smFRET data obtained by the Matlab software FRET_efficiency_analysis published by Winkelmann et al. (https://doi.org/10.1038/s41467-024-49876-9). FRET efficiency analysis is a batch script to analyze multiple datasets (individual cells). It generates a table of pooled FRET efficiency and stoichiometry data for single-molecule FRET events including there localizations and time-points. This data is used here to generate trajectories based on nearest-neighbor tracking including gap closing. User needs to define the following parameters

## System Requirements (tested environment)
- Operating System: Microsoft Windows 11 Home Version 23H2 (Build 22631.3527)
- Tested MATLAB Version: 9.13.0.2698988 (R2022b) Update 10

## Containing files
- trackPooledEMapsWithGapClosure.m: Main script containing nearest-neighbor tracking and gap closing,
- plotEandSvst.m: Script to plot FRET efficiencies and stoichiometries versus time.

## Installation guide
- Install Matlab and required toolboxes (installation time < 1 h),
- extract ZIP-file 'SPT_Simulator.zip'.

## Instructions to run
1. Start Matlab 2022b,
2. In Matlab browser, navigate to software directory (\...\smFRET_tracking\),
4. Open 'trackPooledEMapsWithGapClosure.m' in Matlab, set parameters to your needs and run. After starting the script, user need to load txt file containing pooled E-S table and define folder to save results.  
5. Open 'plotEandSvst.m' in Matlab, set parameters to your needs and run.

Expected run time with default parameters less than 1 minute, using a computer with AMD Ryzen 7 4700U or similar.

## Input parameters
- D: rough estimate of the 2D diffusion constant of the molecules to track.
- dt: Temporal resolution of input data.
- nFrGapClosure: Maximum number of frames to consider for gap closing.
- pxlSz: Pixel size of raw data.
- nPxlX: Horizontal resolution of input images in pixels.
- nPxlY: Vertical resolution of input images in pixels.
- trLenForPlot: Minimal track length for final plotting of trajectories

## Main outputs:
- particleTracks: Structure array with all tracks without considering gap closing. Each field (row) is a full track with 12 entries (columns): cell #, track id, time [s], x [µm], y [µm], FRET efficiency E_raw, FRET efficiency EPR, corrected FRET efficiency E, stoichiometry S_raw, stoichiometry SPR, gamma corrected stoichiometry S_gamma, gamma and beta corrected stoichiometry S_gammabeta
- particleTracksGapClosure: Same structure array as particleTracks, but considering gap closure to assemble final tracks 
- Figure showing all trajectories above user defined track length threshold.
- mat file containg all variables.

## Author
Rainer Kurre, PhD 

Email: rainer.kurre@uos.de

Center for Cellular Nanoanalytics and Division of Biophysics

Osnabrueck University, Barabastr. 11, D-49076 Osnabrück
%Center for Cellular Nanoanalytics and Division of Biophysics
%Osnabrueck University, Barabastr. 11, D-49076 Osnabrück
