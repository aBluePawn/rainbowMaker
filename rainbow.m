function varargout = rainbow(varargin)
% RAINBOW MATLAB code for rainbow.fig
%      RAINBOW, by itself, creates a new RAINBOW or raises the existing
%      singleton*.
%
%      H = RAINBOW returns the handle to a new RAINBOW or the handle to
%      the existing singleton*.
%
%      RAINBOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RAINBOW.M with the given input arguments.
%
%      RAINBOW('Property','Value',...) creates a new RAINBOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before rainbow_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to rainbow_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help rainbow

% Last Modified by GUIDE v2.5 27-Jun-2019 19:52:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @rainbow_OpeningFcn, ...
    'gui_OutputFcn',  @rainbow_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before rainbow is made visible.
function rainbow_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to rainbow (see VARARGIN)

% Show the tutorial
% See https://uk.mathworks.com/matlabcentral/answers/30017-output-a-file-text-in-a-uicontrol-of-style-static-text
fid = fopen('RainbowMaker_Tutorial.txt');
if fid >0
    tutorial = textscan(fid, '%s', 'Delimiter', '\n');
end
fclose(fid);

% TODO improve the tutorial textbox
% https://undocumentedmatlab.com/blog/smart-listbox-editbox-scrollbars

set(handles.text3, 'String', tutorial{:});

% Choose default command line output for rainbow
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = rainbow_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
% Load Image
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% clear the axes
% see https://uk.mathworks.com/matlabcentral/answers/222578-display-image-in-axes-matlab-gui
cla; % try also cla reset
[fileName, path] = uigetfile('*.*','Select an image');
handles.fileName = fileName; % used to save the new image
%Quit the execution if no file is selected
if fileName == 0
    errordlg('No file selected') ;
    error('No file selected');
end
completePath = strcat(path,fileName);
A = imread(completePath);

% adjust the orientation
% see https://uk.mathworks.com/matlabcentral/answers/260607-how-to-load-a-jpg-properly
info = imfinfo(completePath); % some images will generate an warning here,
% see https://uk.mathworks.com/matlabcentral/answers/30046-corrupt-image
if isfield(info, 'Orientation')
    orientation=info(1).Orientation;
    switch orientation
        case 1
            %;
        case 2
            A = A(:,end:-1:1,:);
        case 3
            A = A(end:-1:1,end:-1:1,:);
        case 4
            A = A(end:-1:1,:,:);
        case 5
            A = permute(A, [2 1 3]);
        case 6
            A = rot90(A,3);
        case 7
            A = rot90(A(end:-1:1,:,:));
        case 8
            A = rot90(A);
        otherwise
            warning('unknown orientation %g ignored\n', orientation);
    end
end

set(handles.text3, 'Visible', 'Off');
imshow(A);
handles.image = A;
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbutton2.
% Draw
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% The colours
colours = [[1 0 0]; [1 0.498 0]; [1 1 0]; [0 1 0]; [0 0 1]; [0.294 0 0.509]; [0.545 0 1]];

% Get image dimensions
[nrows, ncols,~] = size(handles.image);
stripeWidth = round(nrows*0.025);

% Get mouse inputs
button=1;
count=0; % keep track of the points that are selected
while button==1
    % Get the coordinates
    [xClick,yClick,button] = ginput(1);
    
    if button ~=1
        break
    end
    
    count = count + 1;
    xClick = round(xClick);
    yClick = round(yClick);
    
    % If the click is outside the image, bring it at the edge of the image
    if xClick < round(ncols*0.05)
        xClick = 1;
    elseif xClick > round(ncols*0.95)
        xClick = ncols;
    end
    
    if yClick < round(nrows*0.05)
        yClick = 1;
    elseif yClick > round(nrows*0.95)
        yClick = nrows;
    end
    
    % Save the clicked points
    x(count,:) = xClick;
    y(count,:) = yClick;
    
    hold on;
    % show the lines
    if count ==1
        pl = plot(x,y, 'r*');
    elseif count>1
        if exist('pl', 'var')==1
            delete(pl);
        end
        pl = line(x,y);
        pl.Color = 'red';
    end
