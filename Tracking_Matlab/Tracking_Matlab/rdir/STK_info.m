function [STKplaneIndex,STKinfo,STKplaneInfo,Count,N] = STK_info(source)
%STKread Read Stack Images and Information (8bit and 16bit)
% function STKread(source)returns 4 Structures
% 
% Input: Source - Path + Filename 
%
% Output: [STKplanes,STKplaneIndex,STKinfo,STKplaneInfo]
%
% STKplanes - Image Data, 4-dimensional array [y,x,1,z] - format: uint16 
% STKplaneIndex - Plane Data, containing Z, Wavelength, CreationTime for each plane
% STKinfo - Stack Data, containing all relevent MetaMorph Stack data 
% more information at http://support.universal-imaging.com/docs/T10243.pdf
% STKplaneInfo - Image Information, containing all relevent grayscale tiff information
%
% Example: [Stack,Index,Data,Info] = STKread('ZSER16.STK');
%
% Copyright 2006 Felix Ruhnow 
% $Revision: 1.0 $ $Date: 2006/01/31 13:38:37 

STKplaneIndex = struct('Znumerator',{},'Zdenominator',{},'WavelengthNumerator',{},'WavelengthDenominator',{},'CreationDate',{},'CreationTime',{},'CreationTimeStr',{},'ModificationDate',{},'ModificationTime',{});

STKinfo = struct('AutoScale',{},'MinScale',{},'MaxScale',{},'SpatialCalibration',{},'XCalibration',{},'YCalibration',{},'CalibrationUnits',{},...
'Name',{},'ThreshState',{},'ThreshStateRed',{},'ThreshStateGreen',{},'ThreshStateBlue',{},'ThreshStateLo',{},'ThreshStateHi',{},'Zoom',{},...
'CreateTime',{},'LastSavedTime',{},'currentBuffer',{},'grayFit',{},'grayPointCount',{},'grayX',{},'grayY',{},'grayMin',{},'grayMax',{},'grayUnitName',{},...
'StandartLUT',{},'Wavelength',{},'StagePositionXnumerator',{},'StagePositionXdenominator',{},'StagePositionYnumerator',{},'StagePositionYdenominator',{},...
'CameraChipOffsetXnumerator',{},'CameraChipOffsetXdenominator',{},'CameraChipOffsetYnumerator',{},'CameraChipOffsetYdenominator',{},'OverlayMask',{},...
'OverlayCompress',{},'Overlay',{},'SpecialOverlayMask',{},'SpecialOverlayCompress',{},'SpecialOverlay',{},'ImageProperty',{},'StageLabel',{},...
'AutoScaleLoInfo',{},'AutoScaleHiInfo',{},'AbsoluteZ',{},'AbsoluteZValid',{},'Gamma',{},'GammaRed',{},'GammaGreen',{},'GammaBlue',{});

STKplaneInfo = struct('ImageWidth',{},'ImageLength',{},'BitsPerSample',{},'Compression',{},'PhotometricInterpretation',{},'StripOffsets',{},'RowsPerStrip',{},'StripByteCounts',{},...
'XResolution',{},'YResolution',{},'ResolutionUnit',{});

%required on mac to make the structure accessible, avoiding error A dot
%name structure assignment is illegal when the structure is empty.



file = fopen (source, 'r');
%read TIFF-header
if (file==-1)
    error('Cannot open the file %s',source);
end
%read byte order first
shortvalue = fread (file, 1, 'int16');

if (shortvalue == hex2dec('4949'))
    endian='l';
elseif (shortvalue == hex2dec('4D4D'))
    endian='b';
% fclose (file);
% error('File is in big endian order - no support yet');
else
fclose (file);
error('No Stack File')
end

fclose (file);
file = fopen (source, 'r',endian);
shortvalue = fread (file, 1, 'int16'); %skipping the byte order field

%check tiff format
shortvalue = fread (file, 1, 'int16',0,endian);
if (shortvalue ~= 42)
fclose (file);
error('No Tiff File');
end

