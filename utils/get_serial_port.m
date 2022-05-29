function portname = get_serial_port()
    ser_list = serialportlist();
    if length(ser_list) < 1
        portname = "";
        return;
    end
    portname = ser_list(1);
end