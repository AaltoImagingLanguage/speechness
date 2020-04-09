function [ind] = extract_auditory_channels()

chan_order = load('chan_order.mat');
audcortex = load('chan_auditory_cortex.mat');
chan_order = chan_order.chan_names;
audcortex = [audcortex.lefttemp; audcortex.righttemp];

indices = zeros(1,length(audcortex));
for(k = 1:length(audcortex))
	mapped_ind = strmatch(audcortex{k}, chan_order);
	if(length(mapped_ind) > 0)
		indices(k) = strmatch(audcortex{k}, chan_order);
	end
end

ind = indices(find(indices > 0));
