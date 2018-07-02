function h = lateximage(varargin)
%lateximage   Create image object with rendered LaTeX text
%   lateximage(X,Y,'string') adds the LaTeX text in the quotes to location
%   (X,Y) on the current axes, where (X,Y) is in units from the current
%   plot. If X and Y are vectors, text writes the text at all locations
%   given. If 'string' is an array the same number of rows as the
%   length of X and Y, text marks each point with the corresponding row
%   of the 'string' array.
%
%   lateximage returns a column vector of handles to image objects, one
%   handle per image object. image objects are children of AXES objects.
%
%   The X,Y pair (X,Y,Z triple for 3-D) can be followed by option/value
%   pairs to specify options to render the LaTeX text. The X,Y pair can be
%   omitted entirely, and all properties specified using parameter/value
%   pairs.
%
%   Supported Options     Description
%   -----------------------------------------------------------------------
%   String                LaTeX text to display
%   Color                 Text color as RGB triplet
%   FontSize              Font size in points (default: 10)
%   FontSmoothing         Degree of antialiasing (default: 8). The higher
%                         the smoother.
%   EdgeColor             Color of box outline as RGB triplet or 'none'
%                         (default: 'none')
%   BackgroundColor       Color of text box background as RGB triplet or
%                         'none' for transparent background (Default:
%                         'none')
%   Margin*               Space around text within the text box in points
%                         (default: 3). Can also be set by margin/border
%                         option in LatexDocumentOptions. Margin option
%                         is ignored if both are specified.
%   LineWidth             Width of box outline in points (default: 0.5)
%   Position              Location of text in data units
%   Rotation              Text orientation in degrees (default: 0).
%                         Requires Image Processing Toolbox.
%   HorizontalAlignment   [{'left'}|'center'|'right'] Horizontal alignment
%                         of text with respect to position point
%   VerticalAlignment     ['bottom'|{'middle'}|'top'] Vertical alignment of
%                         text with respect to position point
%   Parent                Parent of image (default: current axes)
%   OverSamplingFactor    Set this value higher to get higher resolution
%                         image beyond that given in ScreenPixelsPerInch.
%   EquationOnly          true to render String as a LaTeX equation
%   LatexDocumentOptions  LaTeX document class (standalone) options as
%                         struct with its field names as the option names
%                         and their values sets the option values. By
%                         default, 'preview' option is set regardless of
%                         this user input.
%   LatexPackages         LaTeX packages to include. Default setting
%                         includes amsmath amsfonts amssymb and bm
%                         packages. To override, supply custom cell array
%                         list of packages. Each element must be either the
%                         name of the package or a cellstring specifying
%                         {'name' 'optionstring'}.
%   LatexPreamble         Additional LaTeX preamble to be inserted between
%                         \usepackage lines and \begin{Document} line.
%
%   * Margin set in LaTeX document is currently squashed by dvipng call.
%   If anyone knows how to fix this problem, shoot me an email.
%
%   lateximage(H,Option1Name,Option1Value,...) updates lateximage image
%   objects with their handle in H with the trailing new option name/value
%   pairs.
%
%   lateximage -printmode, lateximage -printmode on, and lateximage
%   -printmode off set axes with lateximage objects to be ready for
%   printing. If 'on' or 'off' switch is not given, the mode is toggled.
%   Turning the printmode on enables printing the lateximage at the correct
%   font size. Set printmode on saves the current axes position in pixels
%   to scale the image appropriately during Matlab's print operation. If
%   axes is moved since the last call, printmode must be set on again.
%
%   Also, to obtain a good resolution on the printed LaTeX text, set
%   OverSamplingFactor. To meet a target DPI setting, use the formula: 
%
%      OverSamplingFactor = ceil(DesiredDPI/get(0,'ScreenPixelsPerInch'))
%
%   lateximage requires latex and dvipng executables to be in the system
%   search path. Internally, lateximage generates a standalone LaTeX
%   document with the provided String and renders it as PNG image via
%   pngdvi call. Virtually any LaTeX text can be rendered via setting
%   String, LatexDocumentOptions, LatexPackages, and LatexPreamble options.
%   For the full list of available document options, see
%
%      https://www.ctan.org/pkg/standalone 
%
%   The auto-built LaTeX source code has an appearance of
%
%      \documentclass[%LatexDocumentOptions goes here%]{standalone}
%      \usepackage{%LatexPackages{1}%}
%      \usepackage... % one line per LatexPackages entry
%
%      %LatexPreamble text goes here
%
%      \begin{document}
%      % String value goes here
%      \end{document}
%   
%   For EquationOnly text, the document segment has the format
%
%      ...
%      \begin{document}
%      $\displaystyle
%      % String value goes here
%      $
%      \end{document}

