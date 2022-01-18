function fill_color(x, u, v, color)
    fill([x; flip(x)], [u; flip(v)], color);
end
