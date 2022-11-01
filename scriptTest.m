clc; close all; clear;

simulation = Simulation();
simulation.patchElements();
normal = simulation.elements(end).normal;


