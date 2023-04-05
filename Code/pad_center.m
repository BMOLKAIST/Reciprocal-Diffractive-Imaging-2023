function output = pad_center(input, output_size)

    input_size = size(input);
    output = zeros(output_size);
    output(...
    ceil(end/2 - input_size(1)/2 + 1:end/2 + input_size(1)/2),...
    ceil(end/2 - input_size(2)/2 + 1:end/2 + input_size(2)/2)) = input;
    
end
