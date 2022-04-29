% Add subdirectories to MATLAB paths
addpath("./utils");
addpath("./daq");
addpath("./analysis");
addpath("./simulation");
addpath("./scpi");
addpath("./aging-experiments");

if ~exist("./aging-experiments/files", "dir")
    mkdir("./aging-experiments/files");
end
