function obj = read(obj)

BaseDir = obj.BaseDir;
imgDir = [ BaseDir 'images/' ];
eventDir = [ BaseDir 'events.txt' ];
yamlDir = [ BaseDir 'camera.yaml' ];

YAML = yamlread(yamlDir);
if ismember('intrinsic', fieldnames(YAML))
	K = YAML.intrinsic;
else
	K = [YAML.Camera.fx 0 YAML.Camera.cx;
		0 YAML.Camera.fy YAML.Camera.cy;
		0 0 1];
end

if ismember('k1', fieldnames(YAML.Camera))
	obj.distCoeffs(1) = YAML.Camera.k1;
end
if ismember('k2', fieldnames(YAML.Camera))
	obj.distCoeffs(2) = YAML.Camera.k2;
end
if ismember('p1', fieldnames(YAML.Camera))
	obj.distCoeffs(3) = YAML.Camera.p1;
end
if ismember('p2', fieldnames(YAML.Camera))
	obj.distCoeffs(4) = YAML.Camera.p2;
end
if ismember('k3', fieldnames(YAML.Camera))
	obj.distCoeffs(5) = YAML.Camera.k3;
end

imSize = [YAML.Camera.height, YAML.Camera.width];

%% Load rgb data
if exist([BaseDir 'images.txt'], 'file')
	rgb = readtable([BaseDir 'images.txt'], 'Delimiter', ' ', 'ReadVariableNames', false);
	List = table2cell(rgb);
	timeList = cell2mat(List(:,1));
	imgList = cellfun(@(x)[BaseDir x], List(:,2), 'un', 0);
	
	imInit = max(1, obj.imInit);
	imLength = min(obj.imInit+obj.imLength-1, length(timeList))-obj.imInit+1;
	image = zeros(imSize);
else
	timeList = [];
	imgList = [];
	imInit = 1;
	imLength = inf;
	image = zeros(imSize);
end

%% Load event data
event = readtable([BaseDir 'events.txt'], 'Delimiter', ' \t', 'ReadVariableNames', false);
event = table2array(event);

eventLength = size(event,1);

%% Load ground-truth data
fVICON = fopen([BaseDir 'groundtruth.txt']);

%
if fVICON > 0
	C = textscan(fVICON, '%f %f %f %f %f %f %f %f');
	vicon = [C{:}].';
	time_vicon = vicon(1,:);
	vicon = vicon(2:end,:);
	
	R = convert_q2r(vicon([7 4 5 6],1));
	t = vicon([1 2 3],1);
	Tbase = [R t; 0 0 0 1];
	
	% world-to-cam
	for i = 1:size(vicon,2)
		abs_tform = zeros(4,4);
		abs_tform(1:3,1:3) = convert_q2r(vicon([7 4 5 6],i));
		abs_tform(1:3,4) = vicon([1 2 3],i)';
		abs_tform(4,4) = 1;
		
		worldToCam = Tbase \ abs_tform;
		vicon(1:3,i) = worldToCam(1:3,4)';
		vicon(4:7,i) = quatmultiply(convert_r2q(worldToCam(1:3,1:3))', convert_r2q(eye(4))');
	end
	
	obj.time_vicon = time_vicon;
	obj.pos_vicon = vicon;
end

%% 
token = strsplit(BaseDir, {'\', '/'});
obj.identifier = token{end-1};

%%
obj.image = image;
obj.imgDir = imgDir;
obj.imSize = imSize;
obj.imInit = imInit;
obj.imLength = imLength;
obj.eventLength = eventLength;
obj.eventDir = eventDir;
obj.K = K;

obj.timeList = timeList;
obj.imgList = imgList;
obj.event = event;

% obj.image = zeros(obj.imSize);
% obj.undistortedImage = zeros(obj.imSize);
			
fprintf('- Directory: [%s]\n', BaseDir);
fprintf('- Step: %d...%d\n', obj.imInit, obj.imInit+obj.imLength-1)