function [msg_origin] = LSB_extract(name, lsb, color)
% LSB_extract(name, lsb)  LSB in steganography (extract)
% name: the picture's path and name
% lsb: lsb-rightmost LSBs
% color: 1-red, 2-green, 3-blue

    % read the image
    image = imread(name);

    layer = image(:, :, color);
    tmp = blanks(0);
    n = prod(size(layer));

    % extract the message
    for i = 1 : n * lsb / 8
        tmp((i - 1) * (8/lsb) + 1 : i * (8/lsb)) = mod(layer((i - 1) * (8/lsb) + 1 : i * (8/lsb)), 2^lsb); 
        msg((i - 1) * 8 + 1 : i * 8) = dec2bin(tmp((i - 1) * (8/lsb) + 1 : i * (8/lsb)), lsb)';
        msg_origin(i) = bin2dec(msg((i - 1) * 8 + 1 : i * 8));
        if msg_origin(i) == 4  % EOT is the end tag
            break;
        end
    end

    msg_origin = native2unicode(msg_origin,'UTF-8');
    
    % return the value
    msg_origin = msg_origin(1:end-1);

end