%read IFD
A = fread (file, 1, 'uint32',0,endian);
fseek (file, A, 'bof');
%number of directory entries
B = fread (file, 1, 'int16',0,endian);
%search tags
for b = 0:B
fseek (file, A + 2 + b * 12, 'bof');
tag = fread (file, 1, 'uint16',0,endian); %read tags
%UIC2 Tag
if ( tag == hex2dec('100'))
shortvalue = fread (file, 1, 'int16',0,endian); % read type must be 4
C = fread (file, 1, 'int32',0,endian); % read 
STKplaneInfo(1).ImageWidth = fread (file, 1, 'int32',0,endian); %read Value
end
if ( tag == hex2dec('101'))
shortvalue = fread (file, 1, 'int16',0,endian); % read type must be 4
C = fread (file, 1, 'int32',0,endian); % read 
STKplaneInfo(1).ImageLength = fread (file, 1, 'int32',0,endian); %read Value
end
if ( tag == hex2dec('102'))
shortvalue = fread (file, 1, 'int16',0,endian); % read type must be 4
C = fread (file, 1, 'int32',0,endian); % read 
STKplaneInfo(1).BitsPerSample = fread (file, 1, 'int32',0,endian); %read Value
end
if ( tag == hex2dec('103'))
shortvalue = fread (file, 1, 'int16',0,endian); % read type must be 4
C = fread (file, 1, 'int32',0,endian); % read 
STKplaneInfo(1).Compression = fread (file, 1, 'int32',0,endian); %read Value
end
if ( tag == hex2dec('106'))
shortvalue = fread (file, 1, 'int16',0,endian); % read type must be 4
C = fread (file, 1, 'int32',0,endian); % read 
STKplaneInfo(1).PhotometricInterpretation = fread (file, 1, 'int32',0,endian); %read Value
end
if ( tag == hex2dec('111'))
shortvalue = fread (file, 1, 'int16',0,endian); % read type must be 4
Count = fread (file, 1, 'int32',0,endian); % read count 
C = fread (file, 1, 'int32',0,endian); %read Offset
fpos=ftell(file);
fseek (file, C, 'bof');
for i=1:Count
STKplaneInfo(1).StripOffsets(i)= fread (file, 1, 'int32',0,endian);
end
fseek (file, fpos, 'bof');
end
if ( tag == hex2dec('116'))
shortvalue = fread (file, 1, 'int16',0,endian); % read type must be 4
C = fread (file, 1, 'int32',0,endian); % read 
STKplaneInfo(1).RowsPerStrip = fread (file, 1, 'int32',0,endian); %read Value
end
if ( tag == hex2dec('117'))
shortvalue = fread (file, 1, 'int16',0,endian); % read type must be 4
I = fread (file, 1, 'int32',0,endian); % read count 
C = fread (file, 1, 'int32',0,endian); %read Offset
fpos=ftell(file);
fseek (file, C, 'bof');
for i=1:I
STKplaneInfo(1).StripByteCounts(i)= fread (file, 1, 'int32',0,endian);
end
fseek (file, fpos, 'bof');
end
if ( tag == hex2dec('11A'))
shortvalue = fread (file, 1, 'int16',0,endian); % read type must be 4
I = fread (file, 1, 'int32',0,endian); % read count 
C = fread (file, 1, 'int32',0,endian); %read Offset
fpos=ftell(file);
fseek (file, C, 'bof');
STKplaneInfo(1).XResolution = fread (file, 1, 'int32',0,endian); %read Value
fseek (file, fpos, 'bof');