% Copyright 2015 Takeshi Ikuma
% History:
% rev. - : (10-11-2015) original release
% rev. 1.1: (10-16-2015) 
%   *   image's Clipping property is set to 'off' by default
%   *   does not return handle if no output argument given
%   *   if LaTeX build failed, returns the auto-generated .tex file content
%   *   Pre-HG2 enhancement: listening to figure size change
%   *   bug fix: dvipng command string (invalid -D value)
%   *   bug fix: input parsing
% rev. 1.2: (10-22-2015)
%   *   improved printmode scaling
% rev. 1.2.1: (10-25-2015)
%   *   bug fix: XLim monitoring was previously not enabled
% rev. 1.2.2: (10-31-2015)
%   *   bug fix: another printmode fix
% rev. 1.2.3: (11-02-2015)
%   *   removed nagging warning for use of feature('UseHG2')

[h,ax,x,y,str,opts] = parse_input(nargin,varargin);

if ~isempty(ax)
   % setting axes operating mode (setting -printmode option)
   setprintmode(ax, opts.printmode);
   clear h
elseif ~isempty(h)
   % change object properties
   for n = 1:numel(h)
      updateobject(h(n),opts)
   end
   clear h
else
   % new object(s)
   if mod(opts.Rotation,90)~=0 && isempty(ver('images'))
      error('Image Processing Toolbox must be installed in order to rotate the text at non-integer multiple of 90??');
   end
   
   if isempty(x) % multiple objects, recurse
      h = newobject(opts);
      if verLessThan('matlab','8.4') % pre-HG2, return double handles
         h = double(h);
      end
   else
      h = zeros(numel(x),1);
      for n = 1:numel(x)
         h(n) = lateximage('Position',[x(n) y(n)],'String',str{min(n,numel(str))},varargin{4:end});
      end
   end
   
   if nargout==0
      clear h
   end
end
end

function h = newobject(opts)

% obtain LaTeX text image & alpha matrices
[A,ALPHA,dims] = renderlatex(opts);

% get parent object
if isempty(opts.Parent)
   ax = handle(gca);
   opts.Parent = ax;
else
   ax = handle(ancestor(opts.Parent,'axes'));
end

% get image corner coordinates
[xdata,ydata] = getextents(ax,opts.Position(1),opts.Position(2),dims,...
   opts.HorizontalAlignment,opts.VerticalAlignment,opts.Rotation);

% create new image object
h = handle(image('XData',xdata,'YData',ydata,'CData',flipud(A),'Parent',opts.Parent,'Clipping','off'));
if ~isempty(ALPHA)
   h.AlphaData = flipud(double(ALPHA)/255);
end

% save the config data & set up the object listeners
setappdata(h,'LaTeXImageData',rmfield(opts,'Parent'));
setappdata(h,'LaTeXImageSize',dims);
setappdata(h,'LaTeXImageExtent',[xdata ydata]);

setappdata(h,'LaTeXImagePostSetXData',...
   addlistener(h,'XData','PostSet',@move));
setappdata(h,'LaTeXImagePostSetYData',...
   addlistener(h,'YData','PostSet',@move));
try
   addlistener(h,'Reparent',@reparent);
catch
   addlistener(h,'ObjectParentChanged',@reparent);
end
addlistener(h,'ObjectBeingDestroyed',@cleanup);

% set up the axes listeners
axessetup(ax,h);

% set root listener for the dpi change
if ~isappdata(0,'LaTeXImageDpiMonitored')
   addlistener(0,'ScreenPixelsPerInch','PostSet',@dpichanged);
   setappdata(0,'LaTeXImageDpiMonitored',true);
end

end

function updateobject(h,newopts)

opts = getappdata(h,'LaTeXImageData');

% merge new opts
fnames = fieldnames(newopts);
for n = 1:numel(fnames)
   opts.(fnames{n}) = newopts.(fnames{n});
end
setappdata(h,'LaTeXImageData',opts);

% redraw LaTeX text image & alpha matrices
if any(ismember(fnames,{'BackgroundColor','Color','EdgeColor','FontSize',...
      'FontSmoothing','LatexDocumentOptions','LatexPackages','LatexPreamble',...
      'LineWidth','Margin','OverSamplingFactor','String','Rotation'}))
   [A,ALPHA,dims] = renderlatex(opts);
   h.CData = flipud(A);
   if ~isempty(ALPHA)
      h.AlphaData = flipud(ALPHA);
   end
   setappdata(h,'LaTeXImageSize',dims);
