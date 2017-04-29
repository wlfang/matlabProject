function decodedMess = jsteg(covername, messagename)

    % read image from path name
    cover = imread(covername);

    % get the size of the image
    sz = size(cover);
    rows = sz(1,1);               
    cols = sz(1,2);
    colors = max(max(cover));  

    % convert the message into character array
    message = char(messagename);
    messagelength = length(message);

    % show the original image;
    global flag;
    imshow(cover); 
    title('Original Image (Cover Image)');

    % convert to uint8
    message = uint8(message);

    coverzero = cover;

    quant_multiple = 1;    

    blocksize = 8; 

    % the standard quantization matrix
    DCT_quantizer = ...    
        [ 16  11  10  16  24  40  51  61; ...
          12  12  14  19  26  58  60  55; ...
          14  13  16  24  40  57  69  56; ...
          14  17  22  29  51  87  80  62; ...
          18  22  37  56  68 109 103  77; ...
          24  35  55  64  81 104 113  92; ...
          49  64  78  87 103 121 120 101; ...
          72  92  95  98 112 100 103  99 ];

    % if the column and row size is not multiple of 8, duplicate the last col
    % or row
    pad_cols = (1 - (cols / blocksize - floor(cols / blocksize))) * blocksize;
    if pad_cols == blocksize, pad_cols = 0; end
    pad_rows = (1 - (rows / blocksize - floor(rows / blocksize))) * blocksize;
    if pad_rows == blocksize, pad_rows = 0; end


    for extra_cols = 1:pad_cols
      coverzero(1:rows, cols+extra_cols) = coverzero(1:rows, cols);
    end

    cols = cols + pad_cols;    % coverzero is now pad_cols wider

    for extra_rows = 1:pad_rows
      coverzero(rows+extra_rows, 1:cols) = coverzero(rows, 1:cols);
    end

    rows = rows + pad_rows;    % coverzero is now pad_rows taller

    % DCT transformation
    for row = 1: blocksize: rows
      for col = 1: blocksize: cols
          DCT_matrix = coverzero(row: row + blocksize - 1, col: col + blocksize - 1);
          DCT_matrix = dct2(DCT_matrix);

          % quantize it (levels stored in DCT_quantizer matrix):
          DCT_matrix = round(DCT_matrix ...
              ./ (DCT_quantizer(1:blocksize, 1:blocksize) * quant_multiple));
          % place it into the compressed-image matrix:
          jpeg_img(row: row + blocksize-1, col: col + blocksize-1) = DCT_matrix;
      end
    end

    % show the image about coefficient distribution after DCT;
    while (flag == 0)
        pause(0.5);
    end
    flag = 0;
    hist(jpeg_img);
    title('Coefficient distribution after DCT');
    % show the image after DCT;
    while (flag == 0)
        pause(0.5);
    end
    flag = 0;
    imshow(jpeg_img);
    title('DCT');
    bitlength = 1;

    for i = 1 : messagelength
        for imbed = 1 : 8
            messageshift = bitshift(message(i), 8-imbed); % message(i) shift to the left by 8-imbed bits

            showmess = uint8(messageshift);
            showmess = bitshift(showmess, -7);

            messagebit(bitlength) = showmess;
            bitlength = bitlength + 1;
        end
    end

    % imbed the message into the image
    i = 1;

    for row = 1 : rows
        for col = 1 : cols
           x = jpeg_img(row, col);
           if (x ~= 0) && (x ~= 1)
               r = mod(x, 2);
               if r == 0 
                   if messagebit(i) == 1
                       x = x + 1;
                   end
               else
                   if messagebit(i) == 0
                       x = x - 1;
                   end
               end
               i = i + 1;
           end
        jpeg_img(row,col) = x;

        if i == bitlength
            break;
        end
        end

        if i == bitlength
            break;
        end
    end

    % show the image of Coefficient distribution after embedding message;
    while (flag == 0)
        pause(0.5);
    end
    flag = 0;
    hist(jpeg_img);
    title('Coefficient distribution after embedding message');

    % Reconstructing image
    recon_img = coverzero - coverzero;  % zero the matrix for the reconstructed image

    % Perform inverse DCT
    for row = 1: blocksize: rows
      for col = 1: blocksize: cols
          IDCT_matrix = jpeg_img(row: row + blocksize-1, col: col + blocksize-1);
          IDCT_matrix = round(idct2(IDCT_matrix .* (DCT_quantizer(1:blocksize, 1:blocksize) * quant_multiple)));
          recon_img(row: row + blocksize-1, col: col + blocksize-1) = IDCT_matrix;
      end
    end

    % Clip off padded rows and columns
    rows = rows - pad_rows;
    cols = cols - pad_cols;
    recon_img = recon_img(1:rows, 1:cols);

    % show the reconstructing image;
    while (flag == 0)
        pause(0.5);
    end
    flag = 0;
    imshow(recon_img);
    title('Reconstructing Image');

    % if the column and row size is not multiple of 8, duplicate the last col
    % or row
    pad_cols = (1 - (cols/blocksize - floor(cols/blocksize))) * blocksize;
    if pad_cols == blocksize, pad_cols = 0; end
    pad_rows = (1 - (rows/blocksize - floor(rows/blocksize))) * blocksize;
    if pad_rows == blocksize, pad_rows = 0; end

    for extra_cols = 1:pad_cols
      recon_img(1:rows, cols+extra_cols) = recon_img(1:rows, cols);
    end

    cols = cols + pad_cols;    % coverzero is now pad_cols wider

    for extra_rows = 1:pad_rows
      recon_img(rows+extra_rows, 1:cols) = recon_img(rows, 1:cols);
    end

    rows = rows + pad_rows;    % coverzero is now pad_rows taller

    jpeg_img=jpeg_img-jpeg_img;

    for row = 1: blocksize: rows
      for col = 1: blocksize: cols

          DCT_matrix = recon_img(row: row + blocksize-1, col: col + blocksize-1);
          DCT_matrix = dct2(DCT_matrix);

          % quantize it (levels stored in DCT_quantizer matrix):
          DCT_matrix = round (DCT_matrix ...
              ./ (DCT_quantizer(1:blocksize, 1:blocksize) * quant_multiple));
          % place it into the compressed-image matrix:
          jpeg_img(row: row + blocksize-1, col: col + blocksize-1) = DCT_matrix;
      end
    end

    stego = jpeg_img;
    stegoindex = 1;
    imbed = 1;
    messagechar = 0;
    messageindex = 1;

    % extract the message from the image
    for row = 1:rows
        for col = 1:cols
            stegomessage = stego(row,col);
            if (stegomessage ~= 0) && (stegomessage ~= 1)
                r = mod(stegomessage, 2);
                if (r == 0)
                    showmess = 0;
                else
                    showmess = 1;
                end

                showmess = uint8(showmess);  
                showmess = bitshift(showmess, (imbed - 1));
                messagechar = uint8(messagechar + showmess);

                stegoindex = stegoindex + 1;
                imbed = imbed + 1;
                if (imbed == 9) 
                    messagestring(messageindex) = messagechar;
                    messageindex = messageindex + 1;
                    messagechar = 0;
                    imbed = 1;
                end
            end
            if (stegoindex == messagelength * 8 + 8)
                break;
            end
        end
        if (stegoindex == messagelength * 8 + 8)
            break;
        end
    end
    decodedMess = messagestring;
end
