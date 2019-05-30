classdef DVS < handle
	properties (Constant)
		version = '2.5'
	end
	properties (SetAccess = private, GetAccess = public)
		local_version
		type
		
		isRectified = true
		
		identifier
		BaseDir
		imgDir
		eventDir
		
		event
		timeList
		imgList
		
		image
		undistortedImage
		
		imInit
		imLength
		eventLength
		
		imSize
		K
		distCoeffs
		
		pos_vicon
		time_vicon
		
		% iteration
		eventStep
		imStep
		
		% bool
		eof
	end
	methods (Access = public)
		% CONSTRUCTOR
		function obj = DVS(varargin)
			
			obj.local_version = DVS.version;
			obj.type = 'dvs';
			obj.imStep = 1;
			obj.eventStep = 1;
			obj.eof = false;
			
			% Default values
			obj.identifier = 'untitled';
			obj.imInit = 1;
			obj.imLength = inf;
			
			for i = 1:length(varargin)
				switch i
					case 1
						obj.BaseDir = varargin{1};
					case 2
						if ~isempty(varargin{2})
							obj.imInit = varargin{2};
						end
					case 3
						if ~isempty(varargin{3})
							obj.imLength = varargin{3};
						end
				end
			end
		end
		
		[event, eventcolor, time, image] = read_current_image(obj)
		[event, eventcolor] = read_event(obj, dt)
		eof = end_of_file(obj)
		
		% SET function
		obj = read(obj)

	end
end