else
   dims = getappdata(h,'LaTeXImageSize');
end

% get image corner coordinates
[xdata,ydata] = getextents(handle(ancestor(h,'axes')),opts.Position(1),opts.Position(2),dims,...
   opts.HorizontalAlignment,opts.VerticalAlignment,opts.Rotation);

% create new image object
setappdata(h,'LaTeXImageExtent',[xdata ydata]);
listento_move(h,false);
h.XData = xdata;
h.YData = ydata;
listento_move(h,true);

% Reparent change
if isfield(newopts,'Parent')
   set(h,'Parent',opts.Parent); % let reparent listener to take care of the rest
end

end

function setprintmode(axs, onoff)
% called by lateximage -printmode on
%           lateximage -printmode off or
%           lateximage(ax,'-printmode',onoff)

for ax = axs
   if isappdata(ax,'LaTeXImageHandles')
      if isempty(onoff) % toggle
         mode = getappdata(ax,'LaTeXImagePrintMode');
         if isempty(mode)
            mode = on;
         else
            mode = ~mode;
         end
      else
         mode = onoff;
      end
      setappdata(ax,'LaTeXImagePrintMode',mode);
      if mode
         hg1 = verLessThan('matlab','8.4');
         if hg1
            lis = getappdata(ax,'LaTeXImageOnSizeChanged');
            set(lis,'Enabled','off');
         end
         u = ax.Units;
         ax.Units = 'pixels';
         setappdata(ax,'LaTeXImageDefaultAxesSize',ax.Position([3 4]));
         ax.Units = u;
         if hg1
            set(lis,'Enabled','on');
         end
      end
   end
   axesredraw(ax,[]);% redraw axes
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LISTENER CALLBACKS

function move(prop,evt)

h = evt.AffectedObject;
opts = getappdata(h,'LaTeXImageData');
ax = handle(ancestor(h,'axes'));

if strcmp(prop.Name,'XData')
   idx = 1;
   val = h.XData([1 end]);
   islog = strcmp(ax.XScale,'log');
   align = opts.HorizontalAlignment;
   dir = strcmp(ax.XDir,'normal');
else
   idx = 2;
   val = h.YData([1 end]);
   islog = strcmp(ax.YScale,'log');
   align = opts.VerticalAlignment;
   dir = strcmp(ax.YDir,'normal');
end   
if islog
   val = log10(val);
end

if align==2 % 'center'
   val = mean(val);
elseif (align==1 && dir) || (align==3 && ~dir)
   val = val(1);
else
   val = val(2);
end
opts.Position(idx) = val;

% update the appdata
setappdata(h,'LaTeXImageData',opts); % save new extent

dims = getappdata(h,'LaTeXImageSize');
[xdata,ydata] = getextents(ax,opts.Position(1),opts.Position(2),dims,...
   opts.HorizontalAlignment,opts.VerticalAlignment,opts.Rotation);
setappdata(h,'LaTeXImageExtent',[xdata ydata]); % save new extent

% update the image objects position
listento_move(h,false);
h.XData = xdata;
h.YData = ydata;
listento_move(h,true);

end

function reparent(h,evt)
%reparent event listener callback

try % HG2
   axnew = ancestor(evt.NewValue,'axes');
   axold = ancestor(evt.OldValue,'axes');
catch % HG1
   axnew = handle(ancestor(evt.NewParent,'axes'));
   axold = handle(ancestor(evt.OldParent,'axes'));
end
% if still on the same axes, nothing to do
if isempty(axnew) || isempty(axold) || axnew==axold
   return;
end

% remove the association to the old axes
axescleanup(axold,h);

% associate with the new axes
axessetup(axnew,h);

end

function dpichanged(~,~)
% root ScreenPixelsPerInch PostSet callback

for ax = findobj('type','axes')'
   if isappdata(ax,'LaTeXImageHandles')
      for h = getappdata(ax,'LaTeXImageHandles')
         % redraw the latex image
         
         % get config data
         opts = getappdata(h,'LaTeXImageData');
         
         % obtain LaTeX text image & alpha matrices
         [A,ALPHA,dims] = renderlatex(opts);
         
         % get image corner coordinates
         [xdata,ydata] = getextents(ax,opts.Position(1),opts.Position(2),dims,...
            opts.HorizontalAlignment,opts.VerticalAlignment,opts.Rotation);
         
         % update the appdata
         setappdata(h,'LaTeXImageExtent',[xdata ydata]); % save new extent
         
         % update the image object
         listento_move(h,false);
         h.XData = xdata;
         h.YData = ydata;
         listento_move(h,true);
         h.CData = flipud(A);
         if ~isempty(ALPHA)
            h.AlphaData = flipud(double(ALPHA)/255);
         end
      end
   end