end
if ( tag == hex2dec('11B'))
shortvalue = fread (file, 1, 'int16',0,endian); % read type must be 4
I = fread (file, 1, 'int32',0,endian); % read count 
C = fread (file, 1, 'int32',0,endian); %read Offset
fpos=ftell(file);
fseek (file, C, 'bof');
STKplaneInfo(1).YResolution = fread (file, 1, 'int32',0,endian); %read Value
fseek (file, fpos, 'bof');
end
if ( tag == hex2dec('128'))
shortvalue = fread (file, 1, 'int16',0,endian); % read type must be 4
C = fread (file, 1, 'int32',0,endian); % read 
STKplaneInfo(1).ResolutionUnit = fread (file, 1, 'int32',0,endian); %read Value
end
if ( tag == hex2dec('835D'))
shortvalue = fread (file, 1, 'int16',0,endian); % read type must be 5
N = fread (file, 1, 'int32',0,endian); % read count - number of frames
uic2 = fread (file, 1, 'int32',0,endian); %read offset
fseek (file, uic2, 'bof'); %set offset
for c = 1:N
STKplaneIndex(c).Znumerator = fread (file, 1, 'int32',0,endian);
STKplaneIndex(c).Zdenominator = fread (file, 1, 'int32',0,endian);
STKplaneIndex(c).CreationDate = JulianToYMD(fread (file, 1,'int32',0,endian));
STKplaneIndex(c).CreationTime = fread (file, 1, 'int32',0,endian);
STKplaneIndex(c).CreationTimeStr=format_time(STKplaneIndex(c).CreationTime);
STKplaneIndex(c).ModificationDate = fread (file, 1, 'int32',0,endian);
STKplaneIndex(c).ModificationTime = fread (file, 1, 'int32',0,endian);
end
end
if ( tag == hex2dec('835E'))
shortvalue = fread (file, 1, 'int16',0,endian); % read type must be 5
N = fread (file, 1, 'int32',0,endian); % read count - number of frames
% N = min(N_max,N);
uic3 = fread (file, 1, 'int32',0,endian); %read offset
fseek (file, uic2, 'bof'); %set offset
for c = 1:N
STKplaneIndex(c).WavelengthNumerator = fread (file, 1, 'int32',0,endian);
STKplaneIndex(c).WavelengthDenominator = fread (file, 1, 'int32',0,endian);
end
end
if ( tag == hex2dec('835F'))
shortvalue = fread (file, 1, 'int16',0,endian); % read type must be 4
N = fread (file, 1, 'int32',0,endian); % read count - number of frames
% N = min(N_max,N);
uic4 = fread (file, 1, 'int32',0,endian); %read offset
fseek (file, uic4, 'bof'); %set offset
tagID = fread (file, 1, 'int16',0,endian);
while (tagID~=0)
if ( tagID == 28)
for i=1:N
STKinfo(1).StagePositionXnumerator(i) = fread (file, 1, 'int32',0,endian); %read Value
STKinfo.StagePositionXdenominator(i) = fread (file, 1, 'int32',0,endian); %read Value
STKinfo.StagePositionYnumerator(i) = fread (file, 1, 'int32',0,endian); %read Value
STKinfo.StagePositionYdenominator(i) = fread (file, 1, 'int32',0,endian); %read Value
end
elseif( tagID == 29)
for i=1:N
STKinfo(1).CameraChipOffsetXnumerator(i) = fread (file, 1, 'int32',0,endian); %read Value
STKinfo.CameraChipOffsetXdenominator(i) = fread (file, 1, 'int32',0,endian); %read Value
STKinfo.CameraChipOffsetYnumerator(i) = fread (file, 1, 'int32',0,endian); %read Value
STKinfo.CameraChipOffsetYdenominator(i) = fread (file, 1, 'int32',0,endian); %read Value
end
elseif( tagID == 37)
for i=1:N
I = fread (file, 1, 'int32',0,endian);
STKinfo.StageLabel(i,:) = fread (file, I, '*char',0,endian)'; 
end
elseif( tagID == 40)
for i=1:N
num = fread (file, 1, 'int32',0,endian);
denom = fread (file, 1, 'int32',0,endian);
STKinfo.AbsoluteZ(i) = num/denom;
end 
elseif( tagID == 41)
for i=1:N
STKinfo.AbsoluteZValid(i) = fread (file, 1, 'int32',0,endian);
end 
else
for i=1:N
I = fread (file, 1, 'int32',0,endian);
I = fread (file, 1, 'int32',0,endian);
end
end
tagID = fread (file, 1, 'int16',0,endian);
end
end
end
for b = 0:B
fseek (file, A + 2 + b * 12, 'bof');
tag = fread (file, 1, 'uint16',0,endian); %read tags
if ( tag == hex2dec('835C'))
shortvalue = fread (file, 1, 'int16',0,endian); % read type must be 5
C = fread (file, 1, 'int32',0,endian); % read count
uic1 = fread (file, 1, 'int32',0,endian); %read offset
fseek (file, uic1, 'bof'); %set offset
while(uic1<uic4)
tagID = fread (file, 1, 'int32',0,endian); % read TagID
if ( tagID == 0)
STKinfo(1).AutoScale = fread (file, 1, 'int32',0,endian); %read Value
end
if ( tagID == 1)
STKinfo.MinScale = fread (file, 1, 'int32',0,endian); %read Value
end
if ( tagID == 2)
STKinfo.MaxScale = fread (file, 1, 'int32',0,endian); %read Value
end
if ( tagID == 3)
STKinfo.SpatialCalibration = fread (file, 1, 'int32',0,endian); %read Value
end
if ( tagID == 4)
C = fread (file, 1, 'int32',0,endian); %read Offset
fpos=ftell(file);
fseek (file, C, 'bof');
num = fread (file, 1, 'int32',0,endian);
denom = fread (file, 1, 'int32',0,endian);
STKinfo.XCalibration = num/denom;
fseek (file, fpos, 'bof');
end
if ( tagID == 5)
C = fread (file, 1, 'int32',0,endian); %read Offset
fpos=ftell(file);
fseek (file, C, 'bof');
num = fread (file, 1, 'int32',0,endian);
denom = fread (file, 1, 'int32',0,endian);
STKinfo.YCalibration = num/denom;
fseek (file, fpos, 'bof');
end
if ( tagID == 6)
C = fread (file, 1, 'int32',0,endian); %read Offset
fpos=ftell(file);
fseek (file, C, 'bof');
I = fread (file, 1, 'int32',0,endian);
STKinfo.CalibrationUnits = fread (file, I, '*char',0,endian)';
fseek (file, fpos, 'bof');
end
if ( tagID == 7)
C = fread (file, 1, 'int32',0,endian); %read Offset
fpos=ftell(file);
fseek (file, C, 'bof');
I = fread (file, 1, 'int32',0,endian);
STKinfo.Name =fread (file, I, '*char',0,endian)';
fseek (file, fpos, 'bof');
end
if ( tagID == 8)
STKinfo.ThreshState = fread (file, 1, 'int32',0,endian); %read Value
end
if ( tagID == 9)
STKinfo.ThreshStateRed = fread (file, 1, 'int32',0,endian); %read Value
end
if ( tagID == 10)
C = fread (file, 1, 'int32',0,endian); %read Value
end
if ( tagID == 11)
STKinfo.ThreshStateGreen = fread (file, 1, 'int32',0,endian); %read Value
end
if ( tagID == 12)
STKinfo.ThreshStateBlue = fread (file, 1, 'int32',0,endian); %read Value
end
if ( tagID == 13)
STKinfo.ThreshStateLo = fread (file, 1, 'int32',0,endian); %read Value
end
if ( tagID == 14)
STKinfo.ThreshStateHi = fread (file, 1, 'int32',0,endian); %read Value
end
if ( tagID == 15)
STKinfo.Zoom = fread (file, 1, 'int32',0,endian); %read Value
end
if ( tagID == 16)
C = fread (file, 1, 'int32',0,endian); %read Offset
fpos=ftell(file);
fseek (file, C, 'bof');
STKinfo.CreateTime= sprintf('%s %s',JulianToYMD(fread (file, 1,'int32',0,endian)),format_time(fread (file, 1,'int32',0,endian)));
fseek (file, fpos, 'bof');
end
if ( tagID == 17)
C = fread (file, 1, 'int32',0,endian); %read Offset
fpos=ftell(file);
fseek (file, C, 'bof');
STKinfo.LastSavedTime= sprintf('%s %s',JulianToYMD(fread (file, 1,'int32',0,endian)),format_time(fread (file, 1,'int32',0,endian)));
fseek (file, fpos, 'bof');
end
if ( tagID == 18)
STKinfo.currentBuffer = fread (file, 1, 'int32',0,endian); %read Value
end
if ( tagID == 19)
STKinfo.grayFit = fread (file, 1, 'int32',0,endian); %read Value
end
if ( tagID == 20)
STKinfo.grayPointCount = fread (file, 1, 'int32',0,endian); %read Value
end
if ( tagID == 21)
C = fread (file, 1, 'int32',0,endian); %read Offset
fpos=ftell(file);
fseek (file, C, 'bof');
num = fread (file, 1, 'int32',0,endian);
denom = fread (file, 1, 'int32',0,endian);
STKinfo.grayX = num/denom;
fseek (file, fpos, 'bof');
end
if ( tagID == 22)
C = fread (file, 1, 'int32',0,endian); %read Offset
fpos=ftell(file);
fseek (file, C, 'bof');
num = fread (file, 1, 'int32',0,endian);
denom = fread (file, 1, 'int32',0,endian);
STKinfo.grayY = num/denom;
fseek (file, fpos, 'bof');
end
if ( tagID == 23)
C = fread (file, 1, 'int32',0,endian); %read Offset
fpos=ftell(file);
fseek (file, C, 'bof');
num = fread (file, 1, 'int32',0,endian);
denom = fread (file, 1, 'int32',0,endian);
STKinfo.grayMin = num/denom;
fseek (file, fpos, 'bof');
end
if ( tagID == 24)
C = fread (file, 1, 'int32',0,endian); %read Offset
fpos=ftell(file);
fseek (file, C, 'bof');
num = fread (file, 1, 'int32',0,endian);
denom = fread (file, 1, 'int32',0,endian);
STKinfo.grayMax = num/denom;
fseek (file, fpos, 'bof');
end
if ( tagID == 25)
C = fread (file, 1, 'int32',0,endian); %read Offset
if C>0
fpos=ftell(file);
fseek (file, C, 'bof');
I = fread (file, 1, 'int32',0,endian);
STKinfo.grayUnitName = fread (file, I, '*char',0,endian)';
fseek (file, fpos, 'bof');
end
end
if ( tagID == 26)
STKinfo.StandartLUT = fread (file, 1, 'int32',0,endian); %read Value
end
if ( tagID == 27)
STKinfo.Wavelength = fread (file, 1, 'int32',0,endian); %read Value
end
if ( tagID == 28)
C = fread (file, 1, 'int32',0,endian); %read Offset
end
if ( tagID == 29)
C = fread (file, 1, 'int32',0,endian); %read Offset
end
if ( tagID == 30)
STKinfo.OverlayMask = fread (file, 1, 'int32',0,endian); %read Value
end
if ( tagID == 31)
STKinfo.OverlayCompress = fread (file, 1, 'int32',0,endian); %read Value
end
if ( tagID == 32)
STKinfo.Overlay = fread (file, 1, 'int32',0,endian); %read Value
end
if ( tagID == 33)
STKinfo.SpecialOverlayMask = fread (file, 1, 'int32',0,endian); %read Value
end
if ( tagID == 34)
STKinfo.SpecialOverlayCompress = fread (file, 1, 'int32',0,endian); %read Value
end
if ( tagID == 35)
STKinfo.SpecialOverlay = fread (file, 1, 'int32',0,endian); %read Value
end
if ( tagID == 36)
STKinfo.ImageProperty = fread (file, 1, 'int32',0,endian); %read Value
end
if ( tagID == 37)
F = fread (file, 1, 'int32',0,endian); %read Value
end
if ( tagID == 38)
C = fread (file, 1, 'int32',0,endian); %read Offset
fpos=ftell(file);
fseek (file, C, 'bof');
num = fread (file, 1, 'int32',0,endian);
denom = fread (file, 1, 'int32',0,endian);
STKinfo.AutoScaleLoInfo = num/denom;
fseek (file, fpos, 'bof');
end
if ( tagID == 39)
C = fread (file, 1, 'int32',0,endian); %read Offset
fpos=ftell(file);
fseek (file, C, 'bof');
num = fread (file, 1, 'int32',0,endian);
denom = fread (file, 1, 'int32',0,endian);
STKinfo.AutoScaleHiInfo = num/denom;
fseek (file, fpos, 'bof');
end
if ( tagID == 40)
F = fread (file, 1, 'int32',0,endian); %read Value
end
if ( tagID == 41)
F = fread (file, 1, 'int32',0,endian); %read Value
end
if ( tagID == 42)
C = fread (file, 1, 'int32',0,endian); %read Offset
fpos=ftell(file);
fseek (file, C, 'bof');
STKinfo.Gamma = fread (file, 1, 'int32',0,endian);
fseek (file, fpos, 'bof');
end
if ( tagID == 43)
C = fread (file, 1, 'int32',0,endian); %read Offset
fpos=ftell(file);
fseek (file, C, 'bof');
STKinfo.GammaRed = fread (file, 1, 'int32',0,endian);
fseek (file, fpos, 'bof');
end
if ( tagID == 44)
C = fread (file, 1, 'int32',0,endian); %read Offset
fpos=ftell(file);
fseek (file, C, 'bof');
STKinfo.GammaGreen = fread (file, 1, 'int32',0,endian);
fseek (file, fpos, 'bof');
end
if ( tagID == 45)
C = fread (file, 1, 'int32',0,endian); %read Offset
fpos=ftell(file);
fseek (file, C, 'bof');
STKinfo.GammaBlue = fread (file, 1, 'int32',0,endian);
fseek (file, fpos, 'bof');
end
uic1=ftell(file);
end
end
end




