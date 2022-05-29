% Add subdirectories to MATLAB paths
addpath("./utils");
addpath("./daq");
addpath("./analysis");
addpath("./simulation");
addpath("./battery");
addpath("./aging-experiments");
addpath("./supercap");

if ~isfolder("./files")
    mkdir("./files");
end

if ~isfolder("./aging-experiments/files")
    mkdir("./aging-experiments/files");
end

if ~isfolder("./scripts")
    mkdir("./scripts");
end