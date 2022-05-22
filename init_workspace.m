% Add subdirectories to MATLAB paths
addpath("./utils");
addpath("./daq");
addpath("./analysis");
addpath("./simulation");
addpath("./scpi");
addpath("./aging-experiments");

if ~isfolder("./aging-experiments/files")
    mkdir("./aging-experiments/files");
end
