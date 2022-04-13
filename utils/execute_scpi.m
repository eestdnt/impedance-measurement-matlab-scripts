function execute_scpi(device_name, filename)
%   EXECUTE_SCPI reads SCPI commands from file and sends to given device
%       execute_scpi(device_name, filename) reads commands from <filename> and then sends to <device_name>

    % Establish RS232 connection
    s = serialport(device_name, 9600);

    % Read SCPI commands line-by-line
    fid = fopen(filename);
    line = fgetl(fid);
    while ischar(line)
        if contains(line, "?")
            fprintf("Send query: %s\n", line);
            writeline(s, line);
            r = readline(s);
            fprintf(" --> Response: %s\n", r);
        else
            fprintf("Send command: %s\n", line);
            writeline(s, line);
        end
        line = fgetl(fid);
    end
    fclose(fid);
end