end
end

function axesredraw(ax,~)
% listener callback for the axes containing lateximage objects

hs = getappdata(ax,'LaTeXImageHandles');
if isempty(setdiff(handle(ax.Children),hs)) % only LaTeXImage objects
   %if axes contains no object, add an invisible rectangle to avoid the
   %redraw infinite loop
   xl = ax.XLim; yl = ax.YLim;
   
   setappdata(ax,'LaTeXImagePlaceHolder',...
      rectangle('Position',[xl(1) yl(1) diff(xl) diff(yl)],'EdgeColor','none'));
end

for h = hs % for each latex image object, rescale
   opts = getappdata(h,'LaTeXImageData');
   dims = getappdata(h,'LaTeXImageSize');
   [xdata,ydata] = getextents(ax,opts.Position(1),opts.Position(2),dims,...
      opts.HorizontalAlignment,opts.VerticalAlignment,opts.Rotation);

   % if moved, reposition & save new extent
   if any([xdata ydata]~=getappdata(h,'LaTeXImageExtent'))
      setappdata(h,'LaTeXImageExtent',[xdata ydata]); % save new extent
      listento_move(h,false);
      h.XData = xdata;
      h.YData = ydata;
      listento_move(h,true);
   end
end
end

function axesredraw_hg1(~,evt) % for older version
axesredraw(evt.AffectedObject)
end

function cleanup(h,~)
%destruction callback
ax = handle(ancestor(h,'axes'));
axescleanup(ax,h);
end

function listento_move(h,ena)
% listener callback supporting function to enable/disable listening to 
% XData & YData proeprties of H

lis = getappdata(h,'LaTeXImagePostSetXData');
try
lis.Enabled = ena;
catch
   if ena
      ena = 'on';
   else
      ena = 'off';
   end
   lis.Enabled = ena;
end
lis = getappdata(h,'LaTeXImagePostSetYData');
lis.Enabled = ena;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function axessetup(ax,h)

hs = getappdata(ax,'LaTeXImageHandles');
if isempty(hs) % first time
   % create appdata
   setappdata(ax,'LaTeXImageHandles',h);
   setappdata(ax,'LaTeXImagePrintMode',false);
   
   % set up new listeners
   try
      setappdata(ax,'LaTeXImageOnSizeChanged',addlistener(ax,'SizeChanged',@axesredraw));
      setappdata(ax,'LaTeXImageOnMarkedClean',addlistener(ax,'MarkedClean',@axesredraw));
   catch
      setappdata(ax,'LaTeXImageOnSizeChanged',[...
         addlistener(ax,'Position','PostSet',@axesredraw_hg1)...
         addlistener(ax,'Parent','PostSet',@axesredraw_hg1)]);
      setappdata(ax,'LaTeXImageOnMarkedClean',[...
         addlistener(ax,'XLim','PostSet',@axesredraw_hg1)...
         addlistener(ax,'XDir','PostSet',@axesredraw_hg1)...
         addlistener(ax,'XScale','PostSet',@axesredraw_hg1)...
         addlistener(ax,'YLim','PostSet',@axesredraw_hg1)...
         addlistener(ax,'YDir','PostSet',@axesredraw_hg1)...
         addlistener(ax,'YScale','PostSet',@axesredraw_hg1)...
         addlistener(ax,'DataAspectRatio','PostSet',@axesredraw_hg1)...
         addlistener(ax,'PlotBoxAspectRatio','PostSet',@axesredraw_hg1)]);
      
      % also need to monitor figure's Position
      framesetup(handle(ax.Parent),ax);
   end
else % already exists
   % add the new object to the appdata
   setappdata(ax,'LaTeXImageHandles',[hs h]);
end
end

function axescleanup(ax,h)
% called when h is deleted or moved to another parent

% update its lateximage handles
hs = setdiff(getappdata(ax,'LaTeXImageHandles'),h);
setappdata(ax,'LaTeXImageHandles',hs);

if isempty(hs) % delete all listeners
   % remove from figure's axes list
   framecleanup(handle(ax.Parent),ax);
   
   % delete all axes listeners
   lis = getappdata(ax,'LaTeXImageOnSizeChanged');
   if ~isempty(lis)
      delete(lis);
      rmappdata(ax,'LaTeXImageOnSizeChanged');
   end
   lis = getappdata(ax,'LaTeXImageOnMarkedClean');
   if ~isempty(lis)
      delete(lis);
      rmappdata(ax,'LaTeXImageOnMarkedClean');
   end
   
   % delete placeholder rectangle if exists
   r = getappdata(ax,'LaTeXImagePlaceHolder');
   if ~isempty(r)
      try
         delete(r);
      catch
      end
      rmappdata(ax,'LaTeXImagePlaceHolder');
   end
   
   % delete misc appdata
   if isappdata(ax,'LaTeXImagePrintMode')
      rmappdata(ax,'LaTeXImagePrintMode');
   end
   if isappdata(ax,'LaTeXImageDefaultAxesSize')
      rmappdata(ax,'LaTeXImageDefaultAxesSize');
   end
   
