
% Run script as:
% matlab -r "cropimage imagefile output_file"
% or from matlab command console: 
% cropimage(imagefile, output_file)

% Turns image into an array of 1 bit pixels after cropping. Targetted
% towards writing letters and numbers;
function [] = cropimage(imgfile, rectangles_file, output_file)

    [pic] = imread(imgfile);
    % crop image
    IMG_WIDTH = 31;
    IMG_HEIGHT = 31;
    PIXEL_CUTOFF = 20;
    
    crop_rect = tblread(rectangles_file);
    [num_letters, ~] = size(crop_rect);
    
    img_pixels = zeros(IMG_HEIGHT*num_letters,IMG_WIDTH) + PIXEL_CUTOFF;
  
    % Use rectangles provided to crop parts of image into 
    % letters and store them in a  height by num_letter*width matrix
    for i=1:num_letters
        rect = ceil(crop_rect(i,:));
        top_img = (i-1)*IMG_HEIGHT;
        I = imcrop(pic, rect);
        s = size(I);
        width = s(2);
        height = s(1);
        img_pixels(top_img+1:height + top_img, 1:width) = I(:,:,1);
    end

    
    % turn into 0 if black, 1 otherwise. Using only one color of RGB 
    % will suffice
    % img_pixels = imresize(img_pixels < PIXEL_CUTOFF - 1, .64);
    img_pixels = img_pixels < PIXEL_CUTOFF - 1;
    
    file_name = strcat(output_file, '.coe');

    % Write coe file for verilog ram
    file = fopen(file_name,'w');

    %write the header info
    fprintf(file,'memory_initialization_radix=2;\n');
    fprintf(file,'memory_initialization_vector=\n');
    fclose(file);

    output = img_pixels(:,1:end-2);

    %append the numeric values to the file
    dlmwrite(file_name,output,'-append','delimiter','', 'newline', 'pc');

end