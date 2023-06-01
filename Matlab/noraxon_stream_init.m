%   connect to Noraxon MR3 software and popup a dialog to select desired
%   data
% 
%   returns a config object that can be passed to noraxon_stream_collect()
%
%   usage:
%        stream_config = noraxon_stream_init(server_ip, port)
%
% 

function [stream_config, sel] = noraxon_stream_init(server_ip, port)

a = exist('webread');

if a == 0
    error('webread() missing. (Matlab R2014b+ required.)');
end

if nargin < 2
    port = 9220;
end
if nargin < 1
    server_ip = '127.0.0.1';
end

server_url = strcat('http://',server_ip, ':', num2str(port));
headers_url = strcat(server_url,'/headers');
disable_url = strcat(server_url,'/disable/');
enable_url = strcat(server_url,'/enable/');
stream_config = {};

%load the headers to get the available data
try
data = webread(headers_url, weboptions('ContentType','json'));
catch   
  error(['Could not connect to MR3 stream at ', server_url, '.  Check to be sure HTTP Streaming is enabled and a measurement is currently running.']);  
end

%parse data
if length(data.headers) == 0
   error('No data sources found'); 
end

sources = cell(0);

for n=1:length(data.headers)
   header = data.headers(n);
   type = header.type;
   type = strrep(type, 'real.', '');
   type = strrep(type, 'vector3.accel', 'acceleration');
   type = strrep(type, 'vector3.rot', 'quaternion');
   type = strrep(type, 'vector3.pos', 'position');
   type = strrep(type, 'switch', 'on/off');
   
   sources(end+1) = {[header.name, ' [', type, ']']};
end

%show selection dialog
[sel,ok] = listdlg('PromptString','Select stream data','ListString',sources,'ListSize',[300,400]);

if ok == 1
    
    %disable all channels
    try
        disabledata = webread(strcat(disable_url,'all'), weboptions('ContentType','json'));
    catch
        error(['Could not connect to MR3 stream at ', server_url, '.  Check to be sure HTTP Streaming is enabled and a measurement is currently running.']);  
    end
    
    stream_config.server_url = server_url;

    for n=1:length(sel)
        
        %get current header
        header = data.headers(sel(n));
        
        %parse type 
        type = header.type;
        type = strrep(type, 'real.', '');
        type = strrep(type, 'vector3.accel', 'acceleration');
        type = strrep(type, 'vector3.rot', 'quaternion');
        type = strrep(type, 'vector3.pos', 'position');
        type = strrep(type, 'switch', 'on/off');
        
        %store channel info 
        stream_config.channelinfo(n).name = header.name;
        stream_config.channelinfo(n).type = type;
        stream_config.channelinfo(n).full_type = header.type;
        stream_config.channelinfo(n).sample_rate = header.samplerate;
        stream_config.channelinfo(n).units = header.units;
        stream_config.channelinfo(n).index = header.index;
        
        %enable channel
        try
            enabledata = webread(strcat(enable_url,num2str(header.index)), weboptions('ContentType','json'));
        catch
            error(['Could not connect to MR3 stream at ', server_url, '.  Check to be sure HTTP Streaming is enabled and a measurement is currently running.']);  
        end
        
    end
else % ok == 0        
    error('No data sources selected');
end