end
end

function frameredraw_hg1(~,evt)
frameredraw(evt.AffectedObject);
end

function frameredraw(fig)
% in HG1, if figure/frame has been resized, pass the command down

hs = getappdata(fig,'LaTeXImageAxes');
for n = 1:numel(hs)
   if ishghandle(hs(n),'axes')
      axesredraw(hs(n))
   else
      frameredraw(hs(n));
   end
end
end

function framesetup(fig,ax)
% only for HG1

hs = getappdata(fig,'LaTeXImageAxes');
if isempty(hs)
   % create appdata
   setappdata(fig,'LaTeXImageAxes',ax);
   
   % set up new listeners
   setappdata(fig,'LaTeXImageFigureSize',...
      addlistener(fig,'Position','PostSet',@frameredraw_hg1));
   
   % recurse until it is figure
   p = fig.Parent;
   if p~=0 % not root
      framesetup(handle(p),fig);
   end
else % already exists
   % add the new object to the appdata
   setappdata(fig,'LaTeXImageAxes',[hs ax]);
end

end

function framecleanup(fig,ax)
% called when h is deleted or moved to another parent

% update its lateximage handles
hs = setdiff(getappdata(fig,'LaTeXImageAxes'),ax);
setappdata(fig,'LaTeXImageAxes',hs);

if isempty(hs) % delete all listeners

   % delete the Position listeners
   lis = getappdata(fig,'LaTeXImageFigureSize');
   if ~isempty(lis)
      delete(lis);
      rmappdata(fig,'LaTeXImageFigureSize');
   end
   
   % remove from figure's axes list
   p = fig.Parent;
   if p>0
      framecleanup(handle(p),fig);
   end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to place and scale the image

function [xdata,ydata] = getextents(ax,x,y,dims,halign,valign,rot)

% if print mode is on, scale text image according to the axes scaling
if getappdata(ax,'LaTeXImagePrintMode')
   % During printing, MATLAB unreportedly changes the DPI to the printing
   % resolution, momentarily yielding large axes size in pixels. To
   % maintain the proper LaTeX image size, the dimension of the image must
   % be reported larger than 
   u = ax.Units;
   ax.Units = 'pixels';
   scale = ax.Position([3 4])./getappdata(ax,'LaTeXImageDefaultAxesSize');
   dims = dims*mean(scale);
   ax.Units = u;
end

% get axes info
[x2px,y2px,islog,xlim,ylim] = data2pxratio(ax);

% scale to the current resolution wrt default res to match the Matlab
% behavior
try % hg2
   sdpi = get(0,'ScreenPixelsPerInch')/get(0,'DefaultRootScreenPixelsPerInch');
catch
   sdpi = 1;
end
x2px = x2px*sdpi;
y2px = y2px*sdpi;

% go to pixel domain
[x,y] = data2px(ax,x,y,x2px,y2px,islog,xlim,ylim);

% get the corner coordinates based on the image pivot point
w = dims(2);
switch halign
   case 1 % left
      xdata = [x x+w];
   case 2 % center
      xdata = [x-w/2 x+w/2];
   case 3 % right
      xdata = [x-w x];
end
h = dims(1);
switch valign
   case 1 % bottom
      ydata = [y y+h];
   case 2 % middle
      ydata = [y-h/2 y+h/2];
   case 3 % top
      ydata = [y-h y];
end

% if rotated, find the corner coordinates of the rotated image
if rot~=0
   Ttra1 = eye(3); Ttra1(3,[1 2]) = -[x y];
   Trot = [cosd(rot) sind(rot) 0; -sind(rot) cosd(rot) 0; 0 0 1];
   Ttra2 = eye(3); Ttra2(3,[1 2]) = [x y];
   tform = affine2d(Ttra1*Trot*Ttra2);
   
   [X,Y] = meshgrid(xdata,ydata);
   [X,Y] = tform.transformPointsForward(X,Y);
   xdata = [min(X(:)) max(X(:))];
   ydata = [min(Y(:)) max(Y(:))];
end

% go back to data domain
[xdata,ydata] = px2data(ax,xdata,ydata,x2px,y2px,islog,xlim,ylim);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to create LaTeX PNG image

