function extract = LSB_embed(name, message, lsb, color)
% LSBembed(name, message, lsb)  LSB in steganography (embed)
% name: the picture's path and name
% message: the data you want to hide in the picture
% lsb: lsb-rightmost LSBs
% color: 1-red, 2-green, 3-blue

    % read the image from path name
    image = imread(name);
    
    % show the original image
    imshow(image);
    title('Original Image');
    global flag;
    while (flag == 0)
        pause(0.5);
    end
    flag = 0;
    
    % conver the message into character vector
    message = char(message);
    message = uint8(message);
    msg_origin = unicode2native(strcat(message, char(4)), 'UTF-8');  % UTF-8 encode, 'EOT' is the end tag
    msg_bin = dec2bin(msg_origin, 8);  % convert to binary
    msg = strjoin(cellstr(msg_bin)','');

    len = length(msg) / lsb;
    while len ~= fix(len)
        strcat(msg, char(4));
        len = length(msg) / lsb;
    end
    tmp = blanks(len);
    for i = 1 : len
        tmp(i) = char(bin2dec(msg((i - 1) * lsb + 1 : i * lsb)) + '0');  % '0' is a kind of placeholder
    end

    % use Red, Green or Blue
    layer = image(:, :, color);
    for i = 1 : len
        layer(i) = layer(i) - mod(layer(i), 2^lsb) + double(tmp(i) - '0');  % only to be consistent with front
    end

    % save the picture
    image_result = image;
    image_result(:, :, color) = layer;
    
    % show the result image
    imshow(image_result);
    title('Result Image');
    while (flag == 0)
        pause(1);
    end
    flag = 0;
    
    imwrite(image_result, 'result.png');  % jpg would lose some information
    
    % call the LSB_extract and return the extracted message
    extract = LSB_extract('result.png',1,1);
    disp(extract);
end