end
delete(pl);

% Draw a polyline linking the clicked points
h = drawpolyline(gca, 'Position',[x y]);

% Generate the curve
polyline = h.Position;
[newX, newY] = splinefit(polyline);
plottedLines = [];
fillArea = [];
numOfColours = get(handles.popupmenu1, 'Value');
for k = 1:numOfColours+1
    p = plot(newX, newY-2*(k-1)*stripeWidth);
    plottedLines = [plottedLines, p];
    
    % Fill the gap
    % See https://uk.mathworks.com/matlabcentral/answers/180829-shade-area-between-graphs
    if(length(plottedLines)>1)
        Cx = [plottedLines(end).XData, fliplr(plottedLines(end-1).XData)];
        Cy = [plottedLines(end).YData, fliplr(plottedLines(end-1).YData)];
        f = fill(Cx, Cy, colours(k-1,:)); %, 'FaceAlpha', .5);
        fillArea = [fillArea, f];
    end
end
handles.polyline = h;
guidata(hObject, handles);

%%% Line adjustments
% Use a callback
% See https://uk.mathworks.com/help/images/use-wait-function-after-drawing-roi-example.html
% TODO provide a different way to exit this loop. Either use escape button, or ...
adjustStatus = get(handles.radiobutton1, 'Value');
while adjustStatus==1
    pos = customWait(h);
    [newX, newY] = splinefit(pos);
    delete(plottedLines);
    delete(fillArea);
    plottedLines = [];
    fillArea = [];
    for k = 1:numOfColours+1
        p = plot(newX, newY-2*(k-1)*stripeWidth);
        plottedLines = [plottedLines, p];
        if(length(plottedLines)>1)
            Cx = [plottedLines(end).XData, fliplr(plottedLines(end-1).XData)];
            Cy = [plottedLines(end).YData, fliplr(plottedLines(end-1).YData)];
            f = fill(Cx, Cy, colours(k-1,:)); %, 'FaceAlpha', .1);
            fillArea = [fillArea, f];
        end
    end
    adjustStatus = get(handles.radiobutton1, 'Value');
end
hold off

% By now I should have all the information I need to write the rainbow to the image
handles.thePatches = fillArea;
handles.polyline = h;

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbutton3.
% Save as
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% show busy status
oldpointer = get(handles.figure1,'pointer');
set(handles.figure1, 'pointer', 'watch');
drawnow;

newI = handles.image;

for i = 1:length(handles.thePatches)
    currentPatch = handles.thePatches(i);
    h = drawpolygon('Position', currentPatch.Vertices, 'Visible', 'off');
    bw = createMask(h, handles.image);
    newI= imoverlay(newI,bw, currentPatch.FaceColor);
end

figure;
imshow(newI);

% Save the new image, creating a new fileName
newFileName = strcat('rainbow_', handles.fileName);
imwrite(newI, newFileName);

% normal pointer
set(handles.figure1, 'pointer', oldpointer);


% --- Executes on button press in pushbutton4.
% View/Hide the polyline
% preview the image with the rainbow
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(handles.polyline.Visible, 'off')
    handles.polyline.Visible = 'on';
    handles.pushbutton4.String = 'Hide polyline';
elseif isequal(handles.polyline.Visible, 'on')
    handles.polyline.Visible = 'off';
    handles.pushbutton4.String = 'View polyline';
end

% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Functions

% Custom wait function for the polyline
function pos = customWait(hROI)
% Listen for mouse clicks on the polyline
l = addlistener(hROI, 'ROIClicked', @clickCallback);

% Block program execution
uiwait;

% Remove listener
delete(l);

% Return the new position
pos = hROI.Position;

% The click callback function
function clickCallback(~, evt)

if strcmp(evt.SelectionType, 'middle')
    uiresume;
end

% The spline fit function
function [x,y] = splinefit(polyline)

xCoordLine =polyline(:,1);
yCoordLine = polyline(:,2);

minX = min(xCoordLine);
maxX = max(xCoordLine);

x = minX:10:maxX;
y = spline(xCoordLine, yCoordLine, x);
