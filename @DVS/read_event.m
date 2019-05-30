function [event, eventcolor] = read_event(obj, dt)

if obj.eventStep < obj.eventLength
	
	idx_f = obj.eventStep;
	if nargin == 2
		if dt < 1 % time (second)
	 		idx_b = find(obj.event(idx_f:end,1) <= obj.event(idx_f,1)+dt, 1, 'last');
		elseif dt >= 1 % striking epoch
			idx_b = dt-1;
		end
		idx_b = idx_f + idx_b;
	else % nargin == 1 => one event
		idx_b = idx_f;
	end
	
	if idx_b > length(obj.event)
		event = obj.event(idx_f:end, :);
	else
		event = obj.event(idx_f:idx_b, :);
	end
	
	if nargout == 2
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
	end
	
	obj.eventStep = obj.eventStep + size(event,1);
	
	if obj.eventStep > obj.eventLength
		obj.eof = true;
		event = [];
		return;
	end
	
	img_idx = find(obj.event(obj.eventStep,1) >= obj.timeList, 1, 'last');
	if isempty(img_idx)
		obj.imStep = 0;
	else
		prev_imStep = obj.imStep;
		obj.imStep = img_idx;
		if obj.imStep > prev_imStep
			obj.image = imread(obj.imgList{obj.imStep});
			if size(obj.image,3) == 3
				obj.image = rgb2gray(obj.image);
			end
			obj.undistortedImage = cv.undistort(obj.image, obj.K, obj.distCoeffs);
		end
	end
	
else
	warning('reach the end of file');
	obj.eof = true;
	event = [];
end

if obj.eventStep == obj.eventLength
	obj.eof = true;
	event = [];
end

end