function [A,ALPHA,dims] = renderlatex(opts)

[dirname,filebase] = fileparts(tempname);
texfile = fullfile(dirname,[filebase '.tex']);
dvifile = fullfile(dirname,[filebase '.dvi']);
psfile = fullfile(dirname,[filebase '.ps']);
pngfile = fullfile(dirname,[filebase '.png']);
strfile = fullfile(dirname,[filebase '.*']);

C = onCleanup(@()delete(strfile));

% set option name to all lower case to remove any potential redundancy
docopts = struct('preview','true');
for fname = fieldnames(opts.LatexDocumentOptions)'
   docopts.(lower(fname)) = opts.LatexDocumentOptions.(fname);
end
if ~any(isfield(docopts,{'margin','border'})) && opts.Margin>0
   docopts.margin = num2str(opts.Margin);
end

% parse tex file
fid = fopen(texfile,'wt');
fprintf(fid,'\\documentclass[');
sep = '';
for fname = fieldnames(docopts)'
   fn = char(fname);
   fprintf(fid,'%c%s',sep,fn);
   if ~isempty(docopts.(fn))
      fprintf(fid,'=%s',docopts.(fn));
   end
   sep = ',';
end
fprintf(fid,']{standalone}\n');
for n = 1:numel(opts.LatexPackages)
   package = opts.LatexPackages{n};
   if iscell(package) % package{1}:name,package{2}:options
      fprintf(fid,'\\usepackage[%s]{%s}\n',package{2},package{1});
   else
      fprintf(fid,'\\usepackage{%s}\n',package);
   end
end



if ~isempty(opts.LatexPreamble)
   fprintf(fid,'%s\n',opts.LatexPreamble);
end

fprintf(fid,'\\begin{document}\n');
if ~isempty(opts.String)
   if opts.EquationOnly
      fprintf(fid,'$\\displaystyle\n%s$\n',opts.String);
   else
      fprintf(fid,'%s\n',opts.String);
   end
end
fprintf(fid,'\\end{document}\n');

fclose(fid);


% run latex to create DVI file
cmd = sprintf('latex -quiet -aux-directory="%s" -output-directory="%s" "%s"', dirname, dirname, texfile);

[s,r] = system(cmd); % intercepts command's output stream
if s~=0
   % if failed, report the error with tex file content
   
   fid = fopen(texfile);
   tex = fscanf(fid,'%c');
   fclose(fid);
   
   error('%s\n\n%s\n\nGenerated .tex file:\n%s\n',cmd,r,tex);
end

% run dvipng to create PNG file: https://www.ctan.org/pkg/dvipng
% dpi = get(0,'ScreenPixelsPerInch');
% D = dpi*opts.FontSize/10*opts.OverSamplingFactor;
% 
% cmd = sprintf('dvips -q -D %d -o "%s" "%s"',D,psfile,dvifile);
% [s,r] = system(cmd); % intercepts command's output stream
% if s~=0
%    % if failed, report the error
%    error('%s\n\n%s',cmd,r);
% end
% 
% eps2raster(psfile,pngfile,'Resolution',D);

dpi = get(0,'ScreenPixelsPerInch');
D = dpi*opts.OverSamplingFactor*opts.FontSize/10;
D = ceil(D*10)/10;
cmd = sprintf('dvipng -q --truecolor -T bbox -D %g -Q %d',D,opts.FontSmoothing);
if ischar(opts.BackgroundColor)
   cmd = sprintf('%s -bg Transparent',cmd);
else
   cmd = sprintf('%s -bg "rgb %g %g %g"',cmd,opts.BackgroundColor(1),opts.BackgroundColor(2),opts.BackgroundColor(3));
end
if ~isempty(opts.Color)
   cmd = sprintf('%s -fg "rgb %g %g %g"',cmd,opts.Color(1),opts.Color(2),opts.Color(3));
end
if ~(isempty(opts.EdgeColor) || ischar(opts.EdgeColor))
   th = ceil(opts.LineWidth/72*D);
   cmd = sprintf('%s -bd "%d rgb %g %g %g"',cmd,th,opts.EdgeColor(1),opts.EdgeColor(2),opts.EdgeColor(3));
end

cmd = sprintf('%s -o "%s" "%s"',cmd,pngfile,dvifile);
[s,r] = system(cmd); % intercepts command's output stream
if s~=0
   % if failed, report the error
   error('%s\n\n%s',cmd,r);
end

% read png file
[A,~,ALPHA] = imread(pngfile);
dims = size(A); % save the original image size
dims = dims([1 2])/opts.OverSamplingFactor;