% stripsPerImage=Count;
% x=STKplaneInfo(1).ImageWidth;
% y=STKplaneInfo(1).ImageLength;
% I=uint16(zeros(y,x));
% try
% STKplanes(y,x,1,1:N)=I(y,x,1);
% catch 
% fclose (file);
% error('Out of memory');
% end
% if STKplaneInfo(1).BitsPerSample == 8
% s='uint8';
% elseif STKplaneInfo(1).BitsPerSample == 16
% s='uint16';
% else
% fclose (file);
% error('Only 8bit or 16bit Stacks supported');
% end 
% h = waitbar(0,'Reading Stack - Please wait...'); 
% for i=1:N 
% planeOffset = (i-1) * (STKplaneInfo(1).StripOffsets(stripsPerImage) + STKplaneInfo(1).StripByteCounts(stripsPerImage) - STKplaneInfo(1).StripOffsets(1)) + STKplaneInfo(1).StripOffsets(1);
% fseek (file, planeOffset, 'bof');
% for k=1:y
% STKplanes(k,1:1:x,1,i) = fread(file,x,s,0,endian);
% end
% waitbar(i/N)
% end
% close(h)
fclose(file);

function [date_string] = JulianToYMD(julian)

z = julian + 1;

%dealing with Gregorian calendar reform
if (z < 2299161) 
a = z;
else
alpha = ((z - 1867216.25) / 36524.25);
a = z + 1 + alpha - alpha / 4;
end
if a>1721423
b = a + 1524; 
else
b = a + 1158;
end
c = fix(((b - 122.1) / 365.25));
d = fix((365.25 * c));
e = fix(((b - d) / 30.6001));

day = fix(b - d - (30.6001 * e));
if e<13.5
month = fix(e - 1);
else
month = fix(e - 13);
end
if month > 2.5
year = fix(c - 4716);
else
year = fix(c - 4715);
end
date_string=sprintf('%02d-%02d-%04d',month,day,year);


function [time_string] = format_time(creation_time)

time_string='';
hour=fix(creation_time/(60*60*1000));
min=fix((creation_time-hour*(60*60*1000) ) / (60*1000));
sec=fix((creation_time-hour*(60*60*1000)-min*(60*1000) ) / (1000));
msec=(creation_time-hour*(60*60*1000)-min*(60*1000) -sec*(1000)) ;
time_string=sprintf('%02d:%02d:%02d:%03d',hour,min,sec,msec);
