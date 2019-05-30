function pkg = advancedReadDVSdataset(string)

token = strsplit(string, {'\', '/'});

if isempty(token{end})
	token = token(1:end-1);
else
	string = [string '\'];
end

new_string = [token{end-1} '-' token{end}];
bRead = true;

if exist([new_string '.mat'], 'file')
	fprintf('Load dataset ...\n');
	S = load(new_string);
	pkg = S.pkg;
	
	try
		if isempty(pkg.local_version) || str2double(pkg.local_version) < str2double(DVS.version)
			bRead = true;
		else
			bRead = false;
		end
	catch
		bRead = true;
	end
end

if bRead
	fprintf('Read dataset ...\n');
	pkg = DVS(string);
	read(pkg);
	
	fprintf('Save dataset as mat ...\n');
	save(new_string, 'pkg');
end

end