% apply rotation if specified
if mod(opts.Rotation,90)==0
   K = mod(opts.Rotation/90,4);
   A = rot90(A,K);
   ALPHA = rot90(ALPHA,K);
else
   A = imrotate(A,opts.Rotation,'bicubic','loose');
   ALPHA = imrotate(ALPHA,opts.Rotation,'bicubic','loose');
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions to convert units between data and pixels

function [x,y] = data2px(ax,x,y,x2px,y2px,islog,xlim,ylim)

% log to linear space
if islog(1)
   x = log10(x);
end
if islog(2)
   y = log10(y);
end

% add offsets
if strcmp(ax.XDir,'normal')
   x = x - xlim(1);
else
   x = xlim(2) - x;
end
if strcmp(ax.YDir,'normal')
   y = y - ylim(1);
else
   y = ylim(2) - y;
end

% pixel origin is (0,0)
x = x/x2px;
y = y/y2px;
end

function [x,y] = px2data(ax,x,y,x2px,y2px,islog,xlim,ylim)

% pixel origin is (0,0)
x = x*x2px;
y = y*y2px;

% add offsets
if strcmp(ax.XDir,'normal')
   x = x + xlim(1);
else
   x = xlim(2) - x;
end
if strcmp(ax.YDir,'normal')
   y = y + ylim(1);
else
   y = ylim(2) - y;
end

% log to linear space
if islog(1)
   x = 10.^(x);
end
if islog(2)
   y = 10.^(y);
end
end

function [x2px,y2px,islog,xlim,ylim] = data2pxratio(ax)
%DATA2PXRATIO   Get pixel to axis data unit conversion factors
%   [AxPos0,X2Px,Y2Px,XLim,YLim] = DATA2PXRATIO(AX) computes the location
%   of the lower left hand corner of the axis in pixels with respect to the
%   lower left hand corner of the figure, ratio of unit x-coordinate length
%   to number of pixels, X2Px, ratio fo the unit y-coodinate length to
%   number of pixels, Y2Px, and the axes position of AX. In addition, the
%   limits of x and y axes are returned in XLim and YLim.

islog = strcmp({ax.XScale ax.YScale},'log'); % needs updating

% get the axes position in pixels
units_bak = ax.Units;  % save the original Units mode
ax.Units = 'pixels';
axloc_px = ax.Position;
ax.Units = units_bak;    % reset to the original Units mode

darIsManual  = strcmp(ax.DataAspectRatioMode,'manual');
pbarIsManual = strcmp(ax.PlotBoxAspectRatioMode,'manual');
xlim = ax.XLim; if islog(1), xlim(:) = log10(xlim); end
ylim = ax.YLim; if islog(2), ylim(:) = log10(ylim); end
dx = diff(xlim);
dy = diff(ylim);

if darIsManual || pbarIsManual
   axisRatio = axloc_px(3)/axloc_px(4);
   
   if darIsManual
      dar = ax.DataAspectRatio;
      limDarRatio = (dx/dar(1))/(dy/dar(2));
      if limDarRatio > axisRatio
         ht = axloc_px(3)/limDarRatio;
         axloc_px(4) = ht;
      else
         wd = axloc_px(4) * limDarRatio;
         axloc_px(3) = wd;
      end
   else%if pbarIsManual
      pbar = ax.PlotBoxAspectRatio;
      pbarRatio = pbar(1)/pbar(2);
      if pbarRatio > axisRatio
         ht = axloc_px(3)/pbarRatio;
         axloc_px(4) = ht;
      else
         wd = axloc_px(4) * pbarRatio;
         axloc_px(3) = wd;
      end
   end
end

% convert to data unit
x2px = dx/axloc_px(3);
y2px = dy/axloc_px(4);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions to valdiate the input arguments

function [h,ax,x,y,str,opts] = parse_input(narg,args)

