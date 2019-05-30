function [event, eventcolor, time, image] = read_current_image(obj)

if obj.imStep < obj.imLength && obj.imStep >= 1
	
	img_filename = obj.imgList{obj.imStep + obj.imInit - 1};
	image = imread(img_filename);
	time = obj.timeList(obj.imStep + obj.imInit - 1);
	
	idx_f = obj.imStep;
	idx_b = find(obj.event(idx_f:end,1) <= time, 1, 'last');
	
	event = obj.event(idx_f:idx_b, :);
	eventcolor = zeros([obj.imSize 3]);
	
	for i = 1:size(event,1)
		if event(i,4) == 1
			eventcolor(event(i,3)+1,event(i,2)+1,3) = min(eventcolor(event(i,3)+1,event(i,2)+1,3)+1,1);
			eventcolor(event(i,3)+1,event(i,2)+1,1) = max(eventcolor(event(i,3)+1,event(i,2)+1,1)-1,0);
		else
			eventcolor(event(i,3)+1,event(i,2)+1,1) = min(eventcolor(event(i,3)+1,event(i,2)+1,1)+1,1);
			eventcolor(event(i,3)+1,event(i,2)+1,3) = max(eventcolor(event(i,3)+1,event(i,2)+1,3)-1,0);
		end
	end
	
	obj.image = image;
	obj.undistortedImage = cv.undistort(obj.image, obj.K, obj.distCoeffs);
	obj.imStep = obj.imStep + 1;
	obj.eventStep = obj.eventStep + size(event,1);
else
	error('reach the end of file');
end

if obj.imStep == obj.imLength
	obj.eof = true;
end

end