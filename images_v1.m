function images(current_pic, previous_pic, mcframe, mcfd, suffix)

    global fig_no;

	[rows, cols, ~] = size(double(previous_pic));


   
    fig_no = fig_no + 1;
    figure(fig_no);
    image((1 : cols), (1 : rows), previous_pic);
    title(['Previous picture for ' suffix]);
    axis image;
    colormap(gray(256));
   
    fig_no = fig_no + 1;
    figure(fig_no);
    image((1 : cols), (1 : rows), mcfd + 128);
    axis image;
    colormap(gray(256));        
    hold on;
    title(['Displaced Frame Difference for ' suffix]);

    fig_no = fig_no + 1;
    figure(fig_no);
    image((1 : cols), (1 : rows), double(current_pic) - double(previous_pic) + 128);
    axis image;
    colormap(gray(256));        
    hold on;
    title(['Non Motion Compensated Frame Difference for ' suffix]);

    fig_no = fig_no + 1;
    figure(fig_no);
    image((1 : cols), (1 : rows), mcframe);
    axis image;
    colormap(gray(256));        
    hold on;
    title(['Motion Compensated Previous Frame for ' suffix]);

end
