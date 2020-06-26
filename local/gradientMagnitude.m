function output = gradientMagnitude(M)
    [h, w] = size(M);
    output = zeros(h, w);
    for i = 1: h
        for j = 1: w
            if i == 1 && j == 1 
                g_x = (2 * M(i + 1, j) + M(i + 1, j + 1) * 2) - (M(i + 1, j + 1) * 2 + 2 * M(i + 1, j));
                g_y = (M(i + 1, j + 1) * 2 + 2 * M(i, j + 1)) - (M(i + 1, j + 1) * 2 + 2 * M(i, j + 1));
            elseif i == 1 && j == w
                g_x = (2 * M(i + 1, j) + M(i + 1, j - 1) * 2) - (M(i + 1, j - 1) * 2 + 2 * M(i + 1, j));
                g_y = (M(i + 1, j - 1) * 2 + 2 * M(i, j - 1)) - (M(i + 1, j - 1) * 2 + 2 * M(i, j - 1));
            elseif i == h && j == 1
                g_x = (2 * M(i - 1, j) + M(i - 1, j + 1) * 2) - (M(i - 1, j + 1) * 2 + 2 * M(i - 1, j));
                g_y = (M(i - 1, j + 1) * 2 + 2 * M(i, j + 1)) - (M(i - 1, j + 1) * 2 + 2 * M(i, j + 1));
            elseif i == h && j == w
                g_x = (2 * M(i - 1, j) + M(i - 1, j - 1) * 2) - (M(i - 1, j - 1) * 2 + 2 * M(i - 1, j));
                g_y = (M(i - 1, j - 1) * 2 + 2 * M(i, j - 1)) - (M(i - 1, j - 1) * 2 + 2 * M(i, j - 1));
            elseif i == 1
                g_x = 0;
                g_y = (M(i + 1, j + 1) * 2 + 2 * M(i, j + 1)) - (M(i + 1, j - 1) * 2 + 2 * M(i, j - 1));
            elseif j == 1
                g_x = (M(i + 1, j + 1) * 2 + 2 * M(i + 1, j)) - (M(i - 1, j + 1) * 2 + 2 * M(i - 1, j));
                g_y = 0;
            elseif i == h
                g_x = 0;
                g_y = (M(i - 1, j + 1) * 2 + 2 * M(i, j + 1)) - (M(i - 1, j - 1) * 2 + 2 * M(i, j - 1));
            elseif j == w
                g_x = (M(i + 1, j - 1) * 2 + 2 * M(i + 1, j)) - (M(i - 1, j - 1) * 2 + 2 * M(i - 1, j));
                g_y = 0;
            else 
                g_x = (M(i + 1, j - 1) + 2 * M(i + 1, j) + M(i + 1, j + 1)) - (M(i - 1, j - 1) + 2 * M(i - 1, j) + M(i - 1, j + 1));
                g_y = (M(i + 1, j + 1) + 2 * M(i, j + 1) + M(i - 1, j + 1)) - (M(i + 1, j - 1) + 2 * M(i, j - 1) + M(i - 1, j - 1));
            end
%             disp(g_y);
            output(i, j) = (double(g_x) ^ 2 + double(g_y) ^ 2) ^ 0.5;
        end
    end
end