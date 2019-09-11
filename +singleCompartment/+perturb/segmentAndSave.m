function segmentAndSave(v, x0, y0, save_name)
	
disp('Starting voronoiSegment....')
v.find(x0,y0);
v.findBoundaries(v.handles.ax(2))


% first print the figure and close it
print(v.handles.fig,[save_name '.eps'],'-depsc2')
close(v.handles.fig)


% now save the voronoi object
save(save_name,'v')