% parse options
optcfgs = {
   'Parent'                []          @ishghandle
   'Color'                 []          @(v)validateattributes(v,{'numeric'},{'numel',3,'nonnegative','<=',1})
   'Position'              [0 0]       @(v)validateattributes(v,{'numeric'},{'numel',2})
   'String'                ''          @(v)validateattributes(v,{'char'},{'row'})
   'Rotation'              0           @(v)validateattributes(v,{'numeric'},{'scalar','finite'})
   'FontSize'              10          @(v)validateattributes(v,{'numeric'},{'scalar','positive','finite'})
   'HorizontalAlignment'   'left'      @(v)validateattributes(v,{'char'},{'row'})
   'VerticalAlignment'     'middle'    @(v)validateattributes(v,{'char'},{'row'})
   'EdgeColor'             'none'      @validatecolor
   'LineWidth'             0.5         @(v)validateattributes(v,{'numeric'},{'scalar','positive','finite'});
   'BackgroundColor'       'none'      @validatecolor
   'Margin'                3           @(v)validateattributes(v,{'numeric'},{'scalar','nonnegative'})
   'FontSmoothing'         8           @(v)validateattributes(v,{'numeric'},{'scalar','positive','integer'})
   'EquationOnly'          true        @(v)validateattributes(v,{'logical'},{'scalar'})
   'LatexDocumentOptions'	struct([])  @validatedocopts
   'LatexPackages'         {'amsmath','amsfonts','amssymb','bm'} @validatepackages
   'LatexPreamble'         ''          @(v)validateattributes(v,{'char'},{'row'})
   'OverSamplingFactor'    1           @(v)validateattributes(v,{'numeric'},{'scalar','nonnegative','integer'})};

[h,ax,x,y,str,opts] = deal([]);
if narg==0, return; end

p = inputParser;

if all(ishghandle(args{1}(:),'axes')) || (ischar(args{1}) && args{1}(1)=='-')
   % setting operation mode for axes containing lateximage
   if ishghandle(args{1}(1),'axes')
      if narg<2
         error('axes handle input requires mode argument');
      end
      ax = handle(args{1}(:)');
      args(1) = [];
   else
      ax = handle(findobj('type','axes')');
   end
   
   if strcmpi(args{1},'-printmode')
      if narg<2
         opts.printmode = [];
      else
         try
            opts.printmode = strcmp(validatestring(args{2},{'on','off'}),'on');
         catch
            validateattributes(args{2},{'logical'},{'scalar'});
            opts.printmode = args{2};
         end
      end
      return;
   end
elseif all(ishghandle(args{1},'image'))
   % changes properties of existing lateximage object
   h = handle(args{1});
   if ~all(arrayfun(@(h)isappdata(h,'LaTeXImageData'),h))
      error('All H must be image object handles created by lateximage.');
   end
   args(1) = [];
   [optcfgs{:,2}] = deal([]);
elseif isnumeric(args{1}) % expects {x,y,'string'} as the first three inputs
   if numel(args{1})==1 % single object
      % convert it to properties
      args = [{'Position',[args{[1 2]}],'String'},args(3:end)];
   else
      sz = size(args{1});
      p.addRequired('XData',@(v)validateattributes(v,{'numeric'},{'2d'}));
      p.addRequired('YData',@(v)validateattributes(v,{'numeric'},{'size',sz}));
      p.addRequired('Strings',@(v)validatestrings(v,sz));
      
      p.parse(args{1:min(3,narg)});
      
      x = p.Results.XData;
      y = p.Results.YData;
      str = cellstr(p.Results.Strings);
      opts = [];
      return
   end
end

for n = 1:size(optcfgs,1)
   p.addParameter(optcfgs{n,:});
end

p.parse(args{:});

opts = p.Results;

if ~isempty(opts.HorizontalAlignment)
   opts.HorizontalAlignment = find(strcmp(validatestring(opts.HorizontalAlignment,...
      {'left','center','right'}),{'left','center','right'}));
end
if ~isempty(opts.VerticalAlignment)
   opts.VerticalAlignment = find(strcmp(validatestring(opts.VerticalAlignment,...
      {'bottom','middle','top'}),{'bottom','middle','top'}));
end

% if updating, remove unspecified options
if ~isempty(h)
   fnames = optcfgs(:,1);
   opts = rmfield(opts,fnames(arrayfun(@(name)isempty(opts.(name{1})),fnames)));
end

end

function tf = validatecolor(v)
if ischar(v) && isrow(v)
   tf = strncmpi(v,'none',numel(v));
else
   validateattributes(v,{'numeric'},{'numel',3,'nonnegative','<=',1});
   tf = true;
end
end

function validatedocopts(v)
validateattributes(v,{'struct'},{'scalar'});
structfun(@(f)validateattributes(f,{'char'},{'row'}),v);
end

function validatepackages(v)
validateattributes(v,{'cell'},{});
for n = 1:numel(v)
   package = v{n};
   if iscell(package) % {name optionstring}
      cellfun(@(v)validateattributes(v,{'char'},{'row'}),package);
   else % just package name
      validateattributes(package,{'char'},{'row'});
   end
end
end

function tf = validatestrings(v,sz)
if ischar(v)
   validateattributes(v,{'char'},{'row'});
   tf = true;
else
   validateattributes(v,{'cell'},{'size',sz});
   tf = iscellstr(v);
end
end
