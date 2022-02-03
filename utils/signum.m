function y = signum(x)
    y = sign(x);
    y(y == 0) = (rand(1) > 0.5)*2 - 1;
end
