function varargout = dsp_signal_compression(varargin)
% DSP_SIGNAL_COMPRESSION MATLAB code for dsp_signal_compression.fig
%      DSP_SIGNAL_COMPRESSION, by itself, creates a new DSP_SIGNAL_COMPRESSION or raises the existing
%      singleton*.
%
%      H = DSP_SIGNAL_COMPRESSION returns the handle to a new DSP_SIGNAL_COMPRESSION or the handle to
%      the existing singleton*.
%
%      DSP_SIGNAL_COMPRESSION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DSP_SIGNAL_COMPRESSION.M with the given input arguments.
%
%      DSP_SIGNAL_COMPRESSION('Property','Value',...) creates a new DSP_SIGNAL_COMPRESSION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dsp_signal_compression_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dsp_signal_compression_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dsp_signal_compression

% Last Modified by GUIDE v2.5 09-Mar-2019 16:40:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dsp_signal_compression_OpeningFcn, ...
                   'gui_OutputFcn',  @dsp_signal_compression_OutputFcn, ...
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


% --- Executes just before dsp_signal_compression is made visible.
function dsp_signal_compression_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dsp_signal_compression (see VARARGIN)

% Choose default command line output for dsp_signal_compression
handles.output = hObject;

handles.mode='Lossy';
handles.basis='haar';
handles.compressed_filename='compressed.mat';
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dsp_signal_compression wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = dsp_signal_compression_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in browse_button.
function browse_button_Callback(hObject, eventdata, handles)
% hObject    handle to browse_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.filename,handles.filepath] = uigetfile('*.csv;*.xls;*.xlsv;*.xlsx','Select a Signal');
handles.file = [handles.filepath handles.filename];

if handles.file
    set(handles.compress_button,'Enable','off');
    set(handles.decompress_button,'Enable','off');
    handles.COMPRESS_FLAG=false;
    handles.DECOMPRESS_FLAG=false;
    [path,name,ext]=fileparts(handles.file);
    if strcmp('.mat',ext)
        handles.DECOMPRESS_FLAG=true;
        handles.compressed_file = matfile(handles.file);
        set(handles.decompress_button,'Enable','on');
    else
        handles.COMPRESS_FLAG=true;
        handles.signal= xlsread(handles.file);
        set(handles.compress_button,'Enable','on');
    end
end

guidata(hObject,handles);




% --- Executes on selection change in mode_menu.
function mode_menu_Callback(hObject, eventdata, handles)
% hObject    handle to mode_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(hObject,'String'))
handles.mode=contents{get(hObject,'Value')};
guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns mode_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from mode_menu


% --- Executes during object creation, after setting all properties.
function mode_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mode_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in compress_button.
function compress_button_Callback(hObject, eventdata, handles)
% hObject    handle to compress_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% transformation
[approximated_signal,details_signal]=dwt(handles.signal,handles.basis);

% calculating some compression parameters
[threshold,sorh,keepapp]=ddencmp('cmp','wv',details_signal);

% Looping to zerofy all the values in my threshold range
iterator=1;
while(iterator<size(details_signal,1))
    if details_signal(iterator,1) > -1*threshold && details_signal(iterator,1) < threshold
        details_signal(iterator,1)=0;
    end
      iterator=iterator+1;
end
% Sparse to squeeze zeros out
sparsed_approximated_signal=sparse(approximated_signal);
sparsed_details_signal=sparse(details_signal);
sparsed_transformed_signal=[sparsed_approximated_signal sparsed_details_signal];
% Save the file squeezed out of zeros
save(handles.compressed_filename,'sparsed_transformed_signal');

axes(handles.original_axis);
plot(handles.signal(1:1000,1))
hold on

set(handles.decompress_button,'Enable','on');
guidata(hObject,handles);


% --- Executes on button press in decompress_button.
function decompress_button_Callback(hObject, eventdata, handles)
% hObject    handle to decompress_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
compressed_file = matfile(handles.compressed_filename);
full_signal=full(compressed_file.sparsed_transformed_signal);
retrievedSignal=idwt(full_signal(:,1),full_signal(:,2),handles.basis);
xlswrite('decompressed.xlsx',retrievedSignal);
plot(retrievedSignal(1:1000,1));
guidata(hObject,handles);


% --- Executes on selection change in basis_menu.
function basis_menu_Callback(hObject, eventdata, handles)
% hObject    handle to basis_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(hObject,'String'))
handles.basis=contents{get(hObject,'Value')}
guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns basis_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from basis_menu



% --- Executes during object creation, after setting all properties.
function basis_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to basis_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end