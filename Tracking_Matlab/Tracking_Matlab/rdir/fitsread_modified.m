function [data]=fitsread_modified(varargin)
% global new_run_ri;
%     if (new_run_ri)
%         p = mfilename('fullpath');
%         Version_perso(p);
%     end
%modified from fitsread function ($Revision: 1.1.6.2 $  $Date: 2004/02/01 22:03:53 $)
%to allow loading of only a part of the
%file

%Parse Inputs
%Verify inputs are correct
[filename,extension,index,raw] = parseInputs(varargin{:});

%Get file info. FITSINFO will check for file existence.
info = fitsinfo(filename);

%Read data from primary data 

data = [];
msg = 'Error reading file.  File may be an invalid FITS file or may be corrupt.';

if info.PrimaryData.DataSize==0
  return;
end

startpoint = info.PrimaryData.Offset;

%Data will be scaled by scale values BZERO, BSCALE if they exist
bscale = info.PrimaryData.Slope;
bzero = info.PrimaryData.Intercept;
nullvals = info.PrimaryData.MissingDataValue;

fid = fopen_perso(info.Filename,'r',1,'ieee-be');
if fid==-1
  error('MATLAB:fitsread:fileOpen', '%s', msg);
end
si=info.PrimaryData.Size;
unit_length=prod(si(1:(size(si,2)-1)));
if ((unit_length*index)>prod(info.PrimaryData.Size))
  fclose_perso(fid);
  error('MATLAB:fitsread:index_out_of_range', '%s', msg)
end
switch (info.PrimaryData.DataType)
    case { 'int16','uint16'}
        shift=unit_length*(index-1)*2;
    case { 'int32','uint32'}
        shift=unit_length*(index-1)*4;
    case { 'single'}
        shift=unit_length*(index-1)*4;
end
startpoint=startpoint+shift;
status = fseek(fid,startpoint,'bof');
if status==-1
  fclose_perso(fid);
  error('MATLAB:fitsread:corruptFile', '%s', msg)
end
[data, count] = fread(fid,unit_length,['*' info.PrimaryData.DataType]);
fclose_perso(fid);
if count<unit_length
  warning_perso('MATLAB:fitsread:truncatedData', ...
          'Problem reading primary data. Data has been truncated.');
else
  %Data is stored in column major order so the first two dimensions must be
  %permuted
  data = permute(reshape(data,si(1:(size(si,2)-1))),...
		 [2 1 3:length(si(1:(size(si,2)-1)))]);
  %Scale data and replace undefined data with NaN by default
  if ~raw && ~isempty(nullvals)
    data(data==nullvals) = NaN;
  end
  if ~raw 
    data = double(data)*bscale+bzero;
  end
end
%END READFITSPRIMARY

function [filename,extension,index,raw] = parseInputs(varargin)
%Verify inputs are correct
estr = nargchk(1,4,nargin, 'struct');
if (~isempty(estr))
    error(estr);
end

filename = varargin{1};
extension = 'primary';
index = 1;
raw = 0;

allStrings = {'primary','raw'};
for k = 2:length(varargin)
  if (ischar(varargin{k}))
    idx = strmatch(lower(varargin{k}), allStrings);
    switch length(idx)
     case 0
      error('MATLAB:fitsread:inputArguments', 'Unknown string argument: "%s."', varargin{k});
     case 1
      varargin{k} = allStrings{idx};
     otherwise
      error('MATLAB:fitsread:inputArguments', 'Ambiguous string argument: "%s."', varargin{k});
    end
  else
    %Don't allow fitsread(filename,idx);
    if k==2
      error('MATLAB:fitsread:extensionIndex', ...
            'The extension index IDX must follow the extension name EXTNAME.');
    end
  end
end

for i=2:nargin
  switch lower(varargin{i})
   case 'primary'
    extension = 'primary';
    if (i+1)<=nargin && isnumeric(varargin{i+1})
      index  = varargin{i+1};
    end
   case 'raw'
    raw = 1;
  end
end
%END PARSEINPUTS
