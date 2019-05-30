pkg = advancedReadDVSdataset('F:\Datasets\DVS\shapes_translation\');

events = pkg.read_event(0.01); % 0.01 seconds
events = pkg.read_event(10); % 10 events