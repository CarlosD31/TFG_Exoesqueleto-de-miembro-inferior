%   wrapper script to connect to Noraxon MR3 software and read JSON
%   data
% 
%   returns an object that contains data
%
%   usage:
%       data = noraxon_stream_collect(stream_config, seconds)
%

function data = noraxon_stream_collect(stream_config, seconds)

a = exist('webread');

if a == 0
    error('webread() missing. (Matlab R2014b+ required.)');
end

if nargin < 1
    error('A stream_object (returned from noraxon_stream_init) is required');
end

if nargin < 2
    seconds = 10;
end

data = {};
info = stream_config.channelinfo;

%store data headers
for n=1:length(info)
   data(n).info = info(n); 
   data(n).samples = []; 
   %determine number of samples required
   samples_remaining(n) = info(n).sample_rate * seconds;
end


%set last data time for timeout
last_data_timer = tic;
while max(samples_remaining) > 0

    try
        new_data = webread(strcat(stream_config.server_url,'/samples'), weboptions('ContentType','json'));
    catch 
        new_data = [];          
    end
    
    if isstruct(new_data)
        %update last data time for timeout
        last_data_timer = tic;
        
        %iterate over received data
        for n=1:length(new_data.channels)
            %get index of current channel
            index = new_data.channels(n).index;

            %find channel in data object
            for i = 1:length(data)
                if data(i).info.index == index
                        %store the data, based on type
                        if strcmp(data(i).info.full_type, 'vector3.rot') %quaternion, need to find a

                            to_copy = min(length(new_data.channels(n).samples)/3,samples_remaining(i));
                            samples = [];
                            for x = 1:to_copy
                               tmpx = new_data.channels(n).samples(((x-1)*3)+1);
                               tmpy = new_data.channels(n).samples(((x-1)*3)+2);
                               tmpz = new_data.channels(n).samples(((x-1)*3)+3);

                               samples(x).q0 = sqrt(max(0, 1 - ((tmpx * tmpx) + (tmpy * tmpy) + (tmpz * tmpz))));
                               samples(x).q1 = tmpx; 
                               samples(x).q2 = tmpy;
                               samples(x).q3 = tmpz;

                            end
                            data(i).samples = [data(i).samples, samples];
                            samples_remaining(i) = samples_remaining(i) - to_copy;

                        elseif ~isempty(strfind(data(i).info.full_type,'vector3')) %3d vector

                            to_copy = min(length(new_data.channels(n).samples)/3,samples_remaining(i));
                            samples = [];
                            for x = 1:to_copy
                               samples(x).x = new_data.channels(n).samples(((x-1)*3)+1); 
                               samples(x).y = new_data.channels(n).samples(((x-1)*3)+2);
                               samples(x).z = new_data.channels(n).samples(((x-1)*3)+3);
                            end
                            data(i).samples = [data(i).samples, samples];
                            samples_remaining(i) = samples_remaining(i) - to_copy;

                        else %single analog channel

                            to_copy = min(length(new_data.channels(n).samples),samples_remaining(i));
                            data(i).samples = [data(i).samples; new_data.channels(n).samples(1:to_copy)];
                            samples_remaining(i) = samples_remaining(i) - to_copy;

                        end
                    break
                end
            end           

        end
    else
        % webread error
        if toc(last_data_timer) > 5
            error('MR3 stream timeout.  Check to be sure HTTP Streaming is enabled and a measurement is currently running.');
            break;
        end        
    end
